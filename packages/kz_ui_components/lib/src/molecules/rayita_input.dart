import 'package:flutter/material.dart';
import 'package:kz_core/kz_core.dart';
import 'package:kz_domain/kz_domain.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// MOLECULE: Campo de texto crítico Cyber-Zen.
/// Solo borde inferior. shakeX en error vía flutter_animate. Cero AnimationController manual.
/// Ahora responsive: usa [LayoutBuilder] para escalar fontSize y letterSpacing
/// según el ancho disponible, evitando overflow en pantallas estrechas.
class RayitaInput extends StatefulWidget {
  const RayitaInput({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.inputState,
    this.hint = 'romaji...',
    this.accentColor,
    this.focusNode,
    this.readOnly = false,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final InputState inputState;
  final String hint;
  final Color? accentColor;
  final FocusNode? focusNode;
  final bool readOnly;

  @override
  State<RayitaInput> createState() => _RayitaInputState();
}

class _RayitaInputState extends State<RayitaInput> {
  Color get _lineColor {
    final accent = widget.accentColor ?? CyberTheme.defaultAccent;
    return switch (widget.inputState) {
      InputState.neutral => CyberTheme.textNeutral.withValues(alpha: 0.3),
      InputState.progress => accent.withValues(alpha: 0.7),
      InputState.error => CyberTheme.errorRed,
      InputState.success => accent,
    };
  }

  @override
  void didUpdateWidget(RayitaInput old) {
    super.didUpdateWidget(old);
    if (widget.inputState != old.inputState) {
      if (widget.inputState == InputState.success ||
          widget.inputState == InputState.error) {
        widget.controller.clear();
        widget.focusNode?.requestFocus();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.accentColor ?? CyberTheme.defaultAccent;

    return LayoutBuilder(
      builder: (context, constraints) {
        final fontSize = (constraints.maxWidth / 18).clamp(14.0, 24.0);
        final hintSize = (constraints.maxWidth / 30).clamp(10.0, 16.0);
        final letterSpacing = (constraints.maxWidth / 60).clamp(1.0, 6.0);

        final field = TextField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          onChanged: widget.onChanged,
          readOnly: widget.readOnly,
          autofocus: true,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: CyberTheme.textNeutral,
            fontSize: fontSize,
            fontFamily: 'Courier',
            fontWeight: FontWeight.w300,
            letterSpacing: letterSpacing,
          ),
          cursorColor: accent,
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TextStyle(
              color: CyberTheme.textNeutral.withValues(alpha: 0.2),
              fontSize: hintSize,
              fontFamily: 'Courier',
              letterSpacing: letterSpacing * 0.5,
            ),
            border: InputBorder.none,
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: _lineColor, width: 1.5),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: _lineColor, width: 2),
            ),
            contentPadding: const EdgeInsets.only(bottom: 8),
          ),
        );

        return field
            .animate(target: widget.inputState == InputState.error ? 1 : 0)
            .shakeX(duration: const Duration(milliseconds: 150));
      },
    );
  }
}
