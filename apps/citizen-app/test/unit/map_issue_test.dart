import 'package:flutter_test/flutter_test.dart';
import 'package:janmaang/core/theme/janmaang_colors.dart';
import 'package:janmaang/features/map/data/map_fixtures.dart';
import 'package:janmaang/features/map/domain/map_issue.dart';
import 'package:janmaang/shared/models/demand_enums.dart';
import 'package:janmaang/shared/models/provenance.dart';
import 'package:latlong2/latlong.dart';

MapIssue issueWith({
  int reportCount = 1,
  Severity severity = Severity.low,
  DemandCategory category = DemandCategory.water,
  DemandStatus status = DemandStatus.reported,
  String title = 'Test issue',
  String ward = 'Ward 1',
}) =>
    MapIssue(
      id: 'x',
      code: 'TST-001',
      title: title,
      category: category,
      severity: severity,
      status: status,
      position: const LatLng(16.77, 77.13),
      reportCount: reportCount,
      reportedAt: DateTime(2026, 8, 1),
      ward: ward,
      stamp: const ProvenanceStamp(provenance: Provenance.syntheticRural),
    );

void main() {
  group('displayTier', () {
    test('a lone critical report is not buried at the low tier', () {
      final issue = issueWith(reportCount: 1, severity: Severity.critical);
      expect(issue.tier, DensityTier.low);
      expect(issue.displayTier, DensityTier.critical);
    });

    test('many reports outrank a mild severity', () {
      final issue = issueWith(reportCount: 60, severity: Severity.low);
      expect(issue.displayTier, DensityTier.critical);
    });

    test('the higher of the two signals wins', () {
      final issue = issueWith(reportCount: 6, severity: Severity.high);
      expect(issue.displayTier, DensityTier.high);
    });
  });

  group('IssueFilter', () {
    test('an empty filter matches everything', () {
      expect(IssueFilter.none.matches(issueWith()), isTrue);
      expect(IssueFilter.none.isEmpty, isTrue);
    });

    test('category filter excludes other categories', () {
      const filter = IssueFilter(categories: <DemandCategory>{DemandCategory.water});
      expect(filter.matches(issueWith(category: DemandCategory.water)), isTrue);
      expect(filter.matches(issueWith(category: DemandCategory.roads)), isFalse);
    });

    test('query searches title, ward and code', () {
      const filter = IssueFilter(query: 'bazaar');
      expect(filter.matches(issueWith(ward: 'Main Bazaar')), isTrue);
      expect(filter.matches(issueWith(ward: 'Ward 9')), isFalse);
    });

    test('filters combine as AND', () {
      const filter = IssueFilter(
        categories: <DemandCategory>{DemandCategory.water},
        severities: <Severity>{Severity.high},
      );
      expect(
        filter.matches(
          issueWith(category: DemandCategory.water, severity: Severity.high),
        ),
        isTrue,
      );
      expect(
        filter.matches(
          issueWith(category: DemandCategory.water, severity: Severity.low),
        ),
        isFalse,
      );
    });

    test('toggling a value adds then removes it', () {
      final once = IssueFilter.none.toggleCategory(DemandCategory.roads);
      expect(once.categories, <DemandCategory>{DemandCategory.roads});
      final twice = once.toggleCategory(DemandCategory.roads);
      expect(twice.categories, isEmpty);
    });

    test('activeCount counts every dimension in play', () {
      const filter = IssueFilter(
        query: 'water',
        categories: <DemandCategory>{DemandCategory.water},
        severities: <Severity>{Severity.high, Severity.critical},
      );
      expect(filter.activeCount, 4);
    });
  });

  group('IssueCluster', () {
    test('weight is total reports, not the number of sites', () {
      final cluster = IssueCluster(
        position: const LatLng(16.77, 77.13),
        issues: <MapIssue>[
          issueWith(reportCount: 30),
          issueWith(reportCount: 25),
        ],
      );
      expect(cluster.totalReports, 55);
      expect(cluster.tier, DensityTier.critical);
      expect(cluster.isSingle, isFalse);
    });
  });

  group('fixtures', () {
    test('every seeded record is labelled as seeded', () {
      for (final issue in MapFixtures.issues) {
        expect(issue.stamp.provenance.isSeeded, isTrue,
            reason: '${issue.code} must declare its provenance');
      }
    });

    test('no seeded record claims a precise device fix', () {
      for (final issue in MapFixtures.issues) {
        expect(issue.stamp.precision.isApproximate, isTrue,
            reason: '${issue.code} coordinates are hand-placed centroids');
      }
    });

    test('the corpus spans both the urban and rural provenances', () {
      final kinds =
          MapFixtures.issues.map((i) => i.stamp.provenance).toSet();
      expect(kinds, contains(Provenance.bbmpPatternDerived));
      expect(kinds, contains(Provenance.syntheticRural));
    });
  });
}
