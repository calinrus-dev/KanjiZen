import 'package:flutter/material.dart';

/// Screen generada por feature_brick.
/// TODO: Implementar lógica de presentación del feature {{name}}.
class {{name.pascalCase()}}Screen extends StatelessWidget {
  const {{name.pascalCase()}}Screen({super.key});

  static const routePath = '/{{name}}';

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('{{name.titleCase()}} Screen'),
      ),
    );
  }
}
