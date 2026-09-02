import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/janmaang_typography.dart';
import '../../core/theme/motion.dart';

/// The floating bottom navigation.
///
/// Five destinations — Home · Track · Report · Ranks · Ledger — on a rounded
/// bar that sits above the content rather than being welded to the bottom
/// edge. Report is the dominant action: a raised primary circle that breaks
/// the top of the bar, ringed in the bar's own colour so it reads as sitting
/// in front of it, and carrying a slow halo so the eye finds it first.
///
/// The selected destination is marked three ways at once — a navy pill that
/// slides between slots, a filled rather than outlined icon, and a reversed
/// label — so the state survives greyscale, colour-blindness and a bright
/// screen outdoors. Labels are always visible; an icon alone is never the only
/// signal.
class JmBottomNav extends StatelessWidget {
  const JmBottomNav({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
  });

  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;

  /// Height of the bar itself. The raised action overhangs it.
  static const barHeight = 62.0;

  /// Height of the sliding indicator pill — tall enough to hold icon *and*
  /// label, which is what lets the selected item reverse out cleanly.
  static const pillHeight = 50.0;

  /// Vertical inset of the pill inside the bar.
  static const pillTop = 6.0;

  static const destinations = <JmNavDestination>[
    JmNavDestination(
      label: 'Home',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
    ),
    JmNavDestination(
      label: 'Track',
      icon: Icons.insights_outlined,
      selectedIcon: Icons.insights_rounded,
    ),
    JmNavDestination(
      label: 'Report',
      icon: Icons.mic_none_rounded,
      selectedIcon: Icons.mic_rounded,
      raised: true,
    ),
    JmNavDestination(
      label: 'Ranks',
      icon: Icons.emoji_events_outlined,
      selectedIcon: Icons.emoji_events_rounded,
    ),
    JmNavDestination(
      label: 'Ledger',
      icon: Icons.receipt_long_outlined,
      selectedIcon: Icons.receipt_long_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final reduced = Motion.reduced(context);

    // On a wide window the bar would stretch to absurd proportions, so it is
    // capped and centred instead.
    final width = MediaQuery.sizeOf(context).width;
    final wide = width >= Breakpoints.medium;
    final rawMargin = wide ? (width - 520) / 2 : Insets.md;
    final margin = rawMargin < Insets.md ? Insets.md : rawMargin;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(margin, 0, margin, Insets.sm + Insets.xs),
        child: SizedBox(
          height: barHeight,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final slot = constraints.maxWidth / destinations.length;
              final rawPill = slot - Insets.sm;
              final pillWidth = rawPill < 0 ? 0.0 : rawPill;
              final index = currentIndex < 0
                  ? 0
                  : currentIndex > destinations.length - 1
                      ? destinations.length - 1
                      : currentIndex;
              final selectedIsRaised = destinations[index].raised;

              return Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  // The bar itself.
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(Corners.xl),
                        boxShadow: Shadows.level3,
                      ),
                    ),
                  ),

