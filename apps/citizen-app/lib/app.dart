import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/config/app_config.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';

/// Root widget. Themes come from the Stitch design system; the router is built
/// once and rebuilt only when auth state changes.
class JanMaangApp extends ConsumerWidget {
  const JanMaangApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: router,
      builder: (context, child) {
        // Cap text scaling so the dense metric and timeline layouts stay
        // legible at the largest accessibility sizes without overflowing.
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(
            textScaler: media.textScaler.clamp(
              minScaleFactor: 0.85,
              maxScaleFactor: 1.6,
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
