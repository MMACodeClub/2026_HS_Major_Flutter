import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'config/app_config.dart';
import 'data/chat_repository.dart';
import 'ui/core/app_theme.dart';
import 'ui/rooms/rooms_screen.dart';

/// The app owns the repository. Screens own and dispose their view models.
class ChatApp extends StatefulWidget {
  const ChatApp({
    super.key,
    required this.repository,
    this.config = const AppConfig(),
  });
  final ChatRepository repository;
  final AppConfig config;
  @override
  State<ChatApp> createState() => _ChatAppState();
}

class _ChatAppState extends State<ChatApp> {
  @override
  void dispose() {
    widget.repository.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'MMA Chat · Code Club',
    debugShowCheckedModeBanner: false,
    theme: appTheme(Brightness.light),
    darkTheme: appTheme(Brightness.dark),
    locale: const Locale('de', 'CH'),
    supportedLocales: const [Locale('de', 'CH')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    home: RoomsScreen(repository: widget.repository, config: widget.config),
  );
}
