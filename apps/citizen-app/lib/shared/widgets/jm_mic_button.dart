import 'package:flutter/material.dart';

import '../../core/theme/janmaang_colors.dart';

/// The 96px microphone control from the Report screen, with the two expanding
/// pulse rings the design shows while recording.
class JmMicButton extends StatefulWidget {
  const JmMicButton({
    super.key,
    required this.isListening,
    required this.onPressed,
    this.size = 96,
  });

  final bool isListening;
  final VoidCallback onPressed;
  final double size;

  @override
  State<JmMicButton> createState() => _JmMicButtonState();
}

class _JmMicButtonState extends State<JmMicButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  );

  @override
  void initState() {
    super.initState();
    if (widget.isListening) _controller.repeat();
  }

  @override
  void didUpdateWidget(covariant JmMicButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isListening && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.isListening && _controller.isAnimating) {
      _controller.stop();
      _controller.reset();
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
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final showPulse = widget.isListening && !reduceMotion;

    return SizedBox(
      width: widget.size * 2,
      height: widget.size * 2,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          if (showPulse)
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) => Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  _ring(_controller.value, 0.5, scheme.primaryFixed),
                  _ring((_controller.value + 0.5) % 1.0, 0.3, scheme.primaryFixed),
                ],
              ),
            ),
          Semantics(
            button: true,
            label: widget.isListening
                ? 'Stop recording'
                : 'Record what your community needs',
            child: SizedBox(
              width: widget.size,
              height: widget.size,
              child: Material(
                color: scheme.primary,
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: widget.onPressed,
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: JanMaangColors.micShadow,
                          offset: Offset(0, 8),
                          blurRadius: 16,
                        ),
                      ],
                    ),
                    child: Icon(
                      widget.isListening ? Icons.stop : Icons.mic,
                      size: widget.size * 0.42,
                      color: scheme.onPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _ring(double t, double baseOpacity, Color color) {
    final scale = 1.0 + t * 0.9;
    return Container(
      width: widget.size * scale,
      height: widget.size * scale,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: baseOpacity * (1 - t)),
      ),
    );
  }
}
