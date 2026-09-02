import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/data/auth_repository_mock.dart';
import '../features/auth/domain/app_user.dart';
import '../features/auth/domain/auth_repository.dart';
import '../features/demands/data/demands_repository_mock.dart';
import '../features/demands/domain/demands_repository.dart';
import '../features/ledger/data/ledger_repository_mock.dart';
import '../features/ledger/domain/ledger_repository.dart';
import '../features/report/data/report_repository_mock.dart';
import '../features/report/domain/report_repository.dart';
import '../features/verification/data/verification_repository_mock.dart';
import '../features/verification/domain/verification_repository.dart';

/// Composition root for the data layer.
///
/// Every repository defaults to its in-memory implementation. `main.dart`
/// overrides these with the Firebase-backed ones once `firebase_options.dart`
/// exists and `USE_MOCKS=false` is passed; tests override them with fakes.
/// Nothing above this file knows which implementation is live.

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final repository = MockAuthRepository();
  ref.onDispose(repository.dispose);
  return repository;
});

final demandsRepositoryProvider = Provider<DemandsRepository>((ref) {
  final repository = MockDemandsRepository();
  ref.onDispose(repository.dispose);
  return repository;
});

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  final demands = ref.watch(demandsRepositoryProvider);
  // The mock report repository writes back into the mock demand store so a
  // freshly filed report appears in "My Demands" immediately. When Firebase is
  // live this provider is overridden in main.dart, so the cast never runs.
  if (demands is MockDemandsRepository) return MockReportRepository(demands);
  throw StateError(
    'reportRepositoryProvider must be overridden when Firebase is enabled.',
  );
});

final verificationRepositoryProvider = Provider<VerificationRepository>(
  (ref) => MockVerificationRepository(),
);

final ledgerRepositoryProvider = Provider<LedgerRepository>(
  (ref) => MockLedgerRepository(),
);

/// The signed-in citizen, or null. Drives the router's auth redirect.
final authStateProvider = StreamProvider<AppUser?>(
  (ref) => ref.watch(authRepositoryProvider).authStateChanges(),
);

/// Convenience read of the current user; null while signed out.
final currentUserProvider = Provider<AppUser?>(
  (ref) => ref.watch(authStateProvider).value,
);
