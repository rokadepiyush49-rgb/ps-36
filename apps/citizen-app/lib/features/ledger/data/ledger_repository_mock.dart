import '../../../shared/models/demand_enums.dart';
import '../domain/ledger_entry.dart';
import '../domain/ledger_repository.dart';

class MockLedgerRepository implements LedgerRepository {
  static const _latency = Duration(milliseconds: 500);

  static final _entries = <LedgerEntry>[
    LedgerEntry(
      id: 'ledger-1',
      demandCode: 'YDG-LGT-0044',
      title: 'Streetlight Installation',
      category: DemandCategory.lighting,
      amount: 340000,
      stage: DemandStatus.citizenVerified,
      department: 'Panchayat Raj Engineering',
      ward: 'Ward 2',
      fiscalYear: 'FY 2026-27',
      verifiedByCitizens: true,
      verifierCount: 34,
      at: DateTime(2026, 8, 2),
    ),
    LedgerEntry(
      id: 'ledger-2',
      demandCode: 'YDG-WTR-0301',
      title: 'Borewell Recharge & Handpump Repair',
      category: DemandCategory.water,
      amount: 1250000,
      stage: DemandStatus.inProgress,
      department: 'Rural Drinking Water Supply',
      ward: 'Ward 7',
      fiscalYear: 'FY 2026-27',
      verifierCount: 12,
      at: DateTime(2026, 7, 28),
    ),
    LedgerEntry(
      id: 'ledger-3',
      demandCode: 'YDG-ROD-0221',
      title: 'Approach Road Resurfacing',
      category: DemandCategory.roads,
      amount: 2870000,
      stage: DemandStatus.funded,
      department: 'Public Works Department',
      ward: 'Main Bazaar',
      fiscalYear: 'FY 2026-27',
      at: DateTime(2026, 8, 12),
    ),
    LedgerEntry(
      id: 'ledger-4',
      demandCode: 'YDG-SAN-0155',
      title: 'Drain Desilting — Market Block',
      category: DemandCategory.sanitation,
      amount: 480000,
      stage: DemandStatus.citizenVerified,
      department: 'Municipal Sanitation',
      ward: 'Ward 1',
      fiscalYear: 'FY 2026-27',
      verifiedByCitizens: true,
      verifierCount: 51,
      at: DateTime(2026, 6, 30),
    ),
    LedgerEntry(
      id: 'ledger-5',
      demandCode: 'YDG-EDU-0090',
      title: 'Anganwadi Roof Repair',
      category: DemandCategory.education,
      amount: 620000,
      stage: DemandStatus.inProgress,
      department: 'Women & Child Development',
      ward: 'Sector B',
      fiscalYear: 'FY 2026-27',
      at: DateTime(2026, 8, 5),
    ),
  ];

  @override
  Stream<List<LedgerEntry>> watchEntries({String? district}) async* {
    await Future<void>.delayed(_latency);
    yield _entries;
  }

  @override
  Future<LedgerSummary> getSummary({String? district}) async {
    await Future<void>.delayed(_latency);
    final total = _entries.fold<int>(0, (sum, e) => sum + e.amount);
    return LedgerSummary(
      totalAllocated: total,
      projectsFunded: _entries.length,
      citizenVerified: _entries.where((e) => e.verifiedByCitizens).length,
      pendingVerification:
          _entries.where((e) => e.stage == DemandStatus.inProgress).length,
    );
  }
}
