// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:kz_data/src/entities/kana_entity.dart';
import 'package:kz_data/src/entities/kanji_entity.dart';
import 'package:kz_data/src/entities/kana_level_entity.dart';
import 'package:kz_data/src/services/kana_seed_data.dart';

/// Inicializa la base de datos Isar y siembra los datos de Kana en background.
/// Ejecutado en un Isolate la primera vez que se abre la app.
class DatabaseInitializerService {
  static Isar? _instance;

  static Future<Isar> openDb() async {
    if (_instance != null && _instance!.isOpen) return _instance!;
    final dir = await getApplicationDocumentsDirectory();
    _instance = await Isar.open(
      [KanaEntitySchema, KanjiEntitySchema, KanaLevelEntitySchema],
      directory: dir.path,
      inspector: false,
    );
    return _instance!;
  }

  /// Devuelve true si la BD ya tiene datos de Kana sembrados.
  static Future<bool> isKanaSeeded() async {
    final isar = await openDb();
    return await isar.kanaEntitys.count() > 0;
  }

  static Future<bool> isKanjiSeeded() async {
    final isar = await openDb();
    return await isar.kanjiEntitys.count() > 0;
  }

  static Future<void> seedInBackground() async {
    try {
      final isar = await openDb();

      final kanaSeeded = await isKanaSeeded();
      if (!kanaSeeded) {
        final entities = KanaSeedData.all.map((s) {
          return KanaEntity()
            ..character = s.character
            ..romaji = s.romaji
            ..isKatakana = s.isKatakana
            ..linkedKanaCharacter = s.linkedKanaCharacter
            ..isDakutenOrHandakuten = s.isDakutenOrHandakuten
            ..isUnlocked = const ['あ', 'い', 'う', 'え', 'お'].contains(s.character)
            ..historyBlob = []
            ..svgPaths = s.character == 'あ'
                ? [
                    'M29.5,39.5c2.38,1.38,6.88,1.38,9.75,0.75c12.38-2.75,25.62-5.75,34.88-6.62c2.62-0.25,5.12-0.25,7.38,0.38',
                    'M47,21.5c1.62,1.38,2.12,3.38,2.12,5.62c0,16.5-1.5,41-15.38,53.88',
                    'M68.5,46.5c0.62,1.25,0.5,2.62-0.5,4c-6.62,9.12-19.38,21.62-38.25,29.38',
                    'M43.75,54.25c4.75,2.12,13.25,6.25,19.38,15.62c3.5,5.38,6.25,11.88,7.38,18.88c0.75,4.75,0.25,8.88-2,10.62c-3.12,2.38-7.5,1.12-9.75-2.25c-4.12-6.12-8.38-16.75-10.62-23.75',
                  ]
                : []
            ..currentHitRate = 0.0
            ..averageMs = 0;
        }).toList();

        await isar.writeTxn(() async {
          await isar.kanaEntitys.putAll(entities);
        });
      }

      final kanjiSeeded = await isKanjiSeeded();
      if (!kanjiSeeded) {
        try {
          final kanjiJsonStr = await rootBundle.loadString(
            'assets/data/kanji_seed.json',
          );
          final List<dynamic> data = jsonDecode(kanjiJsonStr) as List<dynamic>;
          final List<KanjiEntity> entities = [];

          for (final item in data) {
            final map = item as Map<String, dynamic>;
            final e = KanjiEntity()
              ..character = map['character'] as String
              ..onyomi = List<String>.from(map['onyomi'] as Iterable<dynamic>)
              ..kunyomi = List<String>.from(map['kunyomi'] as Iterable<dynamic>)
              ..meanings = List<String>.from(
                map['meanings'] as Iterable<dynamic>,
              )
              ..radicals = List<String>.from(
                map['radicals'] as Iterable<dynamic>,
              )
              ..svgPaths = List<String>.from(
                map['svgPaths'] as Iterable<dynamic>,
              )
              ..isUnlocked = false
              ..historyBlob = []
              ..currentHitRate = 0.0
              ..averageMs = 0;

            final radicalsList = e.radicals;
            if (map.containsKey('radical')) {
              e.radical = map['radical'] as String;
            } else if (radicalsList.isNotEmpty) {
              e.radical = radicalsList.first;
            } else {
              e.radical = '';
            }

            e.jlpt = map.containsKey('jlpt') && map['jlpt'] is num
                ? (map['jlpt'] as num).toInt()
                : 0;
            e.joyo = map.containsKey('joyo') && map['joyo'] is num
                ? (map['joyo'] as num).toInt()
                : 0;
            e.isJinmeiyo = map.containsKey('isJinmeiyo')
                ? map['isJinmeiyo'] as bool
                : false;
            e.kanjidicTranslations = map.containsKey('kanjidicTranslations')
                ? List<String>.from(
                    map['kanjidicTranslations'] as Iterable<dynamic>,
                  )
                : [];

            entities.add(e);
          }

          for (var i = 0; i < entities.length; i += 1000) {
            final chunk = entities.skip(i).take(1000).toList();
            await isar.writeTxn(() async {
              await isar.kanjiEntitys.putAll(chunk);
            });
          }
        } catch (e) {
          print('Error cargando kanji_seed.json: $e');
        }
      }
    } catch (e, stack) {
      print('Error durante el seeding: $e\n$stack');
    }
  }
}
