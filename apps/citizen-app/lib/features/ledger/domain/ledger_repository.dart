import 'ledger_entry.dart';

abstract interface class LedgerRepository {
  Stream<List<LedgerEntry>> watchEntries({String? district});

  Future<LedgerSummary> getSummary({String? district});
}
