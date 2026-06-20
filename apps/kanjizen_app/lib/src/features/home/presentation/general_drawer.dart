import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kanjizen_app/src/providers/timeline_provider.dart';
import 'package:kanjizen_app/src/features/profile/presentation/profile_drawer.dart';

class GeneralDrawer extends ConsumerWidget {
  const GeneralDrawer({super.key, required this.accent});
  final Color accent;

  void _showRenameDialog(
    BuildContext context,
    WidgetRef ref,
    String sessionId,
    String currentName,
    Color accent,
  ) {
    final controller = TextEditingController(text: currentName);
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF05060A),
          title: Text(
            'RENOMBRAR SESIÓN',
            style: TextStyle(
              color: accent,
              fontFamily: 'Courier',
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: const TextStyle(color: Colors.white, fontFamily: 'Courier'),
            cursorColor: accent,
            decoration: InputDecoration(
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: accent.withValues(alpha: 0.3)),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: accent),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'CANCELAR',
                style: TextStyle(
                  color: Colors.white54,
                  fontFamily: 'Courier',
                  fontSize: 11,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                final text = controller.text.trim();
                if (text.isNotEmpty) {
                  ref
                      .read(timelineProvider.notifier)
                      .renameSession(sessionId, text);
                }
                Navigator.pop(ctx);
              },
              child: Text(
                'GUARDAR',
                style: TextStyle(
                  color: accent,
                  fontFamily: 'Courier',
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timelineState = ref.watch(timelineProvider);
    final history = timelineState.history;
    final activeId = timelineState.activeSessionId;

    // Separate pinned and unpinned sessions, sorting pinned ones to the top
    final sortedHistory = List<SessionHistoryItem>.from(history)
      ..sort((a, b) {
        if (a.isPinned && !b.isPinned) return -1;
        if (!a.isPinned && b.isPinned) return 1;
        return b.createdAt.compareTo(a.createdAt);
      });

    return Drawer(
      backgroundColor: const Color(0xFF05060A), // PURE OLED DARK
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // QuickActionsGroup
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ACCIONES RÁPIDAS',
                    style: TextStyle(
                      color: accent.withValues(alpha: 0.4),
                      fontFamily: 'Courier',
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildQuickActionBtn(
                    label: '[ NUEVA SESIÓN ]',
                    onTap: () {
                      Navigator.pop(context); // Close Drawer
                      ref.read(timelineProvider.notifier).createNewSession();
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildQuickActionBtn(
                    label: '[ INVENTARIO ]',
                    onTap: () {
                      Navigator.pop(context); // Close Drawer
                      context.push('/home/inventory');
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildQuickActionBtn(
                    label: '[ KANAS ]',
                    onTap: () {
                      Navigator.pop(context); // Close Drawer
                      context.push('/home/kanas');
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildQuickActionBtn(
                    label: '[ KANJIS ]',
                    onTap: () {
                      Navigator.pop(context); // Close Drawer
                      context.push('/home/kanjis');
                    },
                  ),
                ],
              ),
            ),

            const Divider(color: Colors.white10, height: 1),

            // SessionHistoryList Title
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'HISTORIAL DE SESIONES',
                style: TextStyle(
                  color: accent.withValues(alpha: 0.4),
                  fontFamily: 'Courier',
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),

            // SessionHistoryList (Scrollable)
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: sortedHistory.length,
                itemBuilder: (context, idx) {
                  final session = sortedHistory[idx];
                  final isActive = session.id == activeId;

                  return GestureDetector(
                    onTap: () {
                      // Switch active session
                      ref
                          .read(timelineProvider.notifier)
                          .selectSession(session.id);
                      Navigator.pop(context); // Close drawer
                    },
                    onLongPressStart: (details) {
                      final offset = details.globalPosition;
                      showMenu<String>(
                        context: context,
                        position: RelativeRect.fromLTRB(
                          offset.dx,
                          offset.dy,
                          offset.dx,
                          offset.dy,
                        ),
                        color: const Color(0xFF05060A),
                        items: [
                          PopupMenuItem(
                            value: 'pin',
                            child: Text(
                              session.isPinned ? 'Desfijar' : 'Fijar',
                              style: const TextStyle(
                                color: Colors.white,
                                fontFamily: 'Courier',
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'rename',
                            child: Text(
                              'Renombrar',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Courier',
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text(
                              'Eliminar',
                              style: TextStyle(
                                color: Colors.red,
                                fontFamily: 'Courier',
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ).then((action) {
                        if (action == 'pin') {
                          ref
                              .read(timelineProvider.notifier)
                              .pinSession(session.id);
                        } else if (action == 'rename') {
                          if (context.mounted) {
                            _showRenameDialog(
                              context,
                              ref,
                              session.id,
                              session.name,
                              accent,
                            );
                          }
                        } else if (action == 'delete') {
                          ref
                              .read(timelineProvider.notifier)
                              .deleteSession(session.id);
                        }
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isActive
                              ? accent.withValues(alpha: 0.5)
                              : Colors.white10,
                        ),
                        color: isActive
                            ? accent.withValues(alpha: 0.05)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Row(
                        children: [
                          if (session.isPinned) ...[
                            Icon(Icons.push_pin, color: accent, size: 12),
                            const SizedBox(width: 8),
                          ],
                          Expanded(
                            child: Text(
                              session.name,
                              style: TextStyle(
                                color: isActive ? Colors.white : Colors.white60,
                                fontFamily: 'Courier',
                                fontSize: 12,
                                fontWeight: isActive
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(
                            Icons.keyboard_arrow_right,
                            color: isActive
                                ? accent.withValues(alpha: 0.7)
                                : Colors.white24,
                            size: 14,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const Divider(color: Colors.white10, height: 1),

            // UserProfileAnchor Pinned at absolute bottom
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context); // Close GeneralDrawer
                  showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => const FractionallySizedBox(
                      heightFactor: 0.92,
                      child: ProfileDrawer(),
                    ),
                  );
                },
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: accent, width: 1),
                        color: accent.withValues(alpha: 0.1),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'U',
                        style: TextStyle(
                          color: accent,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Courier',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'USUARIO_ACTIVO',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontFamily: 'Courier',
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'RANGO: JLPT N5',
                            style: TextStyle(
                              color: accent.withValues(alpha: 0.6),
                              fontSize: 9,
                              fontFamily: 'Courier',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      color: Colors.white24,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionBtn({
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.centerLeft,
        child: Text(
          label,
          style: TextStyle(
            color: accent,
            fontFamily: 'Courier',
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }
}
