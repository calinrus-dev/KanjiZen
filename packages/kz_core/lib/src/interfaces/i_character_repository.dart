/// Contrato del repositorio de caracteres (Kana + Kanji).
/// Implementado en kz_data. Consumido por kz_domain y kanjizen_app vía DI.
/// Tipado con dynamic para evitar dependencia de Isar en la interfaz.
abstract interface class ICharacterRepository {
  Future<List<dynamic>> getAllKanas();
  Future<dynamic> getKanaByCharacter(String character);
  Future<void> updateKanaProgress(
    String character,
    List<int> historyBlob,
    double hitRate,
    int averageMs,
  );
  Future<bool> isSeeded();
  Future<void> seedDatabase();
}
