/// Datos estáticos de Kana para seeding inicial de la base de datos Isar.
/// Estructura: [character, romaji, isKatakana, linkedChar, isDakuten]
class KanaSeedData {
  static const List<_KanaSeed> all = [
    // ═══════════════════════════════════════════════════════════════
    // HIRAGANA BASE (46)
    // ═══════════════════════════════════════════════════════════════
    // Vocales
    _KanaSeed('あ', 'a', false, 'ア', false),
    _KanaSeed('い', 'i', false, 'イ', false),
    _KanaSeed('う', 'u', false, 'ウ', false),
    _KanaSeed('え', 'e', false, 'エ', false),
    _KanaSeed('お', 'o', false, 'オ', false),
    // Ka
    _KanaSeed('か', 'ka', false, 'カ', false),
    _KanaSeed('き', 'ki', false, 'キ', false),
    _KanaSeed('く', 'ku', false, 'ク', false),
    _KanaSeed('け', 'ke', false, 'ケ', false),
    _KanaSeed('こ', 'ko', false, 'コ', false),
    // Sa
    _KanaSeed('さ', 'sa', false, 'サ', false),
    _KanaSeed('し', 'shi', false, 'シ', false),
    _KanaSeed('す', 'su', false, 'ス', false),
    _KanaSeed('せ', 'se', false, 'セ', false),
    _KanaSeed('そ', 'so', false, 'ソ', false),
    // Ta
    _KanaSeed('た', 'ta', false, 'タ', false),
    _KanaSeed('ち', 'chi', false, 'チ', false),
    _KanaSeed('つ', 'tsu', false, 'ツ', false),
    _KanaSeed('て', 'te', false, 'テ', false),
    _KanaSeed('と', 'to', false, 'ト', false),
    // Na
    _KanaSeed('な', 'na', false, 'ナ', false),
    _KanaSeed('に', 'ni', false, 'ニ', false),
    _KanaSeed('ぬ', 'nu', false, 'ヌ', false),
    _KanaSeed('ね', 'ne', false, 'ネ', false),
    _KanaSeed('の', 'no', false, 'ノ', false),
    // Ha
    _KanaSeed('は', 'ha', false, 'ハ', false),
    _KanaSeed('ひ', 'hi', false, 'ヒ', false),
    _KanaSeed('ふ', 'fu', false, 'フ', false),
    _KanaSeed('へ', 'he', false, 'ヘ', false),
    _KanaSeed('ほ', 'ho', false, 'ホ', false),
    // Ma
    _KanaSeed('ま', 'ma', false, 'マ', false),
    _KanaSeed('み', 'mi', false, 'ミ', false),
    _KanaSeed('む', 'mu', false, 'ム', false),
    _KanaSeed('め', 'me', false, 'メ', false),
    _KanaSeed('も', 'mo', false, 'モ', false),
    // Ya
    _KanaSeed('や', 'ya', false, 'ヤ', false),
    _KanaSeed('ゆ', 'yu', false, 'ユ', false),
    _KanaSeed('よ', 'yo', false, 'ヨ', false),
    // Ra
    _KanaSeed('ら', 'ra', false, 'ラ', false),
    _KanaSeed('り', 'ri', false, 'リ', false),
    _KanaSeed('る', 'ru', false, 'ル', false),
    _KanaSeed('れ', 're', false, 'レ', false),
    _KanaSeed('ろ', 'ro', false, 'ロ', false),
    // Wa + N
    _KanaSeed('わ', 'wa', false, 'ワ', false),
    _KanaSeed('を', 'wo', false, 'ヲ', false),
    _KanaSeed('ん', 'n', false, 'ン', false),

    // ═══════════════════════════════════════════════════════════════
    // HIRAGANA DAKUTEN / HANDAKUTEN (25)
    // ═══════════════════════════════════════════════════════════════
    // Ga
    _KanaSeed('が', 'ga', false, 'ガ', true),
    _KanaSeed('ぎ', 'gi', false, 'ギ', true),
    _KanaSeed('ぐ', 'gu', false, 'グ', true),
    _KanaSeed('げ', 'ge', false, 'ゲ', true),
    _KanaSeed('ご', 'go', false, 'ゴ', true),
    // Za
    _KanaSeed('ざ', 'za', false, 'ザ', true),
    _KanaSeed('じ', 'ji', false, 'ジ', true),
    _KanaSeed('ず', 'zu', false, 'ズ', true),
    _KanaSeed('ぜ', 'ze', false, 'ゼ', true),
    _KanaSeed('ぞ', 'zo', false, 'ゾ', true),
    // Da
    _KanaSeed('だ', 'da', false, 'ダ', true),
    _KanaSeed('で', 'de', false, 'デ', true),
    _KanaSeed('ど', 'do', false, 'ド', true),
    // Ba
    _KanaSeed('ば', 'ba', false, 'バ', true),
    _KanaSeed('び', 'bi', false, 'ビ', true),
    _KanaSeed('ぶ', 'bu', false, 'ブ', true),
    _KanaSeed('べ', 'be', false, 'ベ', true),
    _KanaSeed('ぼ', 'bo', false, 'ボ', true),
    // Pa (handakuten)
    _KanaSeed('ぱ', 'pa', false, 'パ', true),
    _KanaSeed('ぴ', 'pi', false, 'ピ', true),
    _KanaSeed('ぷ', 'pu', false, 'プ', true),
    _KanaSeed('ぺ', 'pe', false, 'ペ', true),
    _KanaSeed('ぽ', 'po', false, 'ポ', true),

    // ═══════════════════════════════════════════════════════════════
    // KATAKANA BASE (46)
    // ═══════════════════════════════════════════════════════════════
    _KanaSeed('ア', 'a', true, 'あ', false),
    _KanaSeed('イ', 'i', true, 'い', false),
    _KanaSeed('ウ', 'u', true, 'う', false),
    _KanaSeed('エ', 'e', true, 'え', false),
    _KanaSeed('オ', 'o', true, 'お', false),
    _KanaSeed('カ', 'ka', true, 'か', false),
    _KanaSeed('キ', 'ki', true, 'き', false),
    _KanaSeed('ク', 'ku', true, 'く', false),
    _KanaSeed('ケ', 'ke', true, 'け', false),
    _KanaSeed('コ', 'ko', true, 'こ', false),
    _KanaSeed('サ', 'sa', true, 'さ', false),
    _KanaSeed('シ', 'shi', true, 'し', false),
    _KanaSeed('ス', 'su', true, 'す', false),
    _KanaSeed('セ', 'se', true, 'せ', false),
    _KanaSeed('ソ', 'so', true, 'そ', false),
    _KanaSeed('タ', 'ta', true, 'た', false),
    _KanaSeed('チ', 'chi', true, 'ち', false),
    _KanaSeed('ツ', 'tsu', true, 'つ', false),
    _KanaSeed('テ', 'te', true, 'て', false),
    _KanaSeed('ト', 'to', true, 'と', false),
    _KanaSeed('ナ', 'na', true, 'な', false),
    _KanaSeed('ニ', 'ni', true, 'に', false),
    _KanaSeed('ヌ', 'nu', true, 'ぬ', false),
    _KanaSeed('ネ', 'ne', true, 'ね', false),
    _KanaSeed('ノ', 'no', true, 'の', false),
    _KanaSeed('ハ', 'ha', true, 'は', false),
    _KanaSeed('ヒ', 'hi', true, 'ひ', false),
    _KanaSeed('フ', 'fu', true, 'ふ', false),
    _KanaSeed('ヘ', 'he', true, 'へ', false),
    _KanaSeed('ホ', 'ho', true, 'ほ', false),
    _KanaSeed('マ', 'ma', true, 'ま', false),
    _KanaSeed('ミ', 'mi', true, 'み', false),
    _KanaSeed('ム', 'mu', true, 'む', false),
    _KanaSeed('メ', 'me', true, 'め', false),
    _KanaSeed('モ', 'mo', true, 'も', false),
    _KanaSeed('ヤ', 'ya', true, 'や', false),
    _KanaSeed('ユ', 'yu', true, 'ゆ', false),
    _KanaSeed('ヨ', 'yo', true, 'よ', false),
    _KanaSeed('ラ', 'ra', true, 'ら', false),
    _KanaSeed('リ', 'ri', true, 'り', false),
    _KanaSeed('ル', 'ru', true, 'る', false),
    _KanaSeed('レ', 're', true, 'れ', false),
    _KanaSeed('ロ', 'ro', true, 'ろ', false),
    _KanaSeed('ワ', 'wa', true, 'わ', false),
    _KanaSeed('ヲ', 'wo', true, 'を', false),
    _KanaSeed('ン', 'n', true, 'ん', false),

    // ═══════════════════════════════════════════════════════════════
    // KATAKANA DAKUTEN / HANDAKUTEN (23)
    // ═══════════════════════════════════════════════════════════════
    _KanaSeed('ガ', 'ga', true, 'が', true),
    _KanaSeed('ギ', 'gi', true, 'ぎ', true),
    _KanaSeed('グ', 'gu', true, 'ぐ', true),
    _KanaSeed('ゲ', 'ge', true, 'げ', true),
    _KanaSeed('ゴ', 'go', true, 'ご', true),
    _KanaSeed('ザ', 'za', true, 'ざ', true),
    _KanaSeed('ジ', 'ji', true, 'じ', true),
    _KanaSeed('ズ', 'zu', true, 'ず', true),
    _KanaSeed('ゼ', 'ze', true, 'ぜ', true),
    _KanaSeed('ゾ', 'zo', true, 'ぞ', true),
    _KanaSeed('ダ', 'da', true, 'だ', true),
    _KanaSeed('デ', 'de', true, 'で', true),
    _KanaSeed('ド', 'do', true, 'ど', true),
    _KanaSeed('バ', 'ba', true, 'ば', true),
    _KanaSeed('ビ', 'bi', true, 'び', true),
    _KanaSeed('ブ', 'bu', true, 'ぶ', true),
    _KanaSeed('ベ', 'be', true, 'べ', true),
    _KanaSeed('ボ', 'bo', true, 'ぼ', true),
    _KanaSeed('パ', 'pa', true, 'ぱ', true),
    _KanaSeed('ピ', 'pi', true, 'ぴ', true),
    _KanaSeed('プ', 'pu', true, 'ぷ', true),
    _KanaSeed('ペ', 'pe', true, 'ぺ', true),
    _KanaSeed('ポ', 'po', true, 'ぽ', true),
  ];
}

class _KanaSeed {
  const _KanaSeed(
    this.character,
    this.romaji,
    this.isKatakana,
    this.linkedKanaCharacter,
    this.isDakutenOrHandakuten,
  );
  final String character;
  final String romaji;
  final bool isKatakana;
  final String linkedKanaCharacter;
  final bool isDakutenOrHandakuten;
}
