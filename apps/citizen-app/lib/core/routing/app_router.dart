import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/domain/app_user.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/otp_screen.dart';
import '../../features/demands/presentation/cluster_screen.dart';
import '../../features/demands/presentation/demand_detail_screen.dart';
import '../../features/demands/presentation/question_ranking_screen.dart';
import '../../features/demands/presentation/track_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/map/presentation/full_map_screen.dart';
import '../../features/leaderboard/presentation/leaderboard_screen.dart';
import '../../features/ledger/presentation/ledger_screen.dart';
import '../../features/method/presentation/method_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/report/presentation/report_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/verification/presentation/field_verification_screen.dart';
import '../../features/verification/presentation/verify_screen.dart';
import '../../shared/models/demand_enums.dart';
import '../../shared/widgets/jm_shell.dart';
import '../providers.dart';
import 'routes.dart';

final _rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _shellKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

/// go_router configuration.
///
/// Three branches live inside the bottom-nav shell (Home, Track, Ledger).
/// Everything transactional — login, the report flow, verification, a demand
/// detail — is pushed above the shell, which is how the Stitch designs behave:
/// those screens suppress the bottom navigation entirely.
final routerProvider = Provider<GoRouter>((ref) {
  // The router is built exactly once. Watching auth here instead would rebuild
  // the whole GoRouter on every auth change, and the new instance would claim
  // the same navigator GlobalKeys as the one still mounted — which throws
  // "Multiple widgets used the same GlobalKey" and leaves the shell blank.
  // A refreshListenable re-runs `redirect` against the same router instead.
  final authListenable = ValueNotifier<AsyncValue<AppUser?>>(
    const AsyncLoading<AppUser?>(),
  );
  ref.onDispose(authListenable.dispose);
  ref.listen<AsyncValue<AppUser?>>(
    authStateProvider,
    (_, next) => authListenable.value = next,
    fireImmediately: true,
  );

  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: AppRoute.splash.path,
    debugLogDiagnostics: false,
    refreshListenable: authListenable,
    redirect: (context, state) {
      final auth = authListenable.value;

      // Hold the current location until the auth stream produces its first value.
      if (auth.isLoading) return null;

      final location = state.matchedLocation;

      // The splash screen is exempt from the guard in both directions: it runs
      // its own timeline and then decides where to go. Redirecting off it would
      // mean nobody ever sees it.
      if (location == AppRoute.splash.path) return null;

      // First resolution of the session goes through the splash whatever was
      // asked for — otherwise a deep link, a bookmark or a hot restart on
      // `#/onboarding` skips the whole opening sequence. The destination is
      // remembered and restored the moment the timeline finishes.
      if (!SplashGate.completed) {
        SplashGate.remember(state.uri.toString());
        return AppRoute.splash.path;
      }

      final signedIn = auth.value != null;
      final onAuthRoute = location == AppRoute.login.path ||
          location == AppRoute.otp.path ||
          location == AppRoute.onboarding.path;

      if (!signedIn && !onAuthRoute) return AppRoute.onboarding.path;
      if (signedIn && onAuthRoute) return AppRoute.home.path;
      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: AppRoute.splash.path,
        name: AppRoute.splash.name,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoute.onboarding.path,
        name: AppRoute.onboarding.name,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoute.login.path,
        name: AppRoute.login.name,
        builder: (context, state) => const LoginScreen(),
        routes: <RouteBase>[
          GoRoute(
            path: 'otp',
            name: AppRoute.otp.name,
            builder: (context, state) => const OtpScreen(),
          ),
        ],
      ),

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            JmShell(navigationShell: navigationShell),
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            navigatorKey: _shellKey,
            routes: <RouteBase>[
              GoRoute(
                path: AppRoute.home.path,
                name: AppRoute.home.name,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoute.track.path,
                name: AppRoute.track.name,
                builder: (context, state) => const TrackScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoute.leaderboard.path,
                name: AppRoute.leaderboard.name,
                builder: (context, state) => const LeaderboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoute.ledger.path,
                name: AppRoute.ledger.name,
                builder: (context, state) => const LedgerScreen(),
              ),
            ],
          ),
        ],
      ),

      GoRoute(
        path: AppRoute.report.path,
        name: AppRoute.report.name,
        parentNavigatorKey: _rootKey,
        builder: (context, state) => ReportScreen(
          channel: ReportChannel.values.firstWhere(
            (c) => c.name == state.uri.queryParameters['channel'],
            orElse: () => ReportChannel.voice,
          ),
        ),
      ),
      GoRoute(
        path: AppRoute.demandDetail.path,
        name: AppRoute.demandDetail.name,
        parentNavigatorKey: _rootKey,
        builder: (context, state) =>
            DemandDetailScreen(demandId: state.pathParameters['id']!),
        routes: <RouteBase>[
          GoRoute(
            path: 'question',
            name: AppRoute.questionRanking.name,
            parentNavigatorKey: _rootKey,
            builder: (context, state) =>
                QuestionRankingScreen(demandId: state.pathParameters['id']!),
          ),
        ],
      ),
      GoRoute(
        path: AppRoute.cluster.path,
        name: AppRoute.cluster.name,
        parentNavigatorKey: _rootKey,
        builder: (context, state) =>
            ClusterScreen(clusterId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoute.verify.path,
        name: AppRoute.verify.name,
        parentNavigatorKey: _rootKey,
        builder: (context, state) =>
            VerifyScreen(demandId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoute.fieldVerification.path,
        name: AppRoute.fieldVerification.name,
        parentNavigatorKey: _rootKey,
        builder: (context, state) =>
            FieldVerificationScreen(assignmentId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoute.profile.path,
        name: AppRoute.profile.name,
        parentNavigatorKey: _rootKey,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppRoute.map.path,
        name: AppRoute.map.name,
        parentNavigatorKey: _rootKey,
        builder: (context, state) => const FullMapScreen(),
      ),
      GoRoute(
        path: AppRoute.method.path,
        name: AppRoute.method.name,
        parentNavigatorKey: _rootKey,
        builder: (context, state) => const MethodScreen(),
      ),
    ],
    errorBuilder: (context, state) => _RouteErrorScreen(message: state.error?.toString()),
  );
});

class _RouteErrorScreen extends StatelessWidget {
  const _RouteErrorScreen({this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            message ?? 'That page does not exist.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
