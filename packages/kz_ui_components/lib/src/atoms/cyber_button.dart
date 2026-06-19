import 'package:flutter/material.dart';
import 'package:kz_core/kz_core.dart';

/// ATOM: Botón Cyber-Zen con borde de acento y efecto hover.
class CyberButton extends StatefulWidget {
  const CyberButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.accent,
    this.isSmall = false,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final Color? accent;
  final bool isSmall;

  @override
  State<CyberButton> createState() => _CyberButtonState();
}

class _CyberButtonState extends State<CyberButton> {
  bool _pressed = false;

  Color get _accent => widget.accent ?? CyberTheme.defaultAccent;

  @override
  Widget build(BuildContext context) {
    final padding = widget.isSmall
        ? const EdgeInsets.symmetric(horizontal: 12, vertical: 6)
        : const EdgeInsets.symmetric(horizontal: 20, vertical: 10);
    final fontSize = widget.isSmall ? 11.0 : 13.0;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        padding: padding,
        decoration: BoxDecoration(
          color: _pressed ? _accent.withValues(alpha: 0.12) : Colors.transparent,
          border: Border.all(
            color: _accent.withValues(alpha: _pressed ? 1.0 : 0.5),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.icon != null) ...[
              Icon(widget.icon, color: _accent, size: fontSize + 2),
              const SizedBox(width: 6),
            ],
            Text(
              widget.label.toUpperCase(),
              style: TextStyle(
                color: _accent,
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
                fontFamily: 'Courier',
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
