import 'package:flutter/material.dart';

/// Where a record in this build actually came from.
///
/// `docs/SOURCES.md` is explicit that the shipped corpus is seeded and
/// labelled, and that coordinates are hand-placed approximate centroids.
/// Presenting any of it as verified field data would be dishonest, so every
/// screen that shows a figure shows its provenance beside it.
enum Provenance {
  /// Urban records, modelled on the published BBMP grievance distributions —
  /// category mix, ward distribution, text register and volume.
  bbmpPatternDerived(
    key: 'bbmp_pattern_derived',
    shortLabel: 'BBMP-pattern-derived',
    description: 'Modelled on the published BBMP Grievances 2020–2025 category '
        'mix, ward distribution and volume.',
    sourceName: 'BBMP Grievances 2020–2025',
    licence: 'Public Domain (Open Definition)',
    isSeeded: true,
  ),

  /// Rural records, generated from an incident model with per-block
  /// reporting-lag profiles.
  syntheticRural(
    key: 'synthetic_rural',
    shortLabel: 'Synthetic rural',
    description: 'Generated from an incident model with per-block reporting-lag '
        'profiles, calibrated to published district distributions.',
    sourceName: 'SHRUG 2.2 + NFHS-5 district baselines',
    licence: 'CC BY-NC-SA 4.0 (non-commercial) / CC BY 4.0',
    isSeeded: true,
  ),

  /// A report filed by the person using the app right now. Real input, even
  /// though it sits alongside seeded records.
  citizenReported(
    key: 'citizen_reported',
    shortLabel: 'Reported by you',
    description: 'Filed through JanMaang by a signed-in citizen.',
    sourceName: 'JanMaang',
    licence: '—',
    isSeeded: false,
  );

  const Provenance({
    required this.key,
    required this.shortLabel,
    required this.description,
    required this.sourceName,
    required this.licence,
    required this.isSeeded,
  });

  final String key;
  final String shortLabel;
  final String description;
  final String sourceName;
  final String licence;
  final bool isSeeded;

  static Provenance fromKey(String? value) => Provenance.values.firstWhere(
        (p) => p.key == value,
        orElse: () => Provenance.citizenReported,
      );
}

/// How precisely a record is located.
///
/// SHRUG's village polygons are not ingested in this build, so seeded records
/// carry a hand-placed centroid rather than a surveyed point. The map says so
/// rather than implying a precision it does not have.
enum LocationPrecision {
  /// A GPS fix from the reporting citizen's device.
  deviceFix('Device location'),

  /// Hand-placed approximate centroid for the village or ward.
  approximateCentroid('Approximate location'),

  /// Ward-level only, from a fuzzy name match.
  wardCentroid('Ward centroid');

  const LocationPrecision(this.label);

  final String label;

  bool get isApproximate => this != LocationPrecision.deviceFix;
}

/// The provenance line a screen shows beside a figure, e.g.
/// "Synthetic rural · Approximate location".
@immutable
class ProvenanceStamp {
  const ProvenanceStamp({
    required this.provenance,
    this.precision = LocationPrecision.approximateCentroid,
  });

  final Provenance provenance;
  final LocationPrecision precision;

  String get line => provenance == Provenance.citizenReported &&
          precision == LocationPrecision.deviceFix
      ? provenance.shortLabel
      : '${provenance.shortLabel} · ${precision.label}';
}
