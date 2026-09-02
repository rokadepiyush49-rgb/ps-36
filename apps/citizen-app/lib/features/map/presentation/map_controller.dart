import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../shared/models/demand_enums.dart';

import '../data/map_fixtures.dart';
import '../domain/map_issue.dart';

/// Every issue in the corpus, before filtering.
final allIssuesProvider = Provider<List<MapIssue>>((ref) => MapFixtures.issues);

/// Shared filter state. The Track list and the map both read it, so narrowing
/// one narrows the other.
class IssueFilterController extends Notifier<IssueFilter> {
  @override
  IssueFilter build() => IssueFilter.none;

  void setQuery(String value) => state = state.copyWith(query: value);

  void toggleCategory(DemandCategory value) =>
      state = state.toggleCategory(value);

  void toggleSeverity(Severity value) =>
      state = state.toggleSeverity(value);

  void toggleStatus(DemandStatus value) =>
      state = state.toggleStatus(value);

  void clear() => state = IssueFilter.none;
}

final issueFilterProvider =
    NotifierProvider<IssueFilterController, IssueFilter>(
  IssueFilterController.new,
);

/// Issues surviving the current filter.
final filteredIssuesProvider = Provider<List<MapIssue>>((ref) {
  final filter = ref.watch(issueFilterProvider);
  final all = ref.watch(allIssuesProvider);
  return all.where(filter.matches).toList();
});

/// The issue currently selected on the map, if any.
final selectedIssueProvider = NotifierProvider<SelectedIssue, String?>(
  SelectedIssue.new,
);

class SelectedIssue extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? id) => state = id;

  void clear() => state = null;
}

/// Groups issues that are too close together to read separately at the current
/// zoom.
///
/// A grid-based pass rather than a full hierarchical clusterer: at district
/// scale the corpus is small, and grid clustering is stable frame to frame,
/// which matters because unstable clusters make markers jump around while the
/// user pans.
abstract final class IssueClusterer {
  /// Degrees of latitude per cell at a given zoom.
  ///
  /// 96px rather than the marker's own 64px: cells only guarantee that two
  /// markers are not in the *same* cell, so a cell exactly one marker wide
  /// still lets neighbours in adjacent cells overlap. The extra headroom keeps
  /// the largest marker plus its count badge clear of the next one.
  static const clusterCellPx = 96.0;

  static double cellSize(double zoom) =>
      clusterCellPx / (256 * math.pow(2, zoom) / 360);

  static List<IssueCluster> cluster(List<MapIssue> issues, double zoom) {
    // Past this zoom the user has asked to see individual sites.
    if (zoom >= 14) {
      return issues
          .map((i) => IssueCluster(position: i.position, issues: <MapIssue>[i]))
          .toList();
    }

    final size = cellSize(zoom);
    if (size <= 0) {
      return issues
          .map((i) => IssueCluster(position: i.position, issues: <MapIssue>[i]))
          .toList();
    }

    final buckets = <String, List<MapIssue>>{};
    for (final issue in issues) {
      final row = (issue.position.latitude / size).floor();
      final col = (issue.position.longitude / size).floor();
      buckets.putIfAbsent('$row:$col', () => <MapIssue>[]).add(issue);
    }

    return buckets.values.map((group) {
      if (group.length == 1) {
        return IssueCluster(position: group.first.position, issues: group);
      }
      // Weight the centroid by report count so the marker sits over the
      // heaviest part of the cluster rather than its geometric middle.
      var totalWeight = 0;
      var lat = 0.0;
      var lng = 0.0;
      for (final issue in group) {
        final weight = math.max(1, issue.reportCount);
        totalWeight += weight;
        lat += issue.position.latitude * weight;
        lng += issue.position.longitude * weight;
      }
      return IssueCluster(
        position: LatLng(lat / totalWeight, lng / totalWeight),
        issues: group,
      );
    }).toList();
  }
}

/// Camera state the map screen drives and the Track list can command.
///
/// Named [MapViewport] rather than `MapCamera` because flutter_map exports a
/// `MapCamera` of its own; keeping them distinct avoids an import collision at
/// every call site.
@immutable
class MapViewport {
  const MapViewport({required this.centre, required this.zoom});

  final LatLng centre;
  final double zoom;

  static const initial = MapViewport(centre: MapFixtures.yadgir, zoom: 12.5);
}

class MapCameraController extends Notifier<MapViewport> {
  @override
  MapViewport build() => MapViewport.initial;

  /// Fly to an issue and select it — used when the citizen taps a row in the
  /// Track list and expects the map to follow.
  void focusOn(MapIssue issue, {double zoom = 15}) {
    state = MapViewport(centre: issue.position, zoom: zoom);
    ref.read(selectedIssueProvider.notifier).select(issue.id);
  }

  void moveTo(LatLng centre, double zoom) =>
      state = MapViewport(centre: centre, zoom: zoom);

  void reset() => state = MapViewport.initial;
}

final mapCameraProvider = NotifierProvider<MapCameraController, MapViewport>(
  MapCameraController.new,
);
