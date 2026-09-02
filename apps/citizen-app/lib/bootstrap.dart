import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/config/app_config.dart';

/// Starts the app inside a guarded zone.
///
/// Firebase initialisation lives here rather than in `main` so the app still
/// runs — against the in-memory repositories — before `flutterfire configure`
/// has generated `firebase_options.dart`. Once it has, drop the generated file
/// in, follow the TODO below, and pass `--dart-define=USE_MOCKS=false`.
Future<void> bootstrap(Widget Function() builder) async {
  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    if (!AppConfig.useMocks) {
      // TODO(firebase): once `flutterfire configure` has been run, uncomment
      // the block below and add the matching imports. It is deliberately left
      // inert so a fresh clone compiles and runs without a Firebase project.
      //
      //   await Firebase.initializeApp(
      //     options: DefaultFirebaseOptions.currentPlatform,
      //   );
      //   FlutterError.onError =
      //       FirebaseCrashlytics.instance.recordFlutterFatalError;
      //   await FirebaseAnalytics.instance.logAppOpen();
      debugPrint(
        'USE_MOCKS=false but Firebase initialisation is not wired up yet — '
        'see lib/bootstrap.dart.',
      );
    }

    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      if (kReleaseMode) {
        // Crashlytics takes over here once Firebase is initialised.
      }
    };

    runApp(ProviderScope(child: builder()));
  }, (error, stack) {
    debugPrint('Uncaught error: $error\n$stack');
  });
}
