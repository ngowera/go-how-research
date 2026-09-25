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
      title: 'Go-How RS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme.copyWith(
        colorScheme:
            ColorScheme.fromSeed(seedColor: Color(settings.accentColor)),
        visualDensity: settings.compactLayout
            ? VisualDensity.compact
            : VisualDensity.standard,
      ),
      builder: (context, child) => _StartupBranding(child: child!),
      routerConfig: router,
    );
  }
}

class _StartupBranding extends StatefulWidget {
  final Widget child;
  const _StartupBranding({required this.child});

  @override
  State<_StartupBranding> createState() => _StartupBrandingState();
}

class _StartupBrandingState extends State<_StartupBranding> {
  bool _showBranding = true;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 900), () {
      if (mounted) setState(() => _showBranding = false);
    });
  }

  @override
  Widget build(BuildContext context) => Stack(
        children: [
          widget.child,
          if (_showBranding)
            ColoredBox(
              color: Colors.white,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipOval(
                      child: Image.asset('app_logo.png',
                          width: 146, height: 146, fit: BoxFit.cover),
                    ),
                    const SizedBox(height: 18),
                    const Text('Go-How RS',
                        style: TextStyle(
                            color: Color(0xFF1E293B),
                            fontSize: 22,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
        ],
      );
}
