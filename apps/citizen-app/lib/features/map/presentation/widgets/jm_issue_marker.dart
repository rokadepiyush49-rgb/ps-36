import 'package:flutter/material.dart';

import '../../../../core/theme/janmaang_colors.dart';
import '../../../../core/theme/janmaang_typography.dart';
import '../../../../core/theme/motion.dart';
import '../../domain/map_issue.dart';

/// A map pin that says four things at once: what kind of issue it is (icon),
/// how severe or concentrated it is (colour + size + ring weight), how many
/// people have reported it (count badge), and whether it is selected (scale).
///
/// Colour is never the only channel — the brief requires the ranking to survive
/// without it, so size, ring and badge all move with the tier.
class JmIssueMarker extends StatelessWidget {
  const JmIssueMarker({
    super.key,
    required this.issue,
    required this.selected,
    this.onTap,
  });

  final MapIssue issue;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tier = issue.displayTier;
    final size = tier.markerSize * (selected ? 1.18 : 1.0);

    Widget pin = _Pin(
      tier: tier,
      icon: issue.category.filledIcon,
      size: size,
      reportCount: issue.reportCount,
      resolved: issue.isResolved,
    );

    // Only the critical tier pulses. Animating every marker turns the map into
    // noise, which the brief calls out.
    if (tier.pulses && !Motion.reduced(context)) {
      pin = _Pulse(color: tier.color, size: size, child: pin);
    }

    return Semantics(
      button: true,
      label: '${issue.title}, ${issue.ward}. '
          '${issue.reportCount} ${issue.reportCount == 1 ? "report" : "reports"}. '
          '${tier.label} priority.',
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedScale(
          scale: selected ? 1.0 : 1.0,
          duration: Motion.medium,
          curve: Motion.spring,
          child: pin,
        ),
      ),
    );
  }
}

class _Pin extends StatefulWidget {
  const _Pin({
    required this.tier,
    required this.icon,
    required this.size,
    required this.reportCount,
    required this.resolved,
  });

  final DensityTier tier;
  final IconData icon;
  final double size;
  final int reportCount;
  final bool resolved;

  @override
  State<_Pin> createState() => _PinState();
}

class _PinState extends State<_Pin> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final showBadge = widget.reportCount > 1;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        scale: _hovered && !Motion.reduced(context) ? 1.12 : 1.0,
        duration: Motion.fast,
        curve: Motion.curve,
        child: SizedBox(
          width: widget.size + 14,
          height: widget.size + 14,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: <Widget>[
              Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  color: widget.tier.color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: widget.tier.ringWidth,
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: widget.tier.color.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  widget.resolved ? Icons.check : widget.icon,
                  size: widget.size * 0.44,
                  color: widget.tier.onColor,
                ),
              ),
              if (showBadge)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 1,
                    ),
                    constraints: const BoxConstraints(minWidth: 20),
                    decoration: BoxDecoration(
                      color: JanMaangColors.brandNavy,
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: Text(
                      widget.reportCount > 99 ? '99+' : '${widget.reportCount}',
                      textAlign: TextAlign.center,
                      style: JanMaangTypography.labelMd.copyWith(
                        color: Colors.white,
                        fontSize: 10,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                ),
              // The pointer that anchors the pin to its coordinate.
              Positioned(
                bottom: -1,
                child: CustomPaint(
                  size: const Size(12, 8),
                  painter: _TailPainter(
                    color: widget.tier.color,
                    borderColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A slow expanding ring, reserved for critical density.
class _Pulse extends StatefulWidget {
  const _Pulse({
    required this.color,
    required this.size,
    required this.child,
  });

  final Color color;
  final double size;
  final Widget child;

  @override
  State<_Pulse> createState() => _PulseState();
}

class _PulseState extends State<_Pulse> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        return Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: <Widget>[
            Container(
              width: widget.size * (1 + t * 0.85),
              height: widget.size * (1 + t * 0.85),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color.withValues(alpha: 0.28 * (1 - t)),
              ),
            ),
            child!,
          ],
        );
      },
      child: widget.child,
    );
  }
}

/// Marker for a group of nearby issues, sized by total reports inside it.
class JmClusterMarker extends StatelessWidget {
  const JmClusterMarker({
    super.key,
    required this.cluster,
    this.onTap,
  });

  final IssueCluster cluster;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tier = cluster.tier;
    final size = tier.markerSize + 8;

    return Semantics(
      button: true,
      label: '${cluster.issues.length} locations, '
          '${cluster.totalReports} reports. ${tier.label} concentration.',
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: tier.color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: tier.ringWidth),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: tier.color.withValues(alpha: 0.35),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                '${cluster.issues.length}',
                style: JanMaangTypography.withWeight(
                  JanMaangTypography.tabularNums,
                  FontWeight.w700,
                ).copyWith(color: tier.onColor, fontSize: size * 0.3),
              ),
              Text(
                'sites',
                style: JanMaangTypography.labelMd.copyWith(
                  color: tier.onColor.withValues(alpha: 0.85),
                  fontSize: 8,
                  letterSpacing: 0.04 * 8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TailPainter extends CustomPainter {
  _TailPainter({required this.color, required this.borderColor});

  final Color color;
  final Color borderColor;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _TailPainter oldDelegate) =>
      oldDelegate.color != color;
}
