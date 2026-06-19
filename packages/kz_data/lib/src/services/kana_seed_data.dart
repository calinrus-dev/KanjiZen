/// Datos estáticos de Kana para seeding inicial de la base de datos Isar.
/// Estructura: [character, romaji, isKatakana, linkedChar, isDakuten]
class KanaSeedData {
  static const List<KanaSeed> all = [
    // ═══════════════════════════════════════════════════════════════
    // HIRAGANA BASE (46)
    // ═══════════════════════════════════════════════════════════════
    // Vocales
    KanaSeed('あ', 'a', false, 'ア', false),
    KanaSeed('い', 'i', false, 'イ', false),
    KanaSeed('う', 'u', false, 'ウ', false),
    KanaSeed('え', 'e', false, 'エ', false),
    KanaSeed('お', 'o', false, 'オ', false),
    // Ka
    KanaSeed('か', 'ka', false, 'カ', false),
    KanaSeed('き', 'ki', false, 'キ', false),
    KanaSeed('く', 'ku', false, 'ク', false),
    KanaSeed('け', 'ke', false, 'ケ', false),
    KanaSeed('こ', 'ko', false, 'コ', false),
    // Sa
    KanaSeed('さ', 'sa', false, 'サ', false),
    KanaSeed('し', 'shi', false, 'シ', false),
    KanaSeed('す', 'su', false, 'ス', false),
    KanaSeed('せ', 'se', false, 'セ', false),
    KanaSeed('そ', 'so', false, 'ソ', false),
    // Ta
    KanaSeed('た', 'ta', false, 'タ', false),
    KanaSeed('ち', 'chi', false, 'チ', false),
    KanaSeed('つ', 'tsu', false, 'ツ', false),
    KanaSeed('て', 'te', false, 'テ', false),
    KanaSeed('と', 'to', false, 'ト', false),
    // Na
    KanaSeed('な', 'na', false, 'ナ', false),
    KanaSeed('に', 'ni', false, 'ニ', false),
    KanaSeed('ぬ', 'nu', false, 'ヌ', false),
    KanaSeed('ね', 'ne', false, 'ネ', false),
    KanaSeed('の', 'no', false, 'ノ', false),
    // Ha
    KanaSeed('は', 'ha', false, 'ハ', false),
    KanaSeed('ひ', 'hi', false, 'ヒ', false),
    KanaSeed('ふ', 'fu', false, 'フ', false),
    KanaSeed('へ', 'he', false, 'ヘ', false),
    KanaSeed('ほ', 'ho', false, 'ホ', false),
    // Ma
    KanaSeed('ま', 'ma', false, 'マ', false),
    KanaSeed('み', 'mi', false, 'ミ', false),
    KanaSeed('む', 'mu', false, 'ム', false),
    KanaSeed('め', 'me', false, 'メ', false),
    KanaSeed('も', 'mo', false, 'モ', false),
    // Ya
    KanaSeed('や', 'ya', false, 'ヤ', false),
    KanaSeed('ゆ', 'yu', false, 'ユ', false),
    KanaSeed('よ', 'yo', false, 'ヨ', false),
    // Ra
    KanaSeed('ら', 'ra', false, 'ラ', false),
    KanaSeed('り', 'ri', false, 'リ', false),
    KanaSeed('る', 'ru', false, 'ル', false),
    KanaSeed('れ', 're', false, 'レ', false),
    KanaSeed('ろ', 'ro', false, 'ロ', false),
    // Wa + N
    KanaSeed('わ', 'wa', false, 'ワ', false),
    KanaSeed('を', 'wo', false, 'ヲ', false),
    KanaSeed('ん', 'n', false, 'ン', false),

    // ═══════════════════════════════════════════════════════════════
    // HIRAGANA DAKUTEN / HANDAKUTEN (25)
    // ═══════════════════════════════════════════════════════════════
    // Ga
    KanaSeed('が', 'ga', false, 'ガ', true),
    KanaSeed('ぎ', 'gi', false, 'ギ', true),
    KanaSeed('ぐ', 'gu', false, 'グ', true),
    KanaSeed('げ', 'ge', false, 'ゲ', true),
    KanaSeed('ご', 'go', false, 'ゴ', true),
    // Za
    KanaSeed('ざ', 'za', false, 'ザ', true),
    KanaSeed('じ', 'ji', false, 'ジ', true),
    KanaSeed('ず', 'zu', false, 'ズ', true),
    KanaSeed('ぜ', 'ze', false, 'ゼ', true),
    KanaSeed('ぞ', 'zo', false, 'ゾ', true),
    // Da
    KanaSeed('だ', 'da', false, 'ダ', true),
    KanaSeed('で', 'de', false, 'デ', true),
    KanaSeed('ど', 'do', false, 'ド', true),
    // Ba
    KanaSeed('ば', 'ba', false, 'バ', true),
    KanaSeed('び', 'bi', false, 'ビ', true),
    KanaSeed('ぶ', 'bu', false, 'ブ', true),
    KanaSeed('べ', 'be', false, 'ベ', true),
    KanaSeed('ぼ', 'bo', false, 'ボ', true),
    // Pa (handakuten)
    KanaSeed('ぱ', 'pa', false, 'パ', true),
    KanaSeed('ぴ', 'pi', false, 'ピ', true),
    KanaSeed('ぷ', 'pu', false, 'プ', true),
    KanaSeed('ぺ', 'pe', false, 'ペ', true),
    KanaSeed('ぽ', 'po', false, 'ポ', true),

    // ═══════════════════════════════════════════════════════════════
    // KATAKANA BASE (46)
    // ═══════════════════════════════════════════════════════════════
    KanaSeed('ア', 'a', true, 'あ', false),
    KanaSeed('イ', 'i', true, 'い', false),
    KanaSeed('ウ', 'u', true, 'う', false),
    KanaSeed('エ', 'e', true, 'え', false),
    KanaSeed('オ', 'o', true, 'お', false),
    KanaSeed('カ', 'ka', true, 'か', false),
    KanaSeed('キ', 'ki', true, 'き', false),
    KanaSeed('ク', 'ku', true, 'く', false),
    KanaSeed('ケ', 'ke', true, 'け', false),
    KanaSeed('コ', 'ko', true, 'こ', false),
    KanaSeed('サ', 'sa', true, 'さ', false),
    KanaSeed('シ', 'shi', true, 'し', false),
    KanaSeed('ス', 'su', true, 'す', false),
    KanaSeed('セ', 'se', true, 'せ', false),
    KanaSeed('ソ', 'so', true, 'そ', false),
    KanaSeed('タ', 'ta', true, 'た', false),
    KanaSeed('チ', 'chi', true, 'ち', false),
    KanaSeed('ツ', 'tsu', true, 'つ', false),
    KanaSeed('テ', 'te', true, 'て', false),
    KanaSeed('ト', 'to', true, 'と', false),
    KanaSeed('ナ', 'na', true, 'な', false),
    KanaSeed('ニ', 'ni', true, 'に', false),
    KanaSeed('ヌ', 'nu', true, 'ぬ', false),
    KanaSeed('ネ', 'ne', true, 'ね', false),
    KanaSeed('ノ', 'no', true, 'の', false),
    KanaSeed('ハ', 'ha', true, 'は', false),
    KanaSeed('ヒ', 'hi', true, 'ひ', false),
    KanaSeed('フ', 'fu', true, 'ふ', false),
    KanaSeed('ヘ', 'he', true, 'へ', false),
    KanaSeed('ホ', 'ho', true, 'ほ', false),
    KanaSeed('マ', 'ma', true, 'ま', false),
    KanaSeed('ミ', 'mi', true, 'み', false),
    KanaSeed('ム', 'mu', true, 'む', false),
    KanaSeed('メ', 'me', true, 'め', false),
    KanaSeed('モ', 'mo', true, 'も', false),
    KanaSeed('ヤ', 'ya', true, 'や', false),
    KanaSeed('ユ', 'yu', true, 'ゆ', false),
    KanaSeed('ヨ', 'yo', true, 'よ', false),
    KanaSeed('ラ', 'ra', true, 'ら', false),
    KanaSeed('リ', 'ri', true, 'り', false),
    KanaSeed('ル', 'ru', true, 'る', false),
    KanaSeed('レ', 're', true, 'れ', false),
    KanaSeed('ロ', 'ro', true, 'ろ', false),
    KanaSeed('ワ', 'wa', true, 'わ', false),
    KanaSeed('ヲ', 'wo', true, 'を', false),
    KanaSeed('ン', 'n', true, 'ん', false),

    // ═══════════════════════════════════════════════════════════════
    // KATAKANA DAKUTEN / HANDAKUTEN (23)
    // ═══════════════════════════════════════════════════════════════
    KanaSeed('ガ', 'ga', true, 'が', true),
    KanaSeed('ギ', 'gi', true, 'ぎ', true),
    KanaSeed('グ', 'gu', true, 'ぐ', true),
    KanaSeed('ゲ', 'ge', true, 'げ', true),
    KanaSeed('ゴ', 'go', true, 'ご', true),
    KanaSeed('ザ', 'za', true, 'ざ', true),
    KanaSeed('ジ', 'ji', true, 'じ', true),
    KanaSeed('ズ', 'zu', true, 'ず', true),
    KanaSeed('ゼ', 'ze', true, 'ぜ', true),
    KanaSeed('ゾ', 'zo', true, 'ぞ', true),
    KanaSeed('ダ', 'da', true, 'だ', true),
    KanaSeed('デ', 'de', true, 'で', true),
    KanaSeed('ド', 'do', true, 'ど', true),
    KanaSeed('バ', 'ba', true, 'ば', true),
    KanaSeed('ビ', 'bi', true, 'び', true),
    KanaSeed('ブ', 'bu', true, 'ぶ', true),
    KanaSeed('ベ', 'be', true, 'べ', true),
    KanaSeed('ボ', 'bo', true, 'ぼ', true),
    KanaSeed('パ', 'pa', true, 'ぱ', true),
    KanaSeed('ピ', 'pi', true, 'ぴ', true),
    KanaSeed('プ', 'pu', true, 'ぷ', true),
    KanaSeed('ペ', 'pe', true, 'ぺ', true),
    KanaSeed('ポ', 'po', true, 'ぽ', true),
  ];
}

class KanaSeed {
  const KanaSeed(
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
