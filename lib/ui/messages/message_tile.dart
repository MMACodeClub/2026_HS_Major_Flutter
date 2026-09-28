import 'package:flutter/material.dart';
import '../../domain/models/chat_message.dart';

enum MessageAction { edit, delete }

class MessageTile extends StatelessWidget {
  const MessageTile({
    super.key,
    required this.message,
    required this.enabled,
    required this.onAction,
  });
  final ChatMessage message;
  final bool enabled;
  final ValueChanged<MessageAction> onAction;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final localizations = MaterialLocalizations.of(context);
    final date = message.sentAt.toLocal();
    final time =
        '${localizations.formatShortDate(date)} · ${localizations.formatTimeOfDay(TimeOfDay.fromDateTime(date), alwaysUse24HourFormat: true)}';
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Card(
        elevation: 0,
        color: colors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: colors.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 8, 8, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      message.author,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: colors.primary,
                      ),
                    ),
                  ),
                  PopupMenuButton<MessageAction>(
                    tooltip: 'Nachrichtenoptionen',
                    enabled: enabled,
                    onSelected: onAction,
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: MessageAction.edit,
                        child: Text('Bearbeiten'),
                      ),
                      PopupMenuItem(
                        value: MessageAction.delete,
                        child: Text('Nachricht löschen'),
                      ),
                    ],
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: SelectableText(
                  message.content,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                time,
                style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
