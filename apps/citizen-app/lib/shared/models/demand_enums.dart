import 'package:flutter/material.dart';

/// The seven-stage lifecycle a demand moves through, taken from the
/// "Status Timeline" on the Stitch *Track Demand — Transparency Flow* screen.
enum DemandStatus {
  reported('Reported'),
  verified('Verified'),
  clustered('Clustered'),
  prioritised('Prioritised'),
  funded('Funded'),
  inProgress('In Progress'),
  citizenVerified('Citizen Verified');

  const DemandStatus(this.label);

  final String label;

  int get stage => index;

  bool isBefore(DemandStatus other) => index < other.index;

  static DemandStatus fromName(String? value) => DemandStatus.values.firstWhere(
        (s) => s.name == value,
        orElse: () => DemandStatus.reported,
      );
}

/// Categories seen across the Stitch screens (water, roads, lighting) plus the
/// rest of the civic set the district console covers.
enum DemandCategory {
  water('Water', 'WTR', Icons.water_drop_outlined, Icons.water_drop),
  roads('Roads', 'ROD', Icons.add_road_outlined, Icons.add_road),
  lighting('Lighting', 'LGT', Icons.lightbulb_outline, Icons.lightbulb),
  sanitation('Sanitation', 'SAN', Icons.cleaning_services_outlined,
      Icons.cleaning_services),
  health('Health', 'HLT', Icons.local_hospital_outlined, Icons.local_hospital),
  education('Education', 'EDU', Icons.school_outlined, Icons.school),
  electricity('Electricity', 'ELC', Icons.bolt_outlined, Icons.bolt),
  transport('Transport', 'TRN', Icons.directions_bus_outlined, Icons.directions_bus),
  other('Other', 'OTH', Icons.category_outlined, Icons.category);

  const DemandCategory(this.label, this.code, this.icon, this.filledIcon);

  final String label;
  final String code;
  final IconData icon;
  final IconData filledIcon;

  static DemandCategory fromName(String? value) => DemandCategory.values.firstWhere(
        (c) => c.name == value,
        orElse: () => DemandCategory.other,
      );
}

/// Assessed severity. The Stitch report screen renders `high` as an
/// error-container badge reading "HIGH PRIORITY".
enum Severity {
  low('Low Priority'),
  medium('Medium Priority'),
  high('High Priority'),
  critical('Critical');

  const Severity(this.label);

  final String label;

  static Severity fromName(String? value) => Severity.values.firstWhere(
        (s) => s.name == value,
        orElse: () => Severity.medium,
      );
}

/// How the citizen filed the report — the four entry points on the Home hero card.
enum ReportChannel { voice, text, photo, location }

/// Who performed a verification.
enum VerificationKind { citizen, field }
