// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:archive/archive.dart';
import 'package:xml/xml.dart';

const kanjiVgUrl =
    'https://github.com/KanjiVG/kanjivg/releases/download/r20220427/kanjivg-20220427-all.zip';
const kanjidic2Url = 'http://www.edrdg.org/kanjidic/kanjidic2.xml.gz';

void main() async {
  print('Iniciando Ingestión de Datos Kanji...');
  final rawDataDir = Directory('raw_data');
  if (!rawDataDir.existsSync()) rawDataDir.createSync();

  // 1. Descargar KanjiVG
  final kanjiVgZipPath = '${rawDataDir.path}/kanjivg.zip';
  if (!File(kanjiVgZipPath).existsSync()) {
    print('Descargando KanjiVG...');
    final response = await http.get(Uri.parse(kanjiVgUrl));
    File(kanjiVgZipPath).writeAsBytesSync(response.bodyBytes);
  }

  // 2. Descargar Kanjidic2
  final kanjidic2GzPath = '${rawDataDir.path}/kanjidic2.xml.gz';
  if (!File(kanjidic2GzPath).existsSync()) {
    print('Descargando Kanjidic2...');
    final response = await http.get(Uri.parse(kanjidic2Url));
    File(kanjidic2GzPath).writeAsBytesSync(response.bodyBytes);
  }

  // 3. Extraer SVGs
  print('Extrayendo trazos vectoriales de KanjiVG...');
  final bytes = File(kanjiVgZipPath).readAsBytesSync();
  final archive = ZipDecoder().decodeBytes(bytes);

  final Map<String, List<String>> kanjiSvgPaths = {};

  for (final file in archive) {
    if (file.isFile &&
        file.name.endsWith('.svg') &&
        !file.name.contains('0_')) {
      // name is e.g. kanjivg/kanji/0f9a8.svg
      final hexStr = file.name.split('/').last.replaceAll('.svg', '');
      final charCode = int.tryParse(hexStr, radix: 16);
      if (charCode == null) continue;

      final kanjiChar = String.fromCharCode(charCode);

      final content = utf8.decode(file.content as List<int>);
      final document = XmlDocument.parse(content);
      final paths = document
          .findAllElements('path')
          .map((e) => e.getAttribute('d') ?? '')
          .toList();
      kanjiSvgPaths[kanjiChar] = paths;
    }
  }

  // 4. Parsear Kanjidic2
  print('Descomprimiendo Kanjidic2...');
  final gzBytes = File(kanjidic2GzPath).readAsBytesSync();
  final xmlContent = utf8.decode(GZipDecoder().decodeBytes(gzBytes));

  print('Parseando Kanjidic2 XML...');
  final document = XmlDocument.parse(xmlContent);
  final characters = document.findAllElements('character');

  final List<Map<String, dynamic>> kanjiSeedList = [];

  for (final char in characters) {
    final literal = char.findElements('literal').firstOrNull?.innerText;
    if (literal == null) continue;

    // Solo procesar Joyo kanjis y kanjis con trazos en KanjiVG
    final jlpt = char.findAllElements('jlpt').firstOrNull?.innerText;
    final grade = char.findAllElements('grade').firstOrNull?.innerText;

    // Ignorar si no es de uso común y no está en KanjiVG
    if (jlpt == null && grade == null && !kanjiSvgPaths.containsKey(literal)) {
      continue;
    }

    final svgPaths = kanjiSvgPaths[literal] ?? [];
    if (svgPaths.isEmpty) continue;

    final rmgroups = char.findAllElements('rmgroup');
    final List<String> onyomi = [];
    final List<String> kunyomi = [];
    final List<String> meanings = [];

    if (rmgroups.isNotEmpty) {
      final rmgroup = rmgroups.first;

      // Lecturas
      for (final reading in rmgroup.findAllElements('reading')) {
        final rType = reading.getAttribute('r_type');
        if (rType == 'ja_on') onyomi.add(reading.innerText);
        if (rType == 'ja_kun') kunyomi.add(reading.innerText);
      }

      // Significados (Priorizar Español, luego Inglés)
      final allMeanings = rmgroup.findAllElements('meaning');
      final spanishMeanings = allMeanings
          .where((e) => e.getAttribute('m_lang') == 'es')
          .map((e) => e.innerText)
          .toList();
      final englishMeanings = allMeanings
          .where((e) => e.getAttribute('m_lang') == null)
          .map((e) => e.innerText)
          .toList();

      if (spanishMeanings.isNotEmpty) {
        meanings.addAll(spanishMeanings);
      } else {
        meanings.addAll(englishMeanings);
      }
    }

    final radicals = char
        .findAllElements('rad_value')
        .map((e) => e.innerText)
        .toList();

    final jlptVal = jlpt != null ? int.tryParse(jlpt) ?? 0 : 0;
    final gradeVal = grade != null ? int.tryParse(grade) ?? 0 : 0;

    kanjiSeedList.add({
      'character': literal,
      'onyomi': onyomi,
      'kunyomi': kunyomi,
      'meanings': meanings,
      'radicals': radicals,
      'svgPaths': svgPaths,
      'jlpt': jlptVal,
      'joyo': gradeVal,
    });
  }

  print('Kanjis procesados: ${kanjiSeedList.length}');

  // 5. Guardar JSON
  final outputDir = Directory('../../apps/kanjizen_app/assets/data');
  if (!outputDir.existsSync()) outputDir.createSync(recursive: true);

  final jsonStr = jsonEncode(kanjiSeedList);
  File('${outputDir.path}/kanji_seed.json').writeAsStringSync(jsonStr);
  print(
    '¡Éxito! Archivo guardado en ${outputDir.path}/kanji_seed.json con tamaño ${(jsonStr.length / 1024 / 1024).toStringAsFixed(2)} MB',
  );
}
