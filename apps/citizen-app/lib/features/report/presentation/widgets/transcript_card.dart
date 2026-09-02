import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/janmaang_typography.dart';
import '../../../../shared/widgets/jm_card.dart';

/// The live transcription card: a quote glyph, the recognised words at
/// body-lg, and the five-bar recording indicator in the corner.
class TranscriptCard extends StatelessWidget {
  const TranscriptCard({
    super.key,
    required this.transcript,
    required this.isRecording,
  });

  final String transcript;
  final bool isRecording;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return JmCard(
      padding: const EdgeInsets.all(Insets.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // The gradient hairline the design runs along the card's top edge.
          Container(
            height: 2,
            margin: const EdgeInsets.only(bottom: Insets.md),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: <Color>[
                  Colors.transparent,
                  scheme.primaryFixed,
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.format_quote,
                  size: 16,
                  color: scheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: Insets.md),
              Expanded(
                child: Text(
                  '"$transcript"',
                  style: JanMaangTypography.bodyLg
                      .copyWith(color: scheme.onSurface),
                ),
              ),
            ],
          ),
          if (isRecording) ...<Widget>[
            const SizedBox(height: Insets.sm),
            const Align(
              alignment: Alignment.centerRight,
              child: _RecordingBars(),
            ),
          ],
        ],
      ),
    );
  }
}

/// Five bars of animated audio level — decorative, matching the design.
class _RecordingBars extends StatefulWidget {
  const _RecordingBars();

  @override
  State<_RecordingBars> createState() => _RecordingBarsState();
}

class _RecordingBarsState extends State<_RecordingBars>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (MediaQuery.of(context).disableAnimations) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (var i = 0; i < 5; i++)
            Container(
              width: 3,
              height: 10,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
        ],
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (var i = 0; i < 5; i++)
            Container(
              width: 3,
              height: 6 +
                  10 *
                      (0.5 +
                          0.5 *
                              math.sin(
                                (_controller.value + i * 0.18) * math.pi * 2,
                              )),
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
        ],
      ),
    );
  }
}
