import 'environment.dart';

class AppConfig {
  final Environment environment;
  final String apiBaseUrl;

  const AppConfig({
    required this.environment,
    required this.apiBaseUrl,
  });

  static late AppConfig _instance;

  static void init(AppConfig config) {
    _instance = config;
  }

  static AppConfig get instance => _instance;
}
