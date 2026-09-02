import 'package:flutter/foundation.dart';

/// One dataset, exactly as `docs/SOURCES.md` records it.
@immutable
class DataSource {
  const DataSource({
    required this.index,
    required this.name,
    required this.url,
    required this.licence,
    required this.feeds,
    this.status = SourceStatus.inUse,
    this.note = '',
  });

  final int index;
  final String name;
  final String url;
  final String licence;

  /// What this dataset actually drives in the product.
  final String feeds;
  final SourceStatus status;
  final String note;

  /// Licences that restrict commercial use need to be visible, not buried.
  bool get isNonCommercial => licence.toLowerCase().contains('non-commercial');
}

enum SourceStatus {
  inUse('In use'),
  notIngested('Not ingested'),
  optional('Optional');

  const SourceStatus(this.label);

  final String label;
}

/// A dataset that was considered and rejected, with the reason.
@immutable
class RejectedSource {
  const RejectedSource({required this.name, required this.reason});

  final String name;
  final String reason;
}

/// A known constraint that shaped the product.
@immutable
class Landmine {
  const Landmine({
    required this.title,
    required this.body,
    required this.status,
  });

  final String title;
  final String body;

  /// Where this build actually stands on it.
  final String status;
}
