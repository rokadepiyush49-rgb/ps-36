import '../../../shared/models/demand_enums.dart';
import 'demand.dart';
import 'demand_cluster.dart';

/// Contract the presentation layer talks to. Implemented against Firestore in
/// production and against in-memory fixtures for local development and tests.
abstract interface class DemandsRepository {
  /// Demands near the citizen, ordered by distance — the Home "Near You" list.
  Stream<List<Demand>> watchNearbyDemands({int limit = 10});

  /// Everything the signed-in citizen has reported or joined — the Track tab.
  Stream<List<Demand>> watchMyDemands(String uid);

  Future<Demand> getDemand(String id);

  Future<DemandCluster> getCluster(String id);

  /// Called after a report is filed: returns the cluster it was merged into,
  /// or null when the report is the first of its kind.
  Future<DemandCluster?> findSimilarCluster({
    required DemandCategory category,
    required double latitude,
    required double longitude,
  });

  /// Adds the citizen's voice to an existing cluster, raising its priority.
  Future<DemandCluster> joinCluster(String clusterId, String uid);

  /// Files a formal objection to a ranking — "Question this ranking".
  Future<void> questionRanking({
    required String demandId,
    required String uid,
    required String reason,
  });

  /// Aggregate counters behind the Home "Community Pulse" tiles.
  Future<CommunityPulse> getCommunityPulse(String district);
}

/// The four Community Pulse stat tiles.
class CommunityPulse {
  const CommunityPulse({
    required this.activeDemands,
    required this.peopleAffected,
    required this.underReview,
    required this.funded,
  });

  final int activeDemands;
  final int peopleAffected;
  final int underReview;
  final int funded;
}
