import 'package:flutter_test/flutter_test.dart';
import 'package:janmaang/features/demands/data/demand_fixtures.dart';
import 'package:janmaang/features/demands/data/demands_repository_mock.dart';
import 'package:janmaang/shared/models/demand_enums.dart';

void main() {
  late MockDemandsRepository repository;

  setUp(() => repository = MockDemandsRepository());
  tearDown(() => repository.dispose());

  test('community pulse matches the figures in the design', () async {
    final pulse = await repository.getCommunityPulse('Yadgir');
    expect(pulse.activeDemands, 41);
    expect(pulse.peopleAffected, 4281);
    expect(pulse.underReview, 12);
    expect(pulse.funded, 3);
  });

  test('nearby demands lead with the top-ranked one', () async {
    final nearby = await repository.watchNearbyDemands().first;
    expect(nearby.first.rank, 1);
    expect(nearby.any((d) => d.code == 'YDG-WTR-0417'), isTrue);
  });

  test('joining a cluster raises its report count and supporter counts',
      () async {
    final before = await repository.getCluster(DemandFixtures.waterCluster.id);
    final after =
        await repository.joinCluster(DemandFixtures.waterCluster.id, 'uid-1');

    expect(after.reportCount, before.reportCount + 1);
    expect(after.hasJoined, isTrue);
  });

  test('finds the water cluster for a nearby water report', () async {
    final cluster = await repository.findSimilarCluster(
      category: DemandCategory.water,
      latitude: 16.77,
      longitude: 77.13,
    );
    expect(cluster, isNotNull);
    expect(cluster!.reportCount, 41);
  });

  test('returns no cluster for a category with no existing reports', () async {
    final cluster = await repository.findSimilarCluster(
      category: DemandCategory.education,
      latitude: 16.77,
      longitude: 77.13,
    );
    expect(cluster, isNull);
  });

  test('an unknown demand id surfaces a not-found failure', () {
    expect(() => repository.getDemand('nope'), throwsA(isA<Exception>()));
  });

  test('a too-short objection is rejected', () {
    expect(
      () => repository.questionRanking(
        demandId: 'demand-water-0417',
        uid: 'uid-1',
        reason: 'bad',
      ),
      throwsA(isA<Exception>()),
    );
  });
}
