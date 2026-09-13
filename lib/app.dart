import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/providers/app_settings_provider.dart';
import 'shared/theme/app_theme.dart';

class GoHowResearchApp extends ConsumerWidget {
  const GoHowResearchApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final settings = ref.watch(appSettingsProvider);

    return MaterialApp.router(
      title: 'GoHow Research',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme.copyWith(
        colorScheme:
            ColorScheme.fromSeed(seedColor: Color(settings.accentColor)),
        visualDensity: settings.compactLayout
            ? VisualDensity.compact
            : VisualDensity.standard,
      ),
      builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(settings.textScale)),
          child: child!),
      routerConfig: router,
    );
  }
}
