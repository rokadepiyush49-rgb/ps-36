import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/routing/routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/janmaang_typography.dart';
import '../../../shared/widgets/jm_app_bar.dart';
import 'map_controller.dart';
import 'map_screen.dart';

/// The map as a full screen of its own, reached from Home or from a demand.
///
/// The map fills the frame — the brief is explicit that it should be a major
/// part of the product rather than a thumbnail — with only a slim task bar
/// above it carrying the count and a route into the methodology.
class FullMapScreen extends ConsumerWidget {
  const FullMapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final issues = ref.watch(filteredIssuesProvider);
    final total = ref.watch(allIssuesProvider).length;

    return Scaffold(
      appBar: JmAppBar.task(
        title: 'Live resource map',
        actions: <Widget>[
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: Insets.sm),
              child: Text(
                issues.length == total
                    ? '$total sites'
                    : '${issues.length} of $total',
                style: JanMaangTypography.tabularNums
                    .copyWith(color: scheme.onSurfaceVariant),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.help_outline, size: 20),
            color: scheme.onSurfaceVariant,
            tooltip: 'How this map is built',
            onPressed: () => Navigator.of(context).pushNamed(
              AppRoute.method.path,
            ),
          ),
        ],
      ),
      body: const MapScreen(),
    );
  }
}
