import 'package:flutter/foundation.dart';

import '../../../shared/models/demand_enums.dart';

/// A single citizen report.
@immutable
class Demand {
  const Demand({
    required this.id,
    required this.code,
    required this.title,
    required this.reporterId,
    required this.category,
    required this.severity,
    required this.status,
    required this.createdAt,
    this.description = '',
    this.transcript = '',
    this.ward = '',
    this.district = '',
    this.latitude,
    this.longitude,
    this.distanceKm,
    this.photoUrls = const <String>[],
    this.clusterId,
    this.supporterCount = 0,
    this.rank,
    this.totalRanked,
    this.priorityScore = 0,
    this.scoreBreakdown = const <PriorityFactor>[],
    this.timeline = const <TimelineEvent>[],
    this.channel = ReportChannel.voice,
    this.updatedAt,
  });

  final String id;

  /// Human-readable public identifier, e.g. `YDG-WTR-0417`.
  final String code;
  final String title;
  final String description;
  final String transcript;
  final String reporterId;
  final DemandCategory category;
  final Severity severity;
  final DemandStatus status;
  final String ward;
  final String district;
  final double? latitude;
  final double? longitude;

  /// Straight-line distance from the citizen, used by the "Near You" list.
  final double? distanceKm;
  final List<String> photoUrls;
  final String? clusterId;
  final int supporterCount;
  final int? rank;
  final int? totalRanked;
  final double priorityScore;

  /// The five factors the priority engine exposes on "Why is this ranked #2?".
  final List<PriorityFactor> scoreBreakdown;
  final List<TimelineEvent> timeline;
  final ReportChannel channel;
  final DateTime createdAt;
  final DateTime? updatedAt;

  bool get hasLocation => latitude != null && longitude != null;

  bool get isTopRanked => rank == 1;

  Demand copyWith({
    DemandStatus? status,
    String? clusterId,
    int? supporterCount,
    int? rank,
    List<TimelineEvent>? timeline,
    List<String>? photoUrls,
    double? latitude,
    double? longitude,
  }) {
    return Demand(
      id: id,
      code: code,
      title: title,
      description: description,
      transcript: transcript,
      reporterId: reporterId,
      category: category,
      severity: severity,
      status: status ?? this.status,
      ward: ward,
      district: district,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      distanceKm: distanceKm,
      photoUrls: photoUrls ?? this.photoUrls,
      clusterId: clusterId ?? this.clusterId,
      supporterCount: supporterCount ?? this.supporterCount,
      rank: rank ?? this.rank,
      totalRanked: totalRanked,
      priorityScore: priorityScore,
      scoreBreakdown: scoreBreakdown,
      timeline: timeline ?? this.timeline,
      channel: channel,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Demand && other.id == id);

  @override
  int get hashCode => id.hashCode;
}

/// One bar on the "Why is this ranked #2?" card. [score] is 0–100.
@immutable
class PriorityFactor {
  const PriorityFactor({
    required this.label,
    required this.score,
    this.explanation = '',
  });

  final String label;
  final int score;
  final String explanation;
}

/// One node on the status timeline.
@immutable
class TimelineEvent {
  const TimelineEvent({
    required this.status,
    required this.state,
    this.note = '',
    this.at,
  });

  final DemandStatus status;
  final TimelineState state;
  final String note;
  final DateTime? at;
}

enum TimelineState { complete, active, upcoming }
