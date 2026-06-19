import 'package:flutter/material.dart';
import 'package:kz_core/kz_core.dart';
import 'package:kz_domain/kz_domain.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// MOLECULE: Campo de texto crítico Cyber-Zen.
/// Solo borde inferior. shakeX en error vía flutter_animate. Cero AnimationController manual.
class RayitaInput extends StatefulWidget {
  const RayitaInput({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.inputState,
    this.hint = 'romaji...',
    this.accentColor,
    this.focusNode,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final InputState inputState;
  final String hint;
  final Color? accentColor;
  final FocusNode? focusNode;

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
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.accentColor ?? CyberTheme.defaultAccent;

    final Widget field = TextField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      onChanged: widget.onChanged,
      autofocus: true,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: CyberTheme.textNeutral,
        fontSize: 22,
        fontFamily: 'Courier',
        fontWeight: FontWeight.w300,
        letterSpacing: 4,
      ),
      cursorColor: accent,
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: TextStyle(
          color: CyberTheme.textNeutral.withValues(alpha: 0.2),
          fontSize: 14,
          fontFamily: 'Courier',
          letterSpacing: 2,
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

    return field.animate(target: widget.inputState == InputState.error ? 1 : 0).shakeX(duration: const Duration(milliseconds: 150));
  }
}
