import 'package:flutter_test/flutter_test.dart';
import 'package:janmaang/features/map/data/map_fixtures.dart';
import 'package:janmaang/features/map/domain/map_issue.dart';
import 'package:janmaang/features/map/presentation/map_controller.dart';

void main() {
  final issues = MapFixtures.issues;

  group('IssueClusterer', () {
    test('collapses nearby sites when zoomed out', () {
      final clusters = IssueClusterer.cluster(issues, 11);
      expect(clusters.length, lessThan(issues.length),
          reason: 'zoomed out, some sites should group');
    });

    test('resolves to one marker per site once zoomed in', () {
      final clusters = IssueClusterer.cluster(issues, 15);
      expect(clusters.length, issues.length);
      expect(clusters.every((c) => c.isSingle), isTrue);
    });

    test('never loses or duplicates a site', () {
      for (final zoom in <double>[6, 9, 11, 12.5, 13.9, 14, 16]) {
        final clusters = IssueClusterer.cluster(issues, zoom);
        final ids = <String>[
          for (final cluster in clusters)
            for (final issue in cluster.issues) issue.id,
        ];
        expect(ids.length, issues.length, reason: 'zoom $zoom count');
        expect(ids.toSet().length, issues.length, reason: 'zoom $zoom unique');
      }
    });

    test('total reports are preserved across the clustering', () {
      final expected =
          issues.fold<int>(0, (sum, i) => sum + i.reportCount);
      for (final zoom in <double>[8, 11, 13]) {
        final total = IssueClusterer.cluster(issues, zoom)
            .fold<int>(0, (sum, c) => sum + c.totalReports);
        expect(total, expected, reason: 'zoom $zoom');
      }
    });

    test('a cluster centroid sits inside the spread of its members', () {
      final clusters = IssueClusterer.cluster(issues, 10);
      for (final cluster in clusters.where((c) => !c.isSingle)) {
        final lats = cluster.issues.map((i) => i.position.latitude);
        final lngs = cluster.issues.map((i) => i.position.longitude);
        expect(cluster.position.latitude,
            inInclusiveRange(lats.reduce((a, b) => a < b ? a : b),
                lats.reduce((a, b) => a > b ? a : b)));
        expect(cluster.position.longitude,
            inInclusiveRange(lngs.reduce((a, b) => a < b ? a : b),
                lngs.reduce((a, b) => a > b ? a : b)));
      }
    });

    test('cells are wide enough that adjacent markers cannot collide', () {
      // A cell must exceed the largest marker, or two markers one cell apart
      // would still overlap on screen.
      expect(IssueClusterer.clusterCellPx,
          greaterThan(DensityTierMax.largestMarkerPx));
    });

    test('an empty corpus produces no clusters', () {
      expect(IssueClusterer.cluster(const <MapIssue>[], 12), isEmpty);
    });
  });
}

/// Helper so the collision test states its intent rather than a magic number.
abstract final class DensityTierMax {
  static const largestMarkerPx = 64.0;
}
