import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../domain/demand.dart';
import '../domain/demand_cluster.dart';

final demandProvider =
    FutureProvider.autoDispose.family<Demand, String>((ref, id) {
  return ref.watch(demandsRepositoryProvider).getDemand(id);
});

final clusterProvider =
    FutureProvider.autoDispose.family<DemandCluster, String>((ref, id) {
  return ref.watch(demandsRepositoryProvider).getCluster(id);
});

final myDemandsProvider = StreamProvider.autoDispose<List<Demand>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream<List<Demand>>.value(const <Demand>[]);
  return ref.watch(demandsRepositoryProvider).watchMyDemands(user.uid);
});
