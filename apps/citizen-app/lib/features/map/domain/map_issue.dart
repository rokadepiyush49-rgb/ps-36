import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/theme/janmaang_colors.dart';
import '../../../shared/models/demand_enums.dart';
import '../../../shared/models/provenance.dart';

/// A point on the map: one location, and everything reported about it.
///
/// Multiple citizens reporting the same handpump collapse into a single
/// [MapIssue] with a [reportCount] above one. That count — not the number of
/// rows in the database — is what drives the pin's tier, size and colour.
@immutable
class MapIssue {
  const MapIssue({
    required this.id,
    required this.code,
    required this.title,
    required this.category,
    required this.severity,
    required this.status,
    required this.position,
    required this.reportCount,
    required this.reportedAt,
    required this.stamp,
    this.description = '',
    this.ward = '',
    this.district = '',
    this.peopleAffected = 0,
    this.photoUrl,
    this.demandId,
  });

  final String id;
  final String code;
  final String title;
  final String description;
  final DemandCategory category;
  final Severity severity;
  final DemandStatus status;
  final LatLng position;

  /// How many citizens have reported this same location.
  final int reportCount;
  final DateTime reportedAt;
  final ProvenanceStamp stamp;
  final String ward;
  final String district;
  final int peopleAffected;
  final String? photoUrl;

  /// Set when the pin corresponds to a demand the citizen can open.
  final String? demandId;

  /// Density tier, from the report count. Drives colour, size and ring weight.
  DensityTier get tier => DensityTier.forReports(reportCount);

  /// Severity can escalate a sparsely-reported but dangerous issue. A single
  /// critical report should not read as "low" just because nobody else has
  /// filed yet.
  DensityTier get displayTier {
    final byReports = tier;
    final bySeverity = switch (severity) {
      Severity.critical => DensityTier.critical,
      Severity.high => DensityTier.high,
      Severity.medium => DensityTier.moderate,
      Severity.low => DensityTier.low,
    };
    return byReports.index >= bySeverity.index ? byReports : bySeverity;
  }

  bool get isResolved =>
      status == DemandStatus.citizenVerified || status == DemandStatus.funded;
}

/// Active filter state for the map and the Track list. They share it, so
/// narrowing the list narrows the map and vice versa.
@immutable
class IssueFilter {
  const IssueFilter({
    this.query = '',
    this.categories = const <DemandCategory>{},
    this.severities = const <Severity>{},
    this.statuses = const <DemandStatus>{},
  });

  final String query;
  final Set<DemandCategory> categories;
  final Set<Severity> severities;
  final Set<DemandStatus> statuses;

  bool get isEmpty =>
      query.isEmpty &&
      categories.isEmpty &&
      severities.isEmpty &&
      statuses.isEmpty;

  int get activeCount =>
      categories.length +
      severities.length +
      statuses.length +
      (query.isEmpty ? 0 : 1);

  bool matches(MapIssue issue) {
    if (categories.isNotEmpty && !categories.contains(issue.category)) {
      return false;
    }
    if (severities.isNotEmpty && !severities.contains(issue.severity)) {
      return false;
    }
    if (statuses.isNotEmpty && !statuses.contains(issue.status)) return false;

    if (query.isNotEmpty) {
      final q = query.toLowerCase();
      final haystack =
          '${issue.title} ${issue.description} ${issue.ward} ${issue.code}'
              .toLowerCase();
      if (!haystack.contains(q)) return false;
    }
    return true;
  }

  IssueFilter copyWith({
    String? query,
    Set<DemandCategory>? categories,
    Set<Severity>? severities,
    Set<DemandStatus>? statuses,
  }) =>
      IssueFilter(
        query: query ?? this.query,
        categories: categories ?? this.categories,
        severities: severities ?? this.severities,
        statuses: statuses ?? this.statuses,
      );

  IssueFilter toggleCategory(DemandCategory value) => copyWith(
        categories: <DemandCategory>{...categories}..toggle(value),
      );

  IssueFilter toggleSeverity(Severity value) => copyWith(
        severities: <Severity>{...severities}..toggle(value),
      );

  IssueFilter toggleStatus(DemandStatus value) => copyWith(
        statuses: <DemandStatus>{...statuses}..toggle(value),
      );

  static const none = IssueFilter();
}

extension<T> on Set<T> {
  void toggle(T value) => contains(value) ? remove(value) : add(value);
}

/// A group of nearby issues, collapsed at low zoom so the map stays readable.
@immutable
class IssueCluster {
  const IssueCluster({
    required this.position,
    required this.issues,
  });

  final LatLng position;
  final List<MapIssue> issues;

  bool get isSingle => issues.length == 1;

  MapIssue get first => issues.first;

  /// A cluster's weight is the sum of the reports inside it, not the number of
  /// pins — twenty places with one report each is a different thing from one
  /// place with twenty.
  int get totalReports =>
      issues.fold<int>(0, (sum, issue) => sum + issue.reportCount);

  DensityTier get tier => DensityTier.forReports(totalReports);
}
