import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:path_provider/path_provider.dart';

import 'core/environment/app_config.dart';
import 'core/environment/environment.dart';
import 'core/router/app_router.dart';
import 'core/network/api_client.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';

import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // Initialize CookieJar for persistence
  CookieJar cookieJar = CookieJar();
  if (!kIsWeb) {
    final appDocDir = await getApplicationDocumentsDirectory();
    final String appDocPath = appDocDir.path;
    cookieJar = PersistCookieJar(
      ignoreExpires: true,
      storage: FileStorage("$appDocPath/.cookies/"),
    );
  }

  // Determine local backend URL based on platform
  // Using the computer's local network IP so APKs on physical devices can connect
  String localApiUrl = 'http://192.168.0.104:8080';

  // Initialize AppConfig (Development by default for now)
  AppConfig.init(
    AppConfig(
      environment: Environment.dev,
      // apiBaseUrl: 'https://projectiqbackend-production.up.railway.app', 
      apiBaseUrl: localApiUrl,
    ),
  );

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        cookieJarProvider.overrideWithValue(cookieJar),
      ],
      child: const HRMSApp(),
    ),
  );
}

class HRMSApp extends ConsumerWidget {
  const HRMSApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'HRMS Mobile App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ref.watch(themeProvider),
      routerConfig: ref.watch(appRouterProvider),
      debugShowCheckedModeBanner: false,
    );
  }
}
