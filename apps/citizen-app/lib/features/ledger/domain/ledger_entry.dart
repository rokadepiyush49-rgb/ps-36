import 'package:flutter/foundation.dart';

import '../../../shared/models/demand_enums.dart';

/// One line of the public ledger: what was demanded, what it cost, who paid,
/// and whether citizens confirmed it actually happened.
@immutable
class LedgerEntry {
  const LedgerEntry({
    required this.id,
    required this.demandCode,
    required this.title,
    required this.category,
    required this.amount,
    required this.stage,
    required this.at,
    this.department = '',
    this.ward = '',
    this.fiscalYear = '',
    this.verifiedByCitizens = false,
    this.verifierCount = 0,
  });

  final String id;
  final String demandCode;
  final String title;
  final DemandCategory category;

  /// Allocation in rupees.
  final int amount;
  final DemandStatus stage;
  final String department;
  final String ward;
  final String fiscalYear;
  final bool verifiedByCitizens;
  final int verifierCount;
  final DateTime at;
}

/// Header figures on the ledger screen.
@immutable
class LedgerSummary {
  const LedgerSummary({
    required this.totalAllocated,
    required this.projectsFunded,
    required this.citizenVerified,
    required this.pendingVerification,
  });

  final int totalAllocated;
  final int projectsFunded;
  final int citizenVerified;
  final int pendingVerification;
}
