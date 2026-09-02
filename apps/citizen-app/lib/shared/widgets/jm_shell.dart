import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/motion.dart';
import 'jm_bottom_nav.dart';

/// Holds the four tab destinations and the floating bottom navigation.
///
/// The Report destination is not a tab in the usual sense: the design treats
/// it as a dominant action, so selecting it pushes the transactional report
/// flow on top of the shell rather than swapping the body.
///
/// `extendBody` is on because the bar floats — the body runs underneath it and
/// each tab leaves `Insets.navClearance` of padding at the end of its scroll
/// so nothing is ever stranded behind the bar.
class JmShell extends StatelessWidget {
  const JmShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const reportIndex = 2;

  @override
  Widget build(BuildContext context) {
    // The shell holds three branches; index 2 in the bar is the report action,
    // so bar indices above it map one lower onto the branches.
    final barIndex = navigationShell.currentIndex >= reportIndex
        ? navigationShell.currentIndex + 1
        : navigationShell.currentIndex;

    return Scaffold(
      extendBody: true,
      body: _BranchFade(
        index: navigationShell.currentIndex,
        child: navigationShell,
      ),
      bottomNavigationBar: JmBottomNav(
        currentIndex: barIndex,
        onDestinationSelected: (index) => _onSelected(context, index),
      ),
    );
  }

  void _onSelected(BuildContext context, int index) {
    if (index == reportIndex) {
      context.push('/report');
      return;
    }
    final branch = index > reportIndex ? index - 1 : index;
    navigationShell.goBranch(
      branch,
      initialLocation: branch == navigationShell.currentIndex,
    );
  }
}

/// A short fade-and-rise replayed whenever the selected branch changes.
///
/// Deliberately wraps the shell rather than swapping it: an AnimatedSwitcher
/// here would tear down and rebuild the outgoing branch, losing its scroll
/// position and its in-flight requests. This only re-paints.
class _BranchFade extends StatefulWidget {
  const _BranchFade({required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  State<_BranchFade> createState() => _BranchFadeState();
}

class _BranchFadeState extends State<_BranchFade>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
    value: 1,
  );

  late final Animation<double> _curved =
      _controller.drive(CurveTween(curve: Motion.enter));

  @override
  void didUpdateWidget(covariant _BranchFade oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index && !Motion.reduced(context)) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (Motion.reduced(context)) return widget.child;

    return AnimatedBuilder(
      animation: _curved,
      builder: (context, child) => Opacity(
        opacity: _curved.value,
        child: Transform.translate(
          offset: Offset(0, 8 * (1 - _curved.value)),
          child: child,
        ),
      ),
      child: widget.child,
    );
  }
}
