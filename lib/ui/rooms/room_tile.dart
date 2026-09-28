import 'package:flutter/material.dart';
import '../../domain/models/chat_room.dart';

enum RoomAction { rename, delete }

class RoomTile extends StatelessWidget {
  const RoomTile({
    super.key,
    required this.room,
    required this.index,
    required this.onOpen,
    required this.onAction,
    required this.enabled,
  });
  final ChatRoom room;
  final int index;
  final VoidCallback onOpen;
  final ValueChanged<RoomAction> onAction;
  final bool enabled;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      color: colors.surfaceContainerLowest,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: colors.outlineVariant),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 14,
        ),
        leading: CircleAvatar(
          backgroundColor: colors.secondaryContainer,
          foregroundColor: colors.onSecondaryContainer,
          child: Text('${index + 1}'.padLeft(2, '0')),
        ),
        title: Text(
          room.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: const Padding(
          padding: EdgeInsets.only(top: 6),
          child: Text('Gespräch öffnen →'),
        ),
        onTap: onOpen,
        trailing: PopupMenuButton<RoomAction>(
          tooltip: 'Optionen für ${room.title}',
          enabled: enabled,
          onSelected: onAction,
          itemBuilder: (_) => const [
            PopupMenuItem(value: RoomAction.rename, child: Text('Umbenennen')),
            PopupMenuItem(
              value: RoomAction.delete,
              child: Text('Raum löschen'),
            ),
          ],
        ),
      ),
    );
  }
}
