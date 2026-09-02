import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/janmaang_typography.dart';
import '../../core/utils/formatters.dart';
import '../../features/demands/domain/demand.dart';

/// The status timeline: completed nodes are filled check circles, the active
/// node is a pulsing ring, future nodes are hollow dots, all joined by a
/// vertical connector that stops at the last node.
class JmTimeline extends StatelessWidget {
  const JmTimeline({super.key, required this.events});

  final List<TimelineEvent> events;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (var i = 0; i < events.length; i++)
          _TimelineRow(
            event: events[i],
            isLast: i == events.length - 1,
          ),
      ],
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.event, required this.isLast});

  final TimelineEvent event;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isUpcoming = event.state == TimelineState.upcoming;

    final subtitle = <String>[
      if (event.at != null) Formatters.date(event.at!),
      if (event.note.isNotEmpty) event.note,
    ].join(' • ');

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Column(
            children: <Widget>[
              _TimelineNode(state: event.state),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    color: event.state == TimelineState.complete
                        ? scheme.primary
                        : scheme.outlineVariant,
                  ),
                ),
            ],
          ),
          const SizedBox(width: Insets.md),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : Insets.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    event.status.label,
                    style: JanMaangTypography.bodyMd.copyWith(
                      color: isUpcoming ? scheme.onSurfaceVariant : scheme.onSurface,
                      fontWeight:
                          event.state == TimelineState.active ? FontWeight.w700 : null,
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: JanMaangTypography.bodySm
                          .copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineNode extends StatefulWidget {
  const _TimelineNode({required this.state});

  final TimelineState state;

  @override
  State<_TimelineNode> createState() => _TimelineNodeState();
}

class _TimelineNodeState extends State<_TimelineNode>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );

  @override
  void initState() {
    super.initState();
    if (widget.state == TimelineState.active) _controller.repeat();
  }

  @override
  void didUpdateWidget(covariant _TimelineNode oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state == TimelineState.active && !_controller.isAnimating) {
      _controller.repeat();
    } else if (widget.state != TimelineState.active && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return switch (widget.state) {
      TimelineState.complete => Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(color: scheme.primary, shape: BoxShape.circle),
          child: Icon(Icons.check, size: 15, color: scheme.onPrimary),
        ),
      TimelineState.active => SizedBox(
          width: 24,
          height: 24,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              // Reduced-motion users get the static ring without the pulse.
              if (!MediaQuery.of(context).disableAnimations)
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) {
                    final t = _controller.value;
                    return Container(
                      width: 12 + 12 * t,
                      height: 12 + 12 * t,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: scheme.primaryFixed.withValues(alpha: 0.6 * (1 - t)),
                      ),
                    );
                  },
                ),
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: scheme.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: scheme.surface, width: 2),
                ),
              ),
            ],
          ),
        ),
      TimelineState.upcoming => Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: scheme.outlineVariant, width: 2),
            ),
          ),
        ),
    };
  }
}
