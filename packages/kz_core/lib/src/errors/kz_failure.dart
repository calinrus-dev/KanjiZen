/// Errores del dominio KanjiZen — sealed class para exhaustividad en switch.
sealed class KzFailure {
  const KzFailure(this.message);
  final String message;
}

/// Error de inicialización de la base de datos Isar.
final class DatabaseInitFailure extends KzFailure {
  const DatabaseInitFailure(super.message);
}

/// Error al parsear KANJIDIC2 o KanjiVG durante el seeding.
final class ParseFailure extends KzFailure {
  const ParseFailure(super.message);
}

/// Error del motor TTS.
final class TtsFailure extends KzFailure {
  const TtsFailure(super.message);
}

/// Error genérico del repositorio.
final class RepositoryFailure extends KzFailure {
  const RepositoryFailure(super.message);
}
