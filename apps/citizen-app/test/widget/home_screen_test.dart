import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:janmaang/features/home/presentation/home_screen.dart';

/// Home lays out differently either side of the 768px breakpoint, and the wide
/// path once crashed because it asked a shrink-wrapped viewport for its
/// intrinsic height. Both widths are exercised so that cannot regress.
void main() {
  Future<void> pumpHome(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: HomeScreen())),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
  }

  testWidgets('builds on a narrow phone layout', (tester) async {
    await pumpHome(tester, const Size(390, 2400));

    expect(tester.takeException(), isNull);
    expect(find.text('Make your community heard.'), findsOneWidget);
  });

  testWidgets('builds on a wide tablet layout', (tester) async {
    await pumpHome(tester, const Size(1100, 2400));

    expect(tester.takeException(), isNull);
    expect(find.text('Make your community heard.'), findsOneWidget);
  });

  testWidgets('shows the community pulse figures once loaded', (tester) async {
    await pumpHome(tester, const Size(390, 2400));
    // Not pumpAndSettle: the photo gallery drifts continuously by design, so
    // the tree never reaches a settled state.
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Active Demands'), findsOneWidget);
    expect(find.text('People Affected'), findsOneWidget);
    expect(find.text('Under Review'), findsOneWidget);
    expect(find.text('Funded'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
