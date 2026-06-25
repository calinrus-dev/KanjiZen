import 'package:flutter/material.dart';

/// Consola de chat multilínea con acciones TTS, Attachment y Send.
/// Reutilizable: no depende de providers específicos.
/// Usa [LayoutBuilder] para alternar entre layout Row y Column
/// según el ancho disponible, evitando overflow en pantallas estrechas.
class ChatConsoleInput extends StatefulWidget {
  const ChatConsoleInput({
    super.key,
    required this.onSend,
    this.onTtsRequested,
    this.onAttachmentRequested,
    this.accentColor,
  });

  final ValueChanged<String> onSend;
  final VoidCallback? onTtsRequested;
  final VoidCallback? onAttachmentRequested;
  final Color? accentColor;

  @override
  State<ChatConsoleInput> createState() => _ChatConsoleInputState();
}

class _ChatConsoleInputState extends State<ChatConsoleInput> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      widget.onSend(text);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 360;
        final accent = widget.accentColor ?? Colors.cyanAccent;

        final textField = TextField(
          controller: _controller,
          minLines: 1,
          maxLines: 4,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: 'Courier',
          ),
          decoration: InputDecoration(
            hintText: 'Mensaje...',
            hintStyle: TextStyle(
              color: Colors.white.withValues(alpha: 0.3),
              fontFamily: 'Courier',
              fontSize: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: accent.withValues(alpha: 0.4),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: accent.withValues(alpha: 0.4),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: accent.withValues(alpha: 0.7),
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            isDense: true,
          ),
        );

        final buttons = <Widget>[
          if (widget.onTtsRequested != null)
            IconButton(
              icon: const Icon(Icons.volume_up, color: Colors.white70),
              onPressed: widget.onTtsRequested,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            ),
          if (widget.onAttachmentRequested != null)
            IconButton(
              icon: const Icon(Icons.attach_file, color: Colors.white70),
              onPressed: widget.onAttachmentRequested,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            ),
          IconButton(
            icon: Icon(Icons.send, color: accent),
            onPressed: _handleSend,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
        ];

        if (isCompact) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              textField,
              const SizedBox(height: 8),
              Wrap(
                alignment: WrapAlignment.end,
                spacing: 4,
                runSpacing: 4,
                children: buttons,
              ),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(child: textField),
            const SizedBox(width: 8),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              alignment: WrapAlignment.end,
              children: buttons,
            ),
          ],
        );
      },
    );
  }
}
