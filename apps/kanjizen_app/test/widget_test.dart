import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kz_domain/kz_domain.dart';
import 'package:kz_ui_components/kz_ui_components.dart';

void main() {
  testWidgets('GridCell muestra el carácter y candado cuando está bloqueado', (
    WidgetTester tester,
  ) async {
    const kana = KanaModel(
      character: 'あ',
      romaji: 'a',
      isKatakana: false,
      linkedKanaCharacter: '',
      isDakutenOrHandakuten: false,
      isUnlocked: false,
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: GridCell(kana: kana),
        ),
      ),
    );

    expect(find.text('あ'), findsOneWidget);
    expect(find.byIcon(Icons.lock_outline), findsOneWidget);
  });

  testWidgets('KanjiGridCell muestra el kanji y candado cuando está bloqueado', (
    WidgetTester tester,
  ) async {
    const kanji = KanjiModel(
      character: '水',
      meanings: ['agua'],
      radicals: [],
      isUnlocked: false,
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: KanjiGridCell(kanji: kanji),
        ),
      ),
    );

    expect(find.text('水'), findsOneWidget);
    expect(find.byIcon(Icons.lock_outline), findsOneWidget);
  });
}
