import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/contributor.dart';

abstract interface class LeaderboardRepository {
  Future<List<Contributor>> topContributors(LeaderboardPeriod period);
}

/// Seeded leaderboard, consistent with the synthetic corpus.
class MockLeaderboardRepository implements LeaderboardRepository {
  static const _latency = Duration(milliseconds: 450);

  static const _base = <Contributor>[
    Contributor(
      id: 'c-1',
      displayName: 'Lakshmi Devi',
      ward: 'Ward 4',
      rank: 1,
      previousRank: 3,
      reportsFiled: 34,
      reportsVerified: 29,
      demandsJoined: 61,
      verificationsGiven: 22,
      badges: <ContributorBadge>[
        ContributorBadge.wardLead,
        ContributorBadge.verifier,
      ],
    ),
    Contributor(
      id: 'c-2',
      displayName: 'Mahesh Kumar',
      ward: 'Main Bazaar',
      rank: 2,
      previousRank: 1,
      reportsFiled: 41,
      reportsVerified: 25,
      demandsJoined: 38,
      verificationsGiven: 17,
      badges: <ContributorBadge>[ContributorBadge.persistent],
    ),
    Contributor(
      id: 'mock-uid',
      displayName: 'Rajesh',
      ward: 'Ward 4',
      rank: 3,
      previousRank: 7,
      reportsFiled: 22,
      reportsVerified: 18,
      demandsJoined: 44,
      verificationsGiven: 15,
      isCurrentUser: true,
      badges: <ContributorBadge>[
        ContributorBadge.connector,
        ContributorBadge.firstVoice,
      ],
    ),
    Contributor(
      id: 'c-4',
      displayName: 'Sunita Patil',
      ward: 'Ward 7',
      rank: 4,
      previousRank: 4,
      reportsFiled: 19,
      reportsVerified: 16,
      demandsJoined: 30,
      verificationsGiven: 13,
      badges: <ContributorBadge>[ContributorBadge.verifier],
    ),
    Contributor(
      id: 'c-5',
      displayName: 'Imran Shaikh',
      ward: 'Sector B',
      rank: 5,
      previousRank: 2,
      reportsFiled: 27,
      reportsVerified: 12,
      demandsJoined: 21,
      verificationsGiven: 9,
    ),
    Contributor(
      id: 'c-6',
      displayName: 'Anita Rao',
      ward: 'Ward 1',
      rank: 6,
      previousRank: 9,
      reportsFiled: 14,
      reportsVerified: 11,
      demandsJoined: 26,
      verificationsGiven: 8,
      badges: <ContributorBadge>[ContributorBadge.connector],
    ),
    Contributor(
      id: 'c-7',
      displayName: 'Vijay Naik',
      ward: 'Ward 9',
      rank: 7,
      previousRank: 5,
      reportsFiled: 16,
      reportsVerified: 9,
      demandsJoined: 18,
      verificationsGiven: 6,
    ),
    Contributor(
      id: 'c-8',
      displayName: 'Fatima Begum',
      ward: 'Ward 2',
      rank: 8,
      previousRank: 8,
      reportsFiled: 11,
      reportsVerified: 8,
      demandsJoined: 15,
      verificationsGiven: 5,
    ),
    Contributor(
      id: 'c-9',
      displayName: 'Ravi Shankar',
      ward: 'Ward 3',
      rank: 9,
      previousRank: 12,
      reportsFiled: 9,
      reportsVerified: 6,
      demandsJoined: 12,
      verificationsGiven: 4,
    ),
    Contributor(
      id: 'c-10',
      displayName: 'Kavita Joshi',
      ward: 'Main Bazaar',
      rank: 10,
      previousRank: 6,
      reportsFiled: 8,
      reportsVerified: 5,
      demandsJoined: 10,
      verificationsGiven: 3,
    ),
  ];

  @override
  Future<List<Contributor>> topContributors(LeaderboardPeriod period) async {
    await Future<void>.delayed(_latency);

    // Longer windows accumulate more of everything; the shape of the ranking
    // is period-dependent rather than a single fixed list.
    final multiplier = switch (period) {
      LeaderboardPeriod.quarter => 1,
      LeaderboardPeriod.year => 3,
      LeaderboardPeriod.allTime => 6,
    };
    if (multiplier == 1) return _base;

    final scaled = _base
        .map(
          (c) => Contributor(
            id: c.id,
            displayName: c.displayName,
            ward: c.ward,
            rank: c.rank,
            previousRank: c.previousRank,
            reportsFiled: c.reportsFiled * multiplier,
            reportsVerified: c.reportsVerified * multiplier,
            demandsJoined: c.demandsJoined * multiplier,
            verificationsGiven: c.verificationsGiven * multiplier,
            isCurrentUser: c.isCurrentUser,
            badges: c.badges,
          ),
        )
        .toList()
      ..sort((a, b) => b.impactScore.compareTo(a.impactScore));

    return <Contributor>[
      for (var i = 0; i < scaled.length; i++)
        Contributor(
          id: scaled[i].id,
          displayName: scaled[i].displayName,
          ward: scaled[i].ward,
          rank: i + 1,
          previousRank: scaled[i].rank,
          reportsFiled: scaled[i].reportsFiled,
          reportsVerified: scaled[i].reportsVerified,
          demandsJoined: scaled[i].demandsJoined,
          verificationsGiven: scaled[i].verificationsGiven,
          isCurrentUser: scaled[i].isCurrentUser,
          badges: scaled[i].badges,
        ),
    ];
  }
}

final leaderboardRepositoryProvider = Provider<LeaderboardRepository>(
  (ref) => MockLeaderboardRepository(),
);

final leaderboardPeriodProvider = NotifierProvider<_Period, LeaderboardPeriod>(
  _Period.new,
);

class _Period extends Notifier<LeaderboardPeriod> {
  @override
  LeaderboardPeriod build() => LeaderboardPeriod.quarter;

  void set(LeaderboardPeriod value) => state = value;
}

final leaderboardProvider =
    FutureProvider.autoDispose<List<Contributor>>((ref) {
  final period = ref.watch(leaderboardPeriodProvider);
  return ref.watch(leaderboardRepositoryProvider).topContributors(period);
});
