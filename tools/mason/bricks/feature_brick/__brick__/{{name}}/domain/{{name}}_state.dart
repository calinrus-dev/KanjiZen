import 'package:freezed_annotation/freezed_annotation.dart';

part '{{name}}_state.freezed.dart';

/// Estado inmutable del feature {{name}}.
/// Generado por feature_brick.
@freezed
class {{name.pascalCase()}}State with _${{name.pascalCase()}}State {
  const factory {{name.pascalCase()}}State() = _{{name.pascalCase()}}State;
}
