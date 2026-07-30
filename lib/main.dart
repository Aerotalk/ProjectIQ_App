import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/environment/app_config.dart';
import 'core/environment/environment.dart';
import 'core/router/app_router.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';

import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // Initialize AppConfig (Development by default for now)
  AppConfig.init(
    AppConfig(
      environment: Environment.dev,
      apiBaseUrl: kIsWeb ? 'http://localhost:8080/api' : 'http://10.0.2.2:8080/api', 
    ),
  );

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
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
