import 'dart:async';

import '../../../core/errors/failure.dart';
import '../../../shared/models/demand_enums.dart';
import '../domain/demand.dart';
import '../domain/demand_cluster.dart';
import '../domain/demands_repository.dart';
import 'demand_fixtures.dart';

/// In-memory implementation used until a Firebase project is attached, and by
/// widget tests. Mutations are reflected back through the streams so the UI
/// exercises the same rebuild paths it will in production.
class MockDemandsRepository implements DemandsRepository {
  MockDemandsRepository() {
    _nearby = DemandFixtures.nearby;
    _mine = DemandFixtures.mine;
    _clusters = <String, DemandCluster>{
      DemandFixtures.waterCluster.id: DemandFixtures.waterCluster,
    };
  }

  late List<Demand> _nearby;
  late List<Demand> _mine;
  late Map<String, DemandCluster> _clusters;

  final _nearbyController = StreamController<List<Demand>>.broadcast();
  final _mineController = StreamController<List<Demand>>.broadcast();

  static const _latency = Duration(milliseconds: 450);

  @override
  Stream<List<Demand>> watchNearbyDemands({int limit = 10}) async* {
    await Future<void>.delayed(_latency);
    yield _nearby.take(limit).toList();
    yield* _nearbyController.stream.map((d) => d.take(limit).toList());
  }

  @override
  Stream<List<Demand>> watchMyDemands(String uid) async* {
    await Future<void>.delayed(_latency);
    yield _mine;
    yield* _mineController.stream;
  }

  @override
  Future<Demand> getDemand(String id) async {
    await Future<void>.delayed(_latency);
    final all = <Demand>{..._nearby, ..._mine};
    final match = all.where((d) => d.id == id).firstOrNull;
    if (match == null) throw const NotFoundFailure('That demand no longer exists.');
    return match;
  }

  @override
  Future<DemandCluster> getCluster(String id) async {
    await Future<void>.delayed(_latency);
    final cluster = _clusters[id];
    if (cluster == null) {
      throw const NotFoundFailure('That cluster no longer exists.');
    }
    return cluster;
  }

  @override
  Future<DemandCluster?> findSimilarCluster({
    required DemandCategory category,
    required double latitude,
    required double longitude,
  }) async {
    // Mirrors the "Finding similar requests in this area…" banner.
    await Future<void>.delayed(const Duration(milliseconds: 1600));
    if (category == DemandCategory.water) return _clusters.values.first;
    return null;
  }

  @override
  Future<DemandCluster> joinCluster(String clusterId, String uid) async {
    await Future<void>.delayed(_latency);
    final existing = _clusters[clusterId];
    if (existing == null) throw const NotFoundFailure();
    final updated = existing.copyWith(
      hasJoined: true,
      reportCount: existing.reportCount + 1,
    );
    _clusters[clusterId] = updated;

    // Joining raises the supporter count on every demand in the cluster.
    _nearby = _nearby
        .map((d) => d.clusterId == clusterId
            ? d.copyWith(supporterCount: d.supporterCount + 1)
            : d)
        .toList();
    _nearbyController.add(_nearby);
    return updated;
  }

  @override
  Future<void> questionRanking({
    required String demandId,
    required String uid,
    required String reason,
  }) async {
    await Future<void>.delayed(_latency);
    if (reason.trim().length < 10) {
      throw const ValidationFailure(
        'Please describe your objection in a little more detail.',
      );
    }
  }

  @override
  Future<CommunityPulse> getCommunityPulse(String district) async {
    await Future<void>.delayed(_latency);
    return DemandFixtures.pulse;
  }

  /// Used by the report flow so a freshly filed demand appears in "My Demands".
  void addDemand(Demand demand) {
    _mine = <Demand>[demand, ..._mine];
    _nearby = <Demand>[demand, ..._nearby];
    _mineController.add(_mine);
    _nearbyController.add(_nearby);
  }

  void dispose() {
    _nearbyController.close();
    _mineController.close();
  }
}
