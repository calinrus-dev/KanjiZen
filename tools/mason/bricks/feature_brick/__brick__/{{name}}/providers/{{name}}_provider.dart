import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/{{name}}_state.dart';

part '{{name}}_provider.g.dart';

/// Provider del feature {{name}}.
/// Generado por feature_brick — implementar lógica de negocio.
@riverpod
class {{name.pascalCase()}}Notifier extends _${{name.pascalCase()}}Notifier {
  @override
  {{name.pascalCase()}}State build() => const {{name.pascalCase()}}State();
}
