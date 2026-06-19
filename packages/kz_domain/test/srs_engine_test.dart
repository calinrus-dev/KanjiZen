import 'package:test/test.dart';
import 'package:kz_domain/kz_domain.dart';

void main() {
  group('TierCalculator Tests', () {
    test('calculate returns correct Tier', () {
      final tierD = TierCalculator.calculate(
        hitRate: 0.75,
        avgMs: 3000,
        isUnlocked: true,
      );
      expect(tierD, equals(KanaTier.d));

      final tierS = TierCalculator.calculate(
        hitRate: 0.99,
        avgMs: 400,
        isUnlocked: true,
      );
      expect(tierS, equals(KanaTier.s));
    });

    test('encodeAttempt matches structure', () {
      final encoded = TierCalculator.encodeAttempt(
        isCorrect: true,
        isDoubleStroke: false,
        responseMs: 450,
      );
      expect(encoded, equals(0x8000 | 450));
    });
  });

  group('SrsState Tests', () {
    test('SrsState holds values correctly', () {
      final kanas = [
        const KanaModel(
          character: 'あ',
          romaji: 'a',
          isKatakana: false,
          linkedKanaCharacter: '',
          isDakutenOrHandakuten: false,
          isUnlocked: true,
        ),
      ];
      final state = SrsState(
        pool: kanas,
        currentIndex: 0,
        streak: 5,
        totalErrors: 2,
        sessionStartMs: 1000,
      );

      expect(state.current?.character, equals('あ'));
      expect(state.streak, equals(5));
      expect(state.totalErrors, equals(2));
      expect(state.sessionStartMs, equals(1000));
    });
  });
}
