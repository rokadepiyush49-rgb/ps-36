import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/providers.dart';
import '../../demands/domain/demand.dart';
import '../../demands/domain/demands_repository.dart';

/// The four Community Pulse tiles.
final communityPulseProvider = FutureProvider.autoDispose<CommunityPulse>((ref) {
  final user = ref.watch(currentUserProvider);
  final district =
      user?.district.isNotEmpty == true ? user!.district : AppConfig.defaultDistrict;
  return ref.watch(demandsRepositoryProvider).getCommunityPulse(district);
});

/// The "Near You" demand list.
final nearbyDemandsProvider = StreamProvider.autoDispose<List<Demand>>(
  (ref) => ref.watch(demandsRepositoryProvider).watchNearbyDemands(),
);
