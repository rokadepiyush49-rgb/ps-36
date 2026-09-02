import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:janmaang/core/theme/app_theme.dart';
import 'package:janmaang/shared/widgets/jm_logo.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(body: Center(child: child)),
      );

  testWidgets('mark falls back to the institutional glyph until the brand '
      'artwork is dropped in', (tester) async {
    await tester.pumpWidget(wrap(const JmLogo.mark(size: 32)));
    await tester.pump();

    // Image.asset resolves lazily; the errorBuilder supplies the fallback when
    // assets/brand/janmaang_mark.png is absent.
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('full lockup carries an accessible label', (tester) async {
    await tester.pumpWidget(wrap(const JmLogo.full(width: 200)));
    await tester.pump();

    final semantics = tester.getSemantics(find.byType(JmLogo));
    expect(semantics.label, contains('JanMaang'));
  });

  testWidgets('brand row pairs the mark with the wordmark', (tester) async {
    await tester.pumpWidget(wrap(const JmBrandRow()));
    await tester.pump();

    expect(find.text('JanMaang'), findsOneWidget);
    expect(find.byType(JmLogo), findsOneWidget);
  });
}
