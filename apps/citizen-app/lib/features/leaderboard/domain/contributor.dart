import 'package:characters/characters.dart';
import 'package:flutter/foundation.dart';

/// A citizen's standing in the community leaderboard.
///
/// Every metric here is one the shipped corpus can actually support — reports
/// filed, reports that were verified, demands joined, verifications performed.
/// Nothing depends on a closure timestamp, because `docs/SOURCES.md` is clear
/// the BBMP schema has none.
@immutable
class Contributor {
  const Contributor({
    required this.id,
    required this.displayName,
    required this.ward,
    required this.rank,
    required this.previousRank,
    required this.reportsFiled,
    required this.reportsVerified,
    required this.demandsJoined,
    required this.verificationsGiven,
    this.avatarUrl,
    this.isCurrentUser = false,
    this.badges = const <ContributorBadge>[],
  });

  final String id;
  final String displayName;
  final String ward;
  final int rank;

  /// Rank in the previous period, so the list can show movement.
  final int previousRank;
  final int reportsFiled;

  /// Reports that a field officer or fellow citizen confirmed.
  final int reportsVerified;
  final int demandsJoined;

  /// Times this person closed the loop on someone else's demand.
  final int verificationsGiven;
  final String? avatarUrl;
  final bool isCurrentUser;
  final List<ContributorBadge> badges;

  /// Positive means they climbed.
  int get movement => previousRank - rank;

  /// Participation score. Weighted toward verification because confirming
  /// someone else's fix is the scarcest and most valuable civic act here —
  /// filing is easy, checking is not.
  int get impactScore =>
      reportsFiled * 3 +
      reportsVerified * 5 +
      demandsJoined * 1 +
      verificationsGiven * 8;

  String get initials {
    final parts = displayName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.take(1).join();
    return (parts.first.characters.take(1).join() +
            parts.last.characters.take(1).join())
        .toUpperCase();
  }
}

/// A recognition a contributor has earned.
enum ContributorBadge {
  firstVoice('First Voice', 'Filed the first report in their ward'),
  verifier('Verifier', 'Confirmed ten completed works'),
  connector('Connector', 'Joined twenty demands raised by neighbours'),
  persistent('Persistent', 'Followed a demand from report to fix'),
  wardLead('Ward Lead', 'Highest impact score in their ward');

  const ContributorBadge(this.label, this.description);

  final String label;
  final String description;
}

/// The period a leaderboard covers.
enum LeaderboardPeriod {
  quarter('This quarter'),
  year('This year'),
  allTime('All time');

  const LeaderboardPeriod(this.label);

  final String label;
}
