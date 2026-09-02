import 'package:flutter/foundation.dart';

import '../../../shared/models/demand_enums.dart';

/// What the report screen is holding before it becomes a Demand.
@immutable
class ReportDraft {
  const ReportDraft({
    this.transcript = '',
    this.channel = ReportChannel.voice,
    this.analysis,
    this.latitude,
    this.longitude,
    this.locationLabel = '',
    this.photoPaths = const <String>[],
  });

  final String transcript;
  final ReportChannel channel;

  /// Filled in by the `analyzeReport` Cloud Function (Gemini).
  final ReportAnalysis? analysis;
  final double? latitude;
  final double? longitude;
  final String locationLabel;
  final List<String> photoPaths;

  bool get hasTranscript => transcript.trim().isNotEmpty;

  bool get hasLocation => latitude != null && longitude != null;

  /// The report can be submitted once we know what it is and where it is.
  bool get canSubmit => hasTranscript && analysis != null && hasLocation;

  ReportDraft copyWith({
    String? transcript,
    ReportChannel? channel,
    ReportAnalysis? analysis,
    double? latitude,
    double? longitude,
    String? locationLabel,
    List<String>? photoPaths,
  }) =>
      ReportDraft(
        transcript: transcript ?? this.transcript,
        channel: channel ?? this.channel,
        analysis: analysis ?? this.analysis,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        locationLabel: locationLabel ?? this.locationLabel,
        photoPaths: photoPaths ?? this.photoPaths,
      );
}

/// Structured output of the server-side Gemini call. The three cards on the
/// report screen render exactly these fields.
@immutable
class ReportAnalysis {
  const ReportAnalysis({
    required this.category,
    required this.severity,
    required this.title,
    this.mentionedLocation = '',
    this.summary = '',
    this.detectedLanguage = 'en',
  });

  final DemandCategory category;
  final Severity severity;
  final String title;

  /// "Location Mentioned" — what the citizen said, before they pin it exactly.
  final String mentionedLocation;
  final String summary;
  final String detectedLanguage;
}
