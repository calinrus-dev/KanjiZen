import 'package:flutter/material.dart';

/// Modelo de datos para una tecla Flick.
class FlickKeyData {
  final String central;
  final String? up;
  final String? down;
  final String? left;
  final String? right;
  final bool isToggle;

  const FlickKeyData({
    required this.central,
    this.up,
    this.down,
    this.left,
    this.right,
    this.isToggle = false,
  });
}

/// Teclado virtual estilo Flick japonés (12-key, 4×3).
/// Emite caracteres hiragana/katakana vía [onCharacterSelected].
/// La tecla 変換 emite eventos vía [onToggleKana].
///
/// Cada tecla detecta tap (dirección 0 = kana central) y swipe
/// (up / down / left / right) con threshold de 20 px.
class VirtualFlickKeyboard extends StatefulWidget {
  const VirtualFlickKeyboard({
    super.key,
    required this.onCharacterSelected,
    this.onToggleKana,
    this.accentColor,
  });

  final ValueChanged<String> onCharacterSelected;
  final VoidCallback? onToggleKana;
  final Color? accentColor;

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
    FlickKeyData(central: '変換', isToggle: true),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const crossCount = 4;
        final keyWidth = constraints.maxWidth / crossCount;
        final keyHeight = constraints.hasBoundedHeight
            ? constraints.maxHeight / 3
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
              onToggleKana: widget.onToggleKana,
              accentColor: widget.accentColor,
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
    this.onToggleKana,
    this.accentColor,
  });

  final FlickKeyData data;
  final ValueChanged<String> onCharacterSelected;
  final VoidCallback? onToggleKana;
  final Color? accentColor;

  @override
  State<_FlickKey> createState() => _FlickKeyState();
}

class _FlickKeyState extends State<_FlickKey> {
  Offset _startOffset = Offset.zero;
  Offset _currentOffset = Offset.zero;
  bool _isPressed = false;

  String? _getCharacterFromSwipe() {
    final delta = _currentOffset - _startOffset;
    const threshold = 20.0;

    if (delta.dx.abs() < threshold && delta.dy.abs() < threshold) {
      return widget.data.isToggle ? null : widget.data.central;
    }

    if (delta.dx.abs() > delta.dy.abs()) {
      // Horizontal: right > 0, left < 0
      return delta.dx > 0 ? widget.data.right : widget.data.left;
    } else {
      // Vertical: down > 0, up < 0
      return delta.dy > 0 ? widget.data.down : widget.data.up;
    }
  }

  void _handleEnd() {
    setState(() => _isPressed = false);
    if (widget.data.isToggle) {
      widget.onToggleKana?.call();
      return;
    }
    final char = _getCharacterFromSwipe();
    if (char != null && char.isNotEmpty) {
      widget.onCharacterSelected(char);
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.accentColor ?? Colors.cyanAccent;

    return GestureDetector(
      onPanDown: (details) {
        setState(() {
          _isPressed = true;
          _startOffset = details.localPosition;
          _currentOffset = details.localPosition;
        });
      },
      onPanUpdate: (details) {
        setState(() => _currentOffset = details.localPosition);
      },
      onPanEnd: (_) => _handleEnd(),
      onPanCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        decoration: BoxDecoration(
          color: _isPressed
              ? accent.withValues(alpha: 0.25)
              : accent.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _isPressed ? accent : accent.withValues(alpha: 0.3),
            width: _isPressed ? 1.5 : 1.0,
          ),
        ),
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            widget.data.central,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: widget.data.isToggle ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
