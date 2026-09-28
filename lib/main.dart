import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'app.dart';
import 'config/app_config.dart';
import 'data/repositories/api_chat_repository.dart';
import 'data/repositories/demo_chat_repository.dart';
import 'data/services/chat_api_client.dart';

void main() {
  final config = AppConfig.fromEnvironment();
  final repository = config.isDemo
      ? DemoChatRepository()
      : ApiChatRepository(
          ChatApiClient(client: http.Client(), baseUrl: config.apiBaseUrl!),
        );
  runApp(ChatApp(repository: repository, config: config));
}
