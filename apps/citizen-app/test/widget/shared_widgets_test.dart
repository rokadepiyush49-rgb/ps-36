import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:janmaang/core/theme/app_theme.dart';
import 'package:janmaang/features/demands/domain/demand.dart';
import 'package:janmaang/shared/models/demand_enums.dart';
import 'package:janmaang/shared/widgets/jm_bottom_nav.dart';
import 'package:janmaang/shared/widgets/jm_metric_bar.dart';
import 'package:janmaang/shared/widgets/jm_rank_badge.dart';
import 'package:janmaang/shared/widgets/jm_stat_tile.dart';
import 'package:janmaang/shared/widgets/jm_status_chip.dart';
import 'package:janmaang/shared/widgets/jm_timeline.dart';

Widget wrap(Widget child) => MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );

void main() {
  testWidgets('stat tile counts up to the Indian-grouped figure',
      (tester) async {
    await tester.pumpWidget(
      wrap(const JmStatTile(value: 4281, label: 'People Affected')),
    );

    // Mid-flight it shows an intermediate value, not the final one.
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('4,281'), findsNothing);

    await tester.pumpAndSettle();
    expect(find.text('4,281'), findsOneWidget);
    expect(find.text('People Affected'), findsOneWidget);
  });

  testWidgets('rank badge marks #1 with a star and others with a trend arrow',
      (tester) async {
    await tester.pumpWidget(wrap(const JmRankBadge(rank: 1)));
    expect(find.text('Rank #1'), findsOneWidget);
    expect(find.byIcon(Icons.star), findsOneWidget);

    await tester.pumpWidget(wrap(const JmRankBadge(rank: 2, total: 214)));
    expect(find.text('Ranked #2 of 214'), findsOneWidget);
    expect(find.byIcon(Icons.trending_up), findsOneWidget);
  });

  testWidgets('status chips read the way the designs label them',
      (tester) async {
    await tester.pumpWidget(
      wrap(
        Column(
          children: <Widget>[
            JmStatusChip.forStatus(DemandStatus.citizenVerified),
            JmStatusChip.forStatus(DemandStatus.verified),
            JmStatusChip.forSeverity(Severity.high),
          ],
        ),
      ),
    );
    expect(find.text('Funded & Fixed'), findsOneWidget);
    expect(find.text('Under Review'), findsOneWidget);
    expect(find.text('HIGH PRIORITY'), findsOneWidget);
  });

  testWidgets('metric bar animates to the score and stays accessible',
      (tester) async {
    await tester.pumpWidget(
      wrap(const JmMetricBar(label: 'People affected', score: 94)),
    );
    await tester.pumpAndSettle();

    expect(find.text('People affected'), findsOneWidget);
    expect(find.text('94'), findsOneWidget);

    final indicator = tester.widget<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator),
    );
    expect(indicator.value, closeTo(0.94, 0.001));
  });

  testWidgets('timeline shows completed, active and upcoming nodes',
      (tester) async {
    await tester.pumpWidget(
      wrap(
        JmTimeline(
          events: <TimelineEvent>[
            TimelineEvent(
              status: DemandStatus.reported,
              state: TimelineState.complete,
              at: DateTime(2026, 6, 12),
            ),
            const TimelineEvent(
              status: DemandStatus.prioritised,
              state: TimelineState.active,
              note: 'Ranked #2 for upcoming block grant.',
            ),
            const TimelineEvent(
              status: DemandStatus.funded,
              state: TimelineState.upcoming,
            ),
          ],
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Reported'), findsOneWidget);
    expect(find.text('12 Jun 2026'), findsOneWidget);
    expect(find.byIcon(Icons.check), findsOneWidget);
    expect(
      find.text('Ranked #2 for upcoming block grant.'),
      findsOneWidget,
    );
    expect(find.text('Funded'), findsOneWidget);
  });

  testWidgets('bottom nav shows five destinations with Report raised',
      (tester) async {
    var selected = -1;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          bottomNavigationBar: JmBottomNav(
            currentIndex: 0,
            onDestinationSelected: (i) => selected = i,
          ),
        ),
      ),
    );

    for (final label in <String>['Home', 'Track', 'Report', 'Ranks', 'Ledger']) {
      expect(find.text(label), findsOneWidget, reason: '$label destination');
    }

    // Report sits in the middle as the raised action.
    expect(JmBottomNav.destinations.length, 5);
    expect(JmBottomNav.destinations[2].label, 'Report');
    expect(JmBottomNav.destinations[2].raised, isTrue);
    expect(
      JmBottomNav.destinations.where((d) => d.raised).length,
      1,
      reason: 'exactly one raised action',
    );

    await tester.tap(find.text('Ledger'));
    expect(selected, 4);

    await tester.tap(find.text('Ranks'));
    expect(selected, 3);
  });
}
