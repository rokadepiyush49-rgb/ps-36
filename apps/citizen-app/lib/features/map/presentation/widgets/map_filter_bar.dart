import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/janmaang_colors.dart';
import '../../../../core/theme/janmaang_typography.dart';
import '../../../../core/theme/motion.dart';
import '../../../../shared/models/demand_enums.dart';
import '../map_controller.dart';

/// Search and filters, floating over the map.
///
/// Category and severity are the two axes a citizen actually thinks in, so
/// they get one tap each; status sits behind the same sheet rather than adding
/// a third row of chips over the map.
class MapFilterBar extends ConsumerStatefulWidget {
  const MapFilterBar({
    super.key,
    required this.onLegendToggle,
    required this.legendOpen,
  });

  final VoidCallback onLegendToggle;
  final bool legendOpen;

  @override
  ConsumerState<MapFilterBar> createState() => _MapFilterBarState();
}

class _MapFilterBarState extends ConsumerState<MapFilterBar> {
  final _searchController = TextEditingController();
  final _focus = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final filter = ref.watch(issueFilterProvider);
    final notifier = ref.read(issueFilterProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Insets.md),
          child: Row(
            children: <Widget>[
              Expanded(
                child: AnimatedContainer(
                  duration: Motion.fast,
                  height: 46,
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(Corners.base),
                    border: Border.all(
                      color: _focus.hasFocus
                          ? scheme.secondary
                          : scheme.outlineVariant,
                      width: _focus.hasFocus ? 2 : 1,
                    ),
                    boxShadow: const <BoxShadow>[
                      BoxShadow(
                        color: JanMaangColors.shadowAmbient,
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: <Widget>[
                      const SizedBox(width: Insets.md),
                      Icon(Icons.search,
                          size: 20, color: scheme.onSurfaceVariant),
                      const SizedBox(width: Insets.sm),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          focusNode: _focus,
                          onChanged: notifier.setQuery,
                          onTap: () => setState(() {}),
                          onTapOutside: (_) {
                            _focus.unfocus();
                            setState(() {});
                          },
                          style: JanMaangTypography.bodySm
                              .copyWith(color: scheme.onSurface),
                          decoration: const InputDecoration(
                            hintText: 'Search issues, wards or IDs',
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            filled: false,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      if (filter.query.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.close, size: 16),
                          color: scheme.onSurfaceVariant,
                          visualDensity: VisualDensity.compact,
                          onPressed: () {
                            _searchController.clear();
                            notifier.setQuery('');
                          },
                        ),
                      const SizedBox(width: Insets.xs),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: Insets.sm),
              _IconChip(
                icon: Icons.layers_outlined,
                active: widget.legendOpen,
                tooltip: 'Legend',
                onTap: widget.onLegendToggle,
              ),
              const SizedBox(width: Insets.sm),
              _IconChip(
                icon: Icons.tune,
                active: filter.activeCount > 0,
                badge: filter.activeCount,
                tooltip: 'Filters',
                onTap: () => _openFilterSheet(context),
              ),
            ],
          ),
        ),
        const SizedBox(height: Insets.sm),
        SizedBox(
          height: 34,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: Insets.md),
            children: <Widget>[
              for (final category in DemandCategory.values)
                Padding(
                  padding: const EdgeInsets.only(right: Insets.sm),
                  child: _FilterChip(
                    label: category.label,
                    icon: category.icon,
                    selected: filter.categories.contains(category),
                    onTap: () => notifier.toggleCategory(category),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  void _openFilterSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => Consumer(
        builder: (context, ref, _) {
          final scheme = Theme.of(context).colorScheme;
          final filter = ref.watch(issueFilterProvider);
          final notifier = ref.read(issueFilterProvider.notifier);

          return Padding(
            padding: const EdgeInsets.fromLTRB(
              Insets.lg,
              0,
              Insets.lg,
              Insets.xl,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'Filter issues',
                        style: JanMaangTypography.headlineSm
                            .copyWith(color: scheme.onSurface),
                      ),
                    ),
                    if (filter.activeCount > 0)
                      TextButton(
                        onPressed: notifier.clear,
                        child: const Text('Clear all'),
                      ),
                  ],
                ),
                const SizedBox(height: Insets.md),
                _SheetSection(
                  title: 'SEVERITY',
                  child: Wrap(
                    spacing: Insets.sm,
                    runSpacing: Insets.sm,
                    children: <Widget>[
                      for (final severity in Severity.values)
                        _FilterChip(
                          label: severity.label,
                          selected: filter.severities.contains(severity),
                          onTap: () => notifier.toggleSeverity(severity),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: Insets.lg),
                _SheetSection(
                  title: 'STATUS',
                  child: Wrap(
                    spacing: Insets.sm,
                    runSpacing: Insets.sm,
                    children: <Widget>[
                      for (final status in DemandStatus.values)
                        _FilterChip(
                          label: status.label,
                          selected: filter.statuses.contains(status),
                          onTap: () => notifier.toggleStatus(status),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SheetSection extends StatelessWidget {
  const _SheetSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style:
              JanMaangTypography.labelMd.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: Insets.sm),
        child,
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return JmPressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Motion.fast,
        curve: Motion.curve,
        padding: const EdgeInsets.symmetric(
          horizontal: Insets.md,
          vertical: Insets.sm,
        ),
        decoration: BoxDecoration(
          color: selected
              ? scheme.primary
              : scheme.surfaceContainerLowest.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(Corners.sm),
          border: Border.all(
            color: selected ? scheme.primary : scheme.outlineVariant,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (icon != null) ...<Widget>[
              Icon(
                icon,
                size: 14,
                color: selected ? scheme.onPrimary : scheme.onSurfaceVariant,
              ),
              const SizedBox(width: Insets.xs),
            ],
            Text(
              label,
              style: JanMaangTypography.labelMd.copyWith(
                color: selected ? scheme.onPrimary : scheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconChip extends StatelessWidget {
  const _IconChip({
    required this.icon,
    required this.active,
    required this.tooltip,
    required this.onTap,
    this.badge = 0,
  });

  final IconData icon;
  final bool active;
  final String tooltip;
  final VoidCallback onTap;
  final int badge;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Tooltip(
      message: tooltip,
      child: JmPressable(
        onTap: onTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            AnimatedContainer(
              duration: Motion.fast,
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: active ? scheme.primary : scheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(Corners.base),
                border: Border.all(
                  color: active ? scheme.primary : scheme.outlineVariant,
                ),
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    color: JanMaangColors.shadowAmbient,
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                icon,
                size: 20,
                color: active ? scheme.onPrimary : scheme.onSurface,
              ),
            ),
            if (badge > 0)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: scheme.error,
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(color: scheme.surface, width: 1.5),
                  ),
                  child: Text(
                    '$badge',
                    style: JanMaangTypography.labelMd.copyWith(
                      color: scheme.onError,
                      fontSize: 10,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
