import 'package:flutter/material.dart';

/// Modelo de datos para una tecla Flick.
class FlickKeyData {
  final String central;
  final String? up;
  final String? down;
  final String? left;
  final String? right;
  final bool isToggle;
  final bool isBackspace;

  const FlickKeyData({
    required this.central,
    this.up,
    this.down,
    this.left,
    this.right,
    this.isToggle = false,
    this.isBackspace = false,
  });
}

/// Teclado virtual estilo Flick japonés.
///
/// Emite caracteres hiragana/katakana vía [onCharacterSelected], borra vía
/// [onBackspace] y alterna kana vía [onToggleKana].
///
/// El layout es adaptativo: usa 4 columnas en portrait y hasta 8 en landscape o
/// tablets, escalando el threshold de swipe y la tipografía proporcionalmente.
class VirtualFlickKeyboard extends StatefulWidget {
  const VirtualFlickKeyboard({
    super.key,
    required this.onCharacterSelected,
    this.onBackspace,
    this.onToggleKana,
    this.accentColor,
    this.enabled = true,
  });

  final ValueChanged<String> onCharacterSelected;
  final VoidCallback? onBackspace;
  final VoidCallback? onToggleKana;
  final Color? accentColor;
  final bool enabled;

  @override
  State<VirtualFlickKeyboard> createState() => _VirtualFlickKeyboardState();
}

class _VirtualFlickKeyboardState extends State<VirtualFlickKeyboard> {
  static const List<FlickKeyData> _keys = [
    FlickKeyData(central: 'あ', up: 'い', right: 'う', down: 'え', left: 'お'),
    FlickKeyData(central: 'か', up: 'き', right: 'く', down: 'け', left: 'こ'),
    FlickKeyData(central: 'さ', up: 'し', right: 'す', down: 'せ', left: 'そ'),
    FlickKeyData(central: 'た', up: 'ち', right: 'つ', down: 'て', left: 'と'),
    FlickKeyData(central: 'な', up: 'に', right: 'ぬ', down: 'ね', left: 'の'),
    FlickKeyData(central: 'は', up: 'ひ', right: 'ふ', down: 'へ', left: 'ほ'),
    FlickKeyData(central: 'ま', up: 'み', right: 'む', down: 'め', left: 'も'),
    FlickKeyData(central: 'や', up: 'ゆ', right: 'よ', down: 'ー', left: 'ー'),
    FlickKeyData(central: 'ら', up: 'り', right: 'る', down: 'れ', left: 'ろ'),
    FlickKeyData(central: 'わ', up: 'を', right: 'ん', down: 'ー', left: 'ー'),
    FlickKeyData(central: '0', up: '1', right: '2', down: '3', left: '4'),
    FlickKeyData(central: '⌫', isBackspace: true),
    FlickKeyData(central: '変換', isToggle: true),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = MediaQuery.of(context).size;
        final isLandscape = size.width > size.height;
        final crossCount = isLandscape
            ? (constraints.maxWidth / 72).clamp(6, 10).toInt()
            : 4;
        final keyWidth = constraints.maxWidth / crossCount;
        final keyHeight = constraints.hasBoundedHeight
            ? constraints.maxHeight / ((constraints.maxHeight / keyWidth).clamp(3.0, 5.0))
            : keyWidth * 1.15;
        final aspect = keyWidth / keyHeight;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossCount,
            childAspectRatio: aspect,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
          ),
          itemCount: _keys.length,
          itemBuilder: (context, index) {
            return _FlickKey(
              data: _keys[index],
              onCharacterSelected: widget.onCharacterSelected,
              onBackspace: widget.onBackspace,
              onToggleKana: widget.onToggleKana,
              accentColor: widget.accentColor,
              enabled: widget.enabled,
            );
          },
        );
      },
    );
  }
}

class _FlickKey extends StatefulWidget {
  const _FlickKey({
    required this.data,
    required this.onCharacterSelected,
    this.onBackspace,
    this.onToggleKana,
    this.accentColor,
    required this.enabled,
  });

  final FlickKeyData data;
  final ValueChanged<String> onCharacterSelected;
  final VoidCallback? onBackspace;
  final VoidCallback? onToggleKana;
  final Color? accentColor;
  final bool enabled;

  @override
  State<_FlickKey> createState() => _FlickKeyState();
}

class _FlickKeyState extends State<_FlickKey> {
  Offset _startOffset = Offset.zero;
  Offset _currentOffset = Offset.zero;
  bool _isPressed = false;

  String? _getCharacterFromSwipe(double threshold) {
    final delta = _currentOffset - _startOffset;

    if (delta.dx.abs() < threshold && delta.dy.abs() < threshold) {
      if (widget.data.isToggle || widget.data.isBackspace) return null;
      return widget.data.central;
    }

    if (delta.dx.abs() > delta.dy.abs()) {
      return delta.dx > 0 ? widget.data.right : widget.data.left;
    } else {
      return delta.dy > 0 ? widget.data.down : widget.data.up;
    }
  }

  void _handleEnd(double threshold) {
    setState(() => _isPressed = false);
    if (!widget.enabled) return;

    if (widget.data.isToggle) {
      widget.onToggleKana?.call();
      return;
    }
    if (widget.data.isBackspace) {
      widget.onBackspace?.call();
      return;
    }

    final char = _getCharacterFromSwipe(threshold);
    if (char != null && char.isNotEmpty) {
      widget.onCharacterSelected(char);
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.accentColor ?? Colors.cyanAccent;

    return LayoutBuilder(
      builder: (context, constraints) {
        final threshold = (constraints.maxWidth * 0.25).clamp(12.0, 32.0);
        final fontSize = (constraints.maxWidth * 0.35).clamp(14.0, 28.0);
        final disabledOpacity = widget.enabled ? 1.0 : 0.3;

        return GestureDetector(
          onPanDown: widget.enabled
              ? (details) {
                  setState(() {
                    _isPressed = true;
                    _startOffset = details.localPosition;
                    _currentOffset = details.localPosition;
                  });
                }
              : null,
          onPanUpdate: widget.enabled
              ? (details) {
                  setState(() => _currentOffset = details.localPosition);
                }
              : null,
          onPanEnd: (_) => _handleEnd(threshold),
          onPanCancel: () => setState(() => _isPressed = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 80),
            decoration: BoxDecoration(
              color: _isPressed
                  ? accent.withValues(alpha: 0.25)
                  : accent.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _isPressed
                    ? accent
                    : accent.withValues(alpha: widget.enabled ? 0.3 : 0.1),
                width: _isPressed ? 1.5 : 1.0,
              ),
            ),
            alignment: Alignment.center,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                widget.data.central,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: disabledOpacity),
                  fontSize: fontSize,
                  fontWeight: widget.data.isToggle || widget.data.isBackspace
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
