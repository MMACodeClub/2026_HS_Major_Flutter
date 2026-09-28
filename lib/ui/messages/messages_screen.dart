import 'dart:async';
import 'package:flutter/material.dart';
import '../../config/app_config.dart';
import '../../data/chat_repository.dart';
import '../../domain/input_validation.dart';
import '../../domain/models/chat_message.dart';
import '../../domain/models/chat_room.dart';
import '../core/dialogs.dart';
import '../core/status_widgets.dart';
import 'message_tile.dart';
import 'messages_view_model.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({
    super.key,
    required this.room,
    required this.repository,
    required this.config,
  });
  final ChatRoom room;
  final ChatRepository repository;
  final AppConfig config;
  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  late final _model = MessagesViewModel(widget.repository, widget.room.id);
  final _draft = TextEditingController();
  final _scroll = ScrollController();
  final _form = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    unawaited(_model.load());
  }

  @override
  void dispose() {
    _model.dispose();
    _draft.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_form.currentState!.validate()) return;
    final saved = await _model.send(_draft.text);
    if (!mounted || !saved) return;
    _draft.clear();
    _form.currentState!.reset();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _scroll.hasClients) {
        unawaited(
          _scroll.animateTo(
            _scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          ),
        );
      }
    });
  }

  Future<void> _action(ChatMessage message, MessageAction action) async {
    switch (action) {
      case MessageAction.edit:
        final content = await showTextEditor(
          context,
          title: 'Nachricht bearbeiten',
          label: 'Nachricht',
          validator: validateMessage,
          maxLength: maxMessageLength,
          initialValue: message.content,
          multiline: true,
        );
        if (!mounted || content == null) return;
        await _model.edit(message, content);
      case MessageAction.delete:
        final confirmed = await confirmDelete(
          context,
          title: 'Nachricht löschen?',
          description: 'Diese Nachricht wird dauerhaft aus dem Raum entfernt.',
        );
        if (!mounted || !confirmed) return;
        await _model.delete(message);
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _model,
    builder: (context, _) => Scaffold(
      appBar: AppBar(
        title: Text(widget.room.title),
        actions: [
          IconButton(
            tooltip: 'Nachrichten aktualisieren',
            onPressed: _model.isBusy ? null : _model.load,
            icon: const Icon(Icons.refresh),
          ),
          SourceBadge(isDemo: widget.config.isDemo),
          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Aktualisiere den Raum, um neue Beiträge zu sehen.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ),
                if (_model.isBusy) const LinearProgressIndicator(),
                if (_model.error case final error?)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: ErrorNotice(
                      message: error,
                      onRetry: _model.isBusy ? null : _model.load,
                    ),
                  ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _model.load,
                    child: ListView(
                      controller: _scroll,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(20),
                      children: [
                        if (_model.items.isEmpty &&
                            !_model.isBusy &&
                            _model.error == null)
                          const EmptyState(
                            icon: Icons.chat_bubble_outline,
                            title: 'Mach den Anfang.',
                            description:
                                'Teile die erste Frage oder Idee in diesem Raum.',
                          ),
                        for (final message in _model.items)
                          MessageTile(
                            key: ValueKey(message.id),
                            message: message,
                            enabled: !_model.isBusy,
                            onAction: (action) =>
                                unawaited(_action(message, action)),
                          ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: Form(
                    key: _form,
                    child: TextFormField(
                      controller: _draft,
                      enabled: !_model.isSaving,
                      minLines: 1,
                      maxLines: 4,
                      maxLength: maxMessageLength,
                      validator: validateMessage,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        labelText: 'Deine Nachricht',
                        hintText: 'Was möchtest du teilen?',
                        suffixIcon: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: IconButton.filled(
                            tooltip: 'Nachricht senden',
                            onPressed: _model.isBusy ? null : _send,
                            icon: Icon(
                              Icons.arrow_upward,
                              color: _model.isBusy
                                  ? null
                                  : Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
