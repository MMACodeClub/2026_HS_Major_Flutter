import 'dart:async';
import 'package:flutter/material.dart';
import '../../config/app_config.dart';
import '../../data/chat_repository.dart';
import '../../domain/input_validation.dart';
import '../../domain/models/chat_room.dart';
import '../core/dialogs.dart';
import '../core/status_widgets.dart';
import '../messages/messages_screen.dart';
import 'room_tile.dart';
import 'rooms_view_model.dart';

class RoomsScreen extends StatefulWidget {
  const RoomsScreen({
    super.key,
    required this.repository,
    required this.config,
  });
  final ChatRepository repository;
  final AppConfig config;
  @override
  State<RoomsScreen> createState() => _RoomsScreenState();
}

class _RoomsScreenState extends State<RoomsScreen> {
  late final _model = RoomsViewModel(widget.repository);
  String _query = '';
  @override
  void initState() {
    super.initState();
    unawaited(_model.load());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final title = await showTextEditor(
      context,
      title: 'Neuer Raum',
      label: 'Raumname',
      validator: validateRoomTitle,
      maxLength: maxRoomTitleLength,
    );
    if (!mounted || title == null) return;
    await _model.create(title);
  }

  Future<void> _action(ChatRoom room, RoomAction action) async {
    switch (action) {
      case RoomAction.rename:
        final title = await showTextEditor(
          context,
          title: 'Raum umbenennen',
          label: 'Raumname',
          validator: validateRoomTitle,
          maxLength: maxRoomTitleLength,
          initialValue: room.title,
        );
        if (!mounted || title == null) return;
        await _model.rename(room, title);
      case RoomAction.delete:
        final confirmed = await confirmDelete(
          context,
          title: 'Raum löschen?',
          description: '«${room.title}» und seine Nachrichten werden gelöscht.',
        );
        if (!mounted || !confirmed) return;
        await _model.delete(room);
    }
  }

  Future<void> _open(ChatRoom room) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MessagesScreen(
          room: room,
          repository: widget.repository,
          config: widget.config,
        ),
      ),
    );
    if (mounted) await _model.load();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _model,
    builder: (context, _) {
      final colors = Theme.of(context).colorScheme;
      final rooms = _model.items
          .where(
            (room) => room.title.toLowerCase().contains(_query.toLowerCase()),
          )
          .toList();
      return Scaffold(
        appBar: AppBar(
          toolbarHeight: 80,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Icon(Icons.forum_rounded, color: colors.onPrimary),
                ),
              ),
              const SizedBox(width: 12),
              const Flexible(
                child: Text(
                  'MMA / CODE CLUB',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            SourceBadge(isDemo: widget.config.isDemo),
            const SizedBox(width: 16),
          ],
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: RefreshIndicator(
                onRefresh: _model.load,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ZUSAMMEN WEITERDENKEN',
                              style: TextStyle(
                                color: colors.primary,
                                letterSpacing: 2,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'Ein Raum für jede gute Idee.',
                              style: TextStyle(
                                fontSize: MediaQuery.sizeOf(context).width < 600
                                    ? 34
                                    : 52,
                                fontWeight: FontWeight.w800,
                                height: 1.12,
                                letterSpacing: -1.4,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Fragen stellen. Wissen teilen. Gemeinsam etwas bauen.',
                              style: TextStyle(
                                fontSize: 17,
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 28),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                FilledButton.icon(
                                  onPressed: _model.isBusy ? null : _create,
                                  icon: const Icon(Icons.add),
                                  label: const Text('Neuer Raum'),
                                ),
                                TextButton.icon(
                                  onPressed: _model.isBusy ? null : _model.load,
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Aktualisieren'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                            TextField(
                              onChanged: (value) =>
                                  setState(() => _query = value),
                              decoration: const InputDecoration(
                                labelText: 'Räume durchsuchen',
                                prefixIcon: Icon(Icons.search),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              '${rooms.length} ${rooms.length == 1 ? 'GESPRÄCHSRAUM' : 'GESPRÄCHSRÄUME'}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.4,
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 14),
                            if (_model.isBusy)
                              const Padding(
                                padding: EdgeInsets.only(bottom: 12),
                                child: LinearProgressIndicator(),
                              ),
                            if (_model.error case final error?)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: ErrorNotice(
                                  message: error,
                                  onRetry: _model.isBusy ? null : _model.load,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    if (rooms.isEmpty && !_model.isBusy && _model.error == null)
                      SliverToBoxAdapter(
                        child: EmptyState(
                          icon: Icons.forum_outlined,
                          title: _query.isEmpty
                              ? 'Hier beginnt euer Gespräch.'
                              : 'Kein passender Raum.',
                          description: _query.isEmpty
                              ? 'Erstelle den ersten Raum und lade andere ein.'
                              : 'Probiere einen anderen Suchbegriff.',
                        ),
                      ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      sliver: SliverList.builder(
                        itemCount: rooms.length,
                        itemBuilder: (context, index) => RoomTile(
                          key: ValueKey(rooms[index].id),
                          room: rooms[index],
                          index: index,
                          enabled: !_model.isBusy,
                          onOpen: () => unawaited(_open(rooms[index])),
                          onAction: (action) =>
                              unawaited(_action(rooms[index], action)),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 18, 24, 32),
                        child: Text(
                          widget.config.isDemo
                              ? 'DEMO · Deine Änderungen bleiben bis zum Neustart.'
                              : 'KURS-API · Neue Beiträge mit «Aktualisieren» laden.',
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.onSurfaceVariant,
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
    },
  );
}
