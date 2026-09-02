/// Every named route in the app. Using an enum keeps `goNamed` call sites
/// typo-proof and gives one place to see the whole navigation surface.
enum AppRoute {
  splash('/splash'),
  onboarding('/onboarding'),
  login('/login'),
  otp('/login/otp'),
  home('/home'),
  track('/track'),
  report('/report'),
  leaderboard('/leaderboard'),
  ledger('/ledger'),
  demandDetail('/demand/:id'),
  cluster('/cluster/:id'),
  questionRanking('/demand/:id/question'),
  verify('/verify/:id'),
  fieldVerification('/field-verification/:id'),
  map('/map'),
  method('/method'),
  profile('/profile'),
  notifications('/notifications');

  const AppRoute(this.path);

  final String path;
}

/// Cold-start gate for the splash sequence.
///
/// On the web a citizen can land on any URL — a shared link to a demand, a
/// bookmark, `#/onboarding` — and go_router will honour that path directly,
/// which means the splash screen would simply never run. This holds the first
/// route resolution of a session at [AppRoute.splash] whatever was asked for,
/// remembers the intended destination, and lets the splash screen hand back to
/// it when its timeline finishes.
///
/// It is deliberately a plain mutable holder rather than a provider: it is
/// process-scoped state that exists for exactly one transition, and wiring it
/// through Riverpod would mean the router rebuilding on a value nothing else
/// reads.
abstract final class SplashGate {
  /// Whether the splash has already run in this session.
  static bool completed = false;

  /// Where the citizen was actually heading when the app opened.
  static String? intended;

  /// Records [location] as the destination to restore, unless it is the splash
  /// route itself or the bare root — neither is somewhere to come back to.
  static void remember(String location) {
    if (location == AppRoute.splash.path || location == '/') return;
    intended ??= location;
  }

  /// Marks the sequence finished and returns where to go next.
  static String release() {
    completed = true;
    final target = intended ?? AppRoute.onboarding.path;
    intended = null;
    return target;
  }
}
