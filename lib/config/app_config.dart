enum DataSource { demo, api }

/// Public build configuration. Dart defines are not a secret store.
class AppConfig {
  const AppConfig({this.source = DataSource.demo, this.apiBaseUrl});

  factory AppConfig.fromEnvironment() {
    const mode = String.fromEnvironment('DATA_SOURCE', defaultValue: 'demo');
    const url = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'https://mmp.li',
    );
    return AppConfig.parse(mode: mode, url: url);
  }

  factory AppConfig.parse({required String mode, required String url}) {
    if (mode == 'demo') return const AppConfig();
    if (mode != 'api') {
      throw const FormatException('DATA_SOURCE muss demo oder api sein.');
    }
    final uri = Uri.tryParse(url);
    if (uri == null ||
        !uri.hasAuthority ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty ||
        uri.hasQuery ||
        uri.hasFragment ||
        (uri.scheme != 'https' &&
            !(uri.scheme == 'http' &&
                ['localhost', '127.0.0.1', '::1'].contains(uri.host)))) {
      throw const FormatException(
        'API_BASE_URL muss eine HTTPS-Basisadresse sein.',
      );
    }
    return AppConfig(source: DataSource.api, apiBaseUrl: uri);
  }

  final DataSource source;
  final Uri? apiBaseUrl;
  bool get isDemo => source == DataSource.demo;
}