                  // The indicator, sliding between slots rather than fading in
                  // and out of each one — the movement is what tells you where
                  // you came from.
                  AnimatedPositioned(
                    duration: reduced ? Duration.zero : Motion.medium,
                    curve: Motion.curve,
                    left: slot * index + Insets.xs,
                    top: pillTop,
                    width: pillWidth,
                    height: pillHeight,
                    child: AnimatedOpacity(
                      duration: reduced ? Duration.zero : Motion.fast,
                      opacity: selectedIsRaised ? 0 : 1,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: scheme.primary,
                          borderRadius: BorderRadius.circular(Corners.base + 4),
                        ),
                      ),
                    ),
                  ),

                  // The ink has to land on a Material above the bar's own
                  // background, or the splash paints behind it.
                  Positioned.fill(
                    child: Material(
                      color: Colors.transparent,
                      child: Row(
                        children: <Widget>[
                          for (var i = 0; i < destinations.length; i++)
                            Expanded(
                              child: _NavItem(
                                destination: destinations[i],
                                selected: i == currentIndex,
                                onTap: () => onDestinationSelected(i),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class JmNavDestination {
  const JmNavDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    this.raised = false,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;

  /// Report is drawn as an elevated circle breaking the top of the bar.
  final bool raised;
}

/// One destination.
///
/// Every item runs a single scale pulse on tap — 1.0 → 1.12 → 1.0 — with a
/// selection click, which acknowledges the press on a screen where the
/// destination change itself may take a moment. It fires once and settles.
///
/// The raised Report action additionally carries a slow halo: a ring that
/// expands out of the circle and fades, once every two and a half seconds. It
/// is the one continuously animating thing in the product, and it earns that
/// because reporting is the single action the whole platform exists to
/// collect. It stops while Report is the current destination — an invitation
/// you have already accepted should stop asking — and never runs under
/// reduce-motion.
class _NavItem extends StatefulWidget {
  const _NavItem({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final JmNavDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> with TickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 280),
  );

  late final Animation<double> _scale = TweenSequence<double>(
    <TweenSequenceItem<double>>[
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 1, end: 1.12)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 38,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 1.12, end: 1)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 62,
      ),
    ],
  ).animate(_pulse);

  /// Drives the Report halo. Only ever created for the raised destination.
  AnimationController? _halo;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncHalo();
  }

  @override
  void didUpdateWidget(covariant _NavItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selected != widget.selected) _syncHalo();
  }

  void _syncHalo() {
    final wanted = widget.destination.raised &&
        !widget.selected &&
        !Motion.reduced(context);

    if (!wanted) {
      _halo?.stop();
      return;
    }

    _halo ??= AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    if (!_halo!.isAnimating) _halo!.repeat();
  }

  @override
  void dispose() {
    _halo?.dispose();
    _pulse.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (!Motion.reduced(context)) {
      _pulse.forward(from: 0);
    }
    // The platform's own selection feedback — no audio dependency needed.
    HapticFeedback.selectionClick();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final d = widget.destination;
    final reduced = Motion.reduced(context);

    // Selected items reverse out of the navy pill; the raised action is always
    // white-on-navy because it has its own navy circle.
    final contentColour = d.raised
        ? scheme.onPrimary
        : widget.selected
            ? scheme.onPrimary
            : scheme.onSurfaceVariant;

    final icon = ScaleTransition(
      scale: _scale,
      child: Icon(
        widget.selected ? d.selectedIcon : d.icon,
        size: 23,
        color: contentColour,
      ),
    );

    final label = AnimatedDefaultTextStyle(
      duration: reduced ? Duration.zero : Motion.fast,
      curve: Motion.curve,
      style: JanMaangTypography.withWeight(
        JanMaangTypography.navLabel,
        widget.selected ? FontWeight.w700 : FontWeight.w600,
      ).copyWith(
        // The raised action's label sits on the bar, not on the pill, so it
        // takes the ordinary foreground colours.
        color: d.raised
            ? (widget.selected ? scheme.primary : scheme.onSurfaceVariant)
            : contentColour,
      ),
      child: Text(
        d.label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
      ),
    );

    if (d.raised) {
      return Semantics(
        button: true,
        selected: widget.selected,
        label: '${d.label} — report a need',
        excludeSemantics: true,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _handleTap,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: <Widget>[
              // The circle. Positioned so its label lands on the same baseline
              // as every other label in the bar.
              Positioned(
                bottom: 22,
                child: _ReportButton(
                  halo: _halo,
                  scale: _scale,
                  icon: Icon(
                    widget.selected ? d.selectedIcon : d.icon,
                    size: 25,
                    color: scheme.onPrimary,
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 6,
                child: label,
              ),
            ],
          ),
        ),
      );
    }

    return Semantics(
      button: true,
      selected: widget.selected,
      label: d.label,
      excludeSemantics: true,
      child: InkWell(
        onTap: _handleTap,
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Corners.base + 4),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Insets.xs),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              icon,
              const SizedBox(height: Insets.xxs),
              label,
            ],
          ),
        ),
      ),
    );
  }
}

/// The raised Report circle, its ring, and the halo that expands out of it.
class _ReportButton extends StatelessWidget {
  const _ReportButton({
    required this.halo,
    required this.scale,
    required this.icon,
  });

  final AnimationController? halo;
  final Animation<double> scale;
  final Widget icon;

  static const _size = 52.0;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final circle = ScaleTransition(
      scale: scale,
      child: Container(
        width: _size,
        height: _size,
        decoration: BoxDecoration(
          color: scheme.primary,
          shape: BoxShape.circle,
          border: Border.all(color: scheme.surfaceContainerLowest, width: 4),
          boxShadow: Shadows.level2,
        ),
        child: Center(child: icon),
      ),
    );

    if (halo == null) return circle;

    return AnimatedBuilder(
      animation: halo!,
      builder: (context, child) {
        final t = halo!.value;
        // Ring expands out and fades. The first 70% of the cycle carries the
        // whole gesture; the remainder is the rest between beats.
        final raw = t / 0.7;
        final ring = raw > 1.0 ? 1.0 : raw;
        // OverflowBox lets the ring paint wider than the circle without
        // changing the footprint — otherwise the button would shift upward
        // the moment the halo switched on.
        return SizedBox(
          width: _size,
          height: _size,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: <Widget>[
              IgnorePointer(
                child: OverflowBox(
                  maxWidth: _size * 1.8,
                  maxHeight: _size * 1.8,
                  child: Opacity(
                    opacity: (1 - ring) * 0.34,
                    child: Container(
                      width: _size * (1 + 0.42 * ring),
                      height: _size * (1 + 0.42 * ring),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: scheme.primary, width: 2),
                      ),
                    ),
                  ),
                ),
              ),
              child!,
            ],
          ),
        );
      },
      child: circle,
    );
  }
}
