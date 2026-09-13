import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'app.dart';
import 'core/database/app_database.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

  // Load environment variables from .env
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('Note: .env file not loaded or not found ($e). Using defaults.');
  }

  // Initialize window manager for desktop
  if (!kIsWeb) {
    try {
      await windowManager.ensureInitialized();
      WindowOptions windowOptions = const WindowOptions(
        size: Size(1280, 800),
        minimumSize: Size(900, 600),
        center: true,
        title: 'GoHow Research',
        backgroundColor: Colors.transparent,
        skipTaskbar: false,
        titleBarStyle: TitleBarStyle.normal,
      );
      await windowManager.waitUntilReadyToShow(windowOptions, () async {
        await windowManager.show();
        await windowManager.focus();
      });
    } catch (_) {}
  }

  // Read Supabase credentials from .env, falling back to --dart-define
  final supabaseUrl = dotenv.env['SUPABASE_URL'] ??
      const String.fromEnvironment(
        'SUPABASE_URL',
        defaultValue: 'https://your-project.supabase.co',
      );

  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ??
      const String.fromEnvironment(
        'SUPABASE_ANON_KEY',
        defaultValue: 'your-anon-key',
      );

  final hasSupabaseConfig =
      Uri.tryParse(supabaseUrl)?.host.endsWith('.supabase.co') == true &&
          !supabaseUrl.contains('your-project') &&
          supabaseAnonKey.isNotEmpty &&
          !supabaseAnonKey.contains('your-anon-key');

  // Cloud services are optional; local research workflows need no credentials.
  if (hasSupabaseConfig) {
    try {
      await Supabase.initialize(
        url: supabaseUrl,
        publishableKey: supabaseAnonKey,
      );
    } catch (e) {
      debugPrint('Supabase init warning: $e');
    }
  }

  // Initialize local database (drift)
  final db = AppDatabase();

  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
      ],
      child: const GoHowResearchApp(),
    ),
  );
}
