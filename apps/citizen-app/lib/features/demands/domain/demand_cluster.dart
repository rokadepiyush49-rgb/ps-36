import 'package:flutter/foundation.dart';

import '../../../shared/models/demand_enums.dart';

/// A group of near-identical reports merged by the clustering function —
/// the "You are not alone." screen.
@immutable
class DemandCluster {
  const DemandCluster({
    required this.id,
    required this.code,
    required this.title,
    required this.category,
    required this.reportCount,
    required this.peopleAffected,
    this.mergedDuplicates = 0,
    this.habitationsAffected = 0,
    this.demandIds = const <String>[],
    this.rank,
    this.totalRanked,
    this.centroidLat,
    this.centroidLng,
    this.hasJoined = false,
  });

  final String id;
  final String code;
  final String title;
  final DemandCategory category;

  /// "41 people have reported the same issue in this area."
  final int reportCount;

  /// "4,281 people affected"
  final int peopleAffected;

  /// "6 duplicate reports merged"
  final int mergedDuplicates;

  /// "7 habitations affected"
  final int habitationsAffected;
  final List<String> demandIds;
  final int? rank;
  final int? totalRanked;
  final double? centroidLat;
  final double? centroidLng;
  final bool hasJoined;

  DemandCluster copyWith({bool? hasJoined, int? reportCount}) => DemandCluster(
        id: id,
        code: code,
        title: title,
        category: category,
        reportCount: reportCount ?? this.reportCount,
        peopleAffected: peopleAffected,
        mergedDuplicates: mergedDuplicates,
        habitationsAffected: habitationsAffected,
        demandIds: demandIds,
        rank: rank,
        totalRanked: totalRanked,
        centroidLat: centroidLat,
        centroidLng: centroidLng,
        hasJoined: hasJoined ?? this.hasJoined,
      );
}
