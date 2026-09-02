import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/failure.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/janmaang_typography.dart';
import '../../../shared/widgets/jm_app_bar.dart';
import '../../../shared/widgets/jm_card.dart';

/// "Question this ranking" — the objection route the transparency screen
/// promises. An unchallengeable ranking is not transparency, so the objection
/// is a first-class, recorded action rather than a support email.
class QuestionRankingScreen extends ConsumerStatefulWidget {
  const QuestionRankingScreen({super.key, required this.demandId});

  final String demandId;

  @override
  ConsumerState<QuestionRankingScreen> createState() =>
      _QuestionRankingScreenState();
}

class _QuestionRankingScreenState extends ConsumerState<QuestionRankingScreen> {
  final _controller = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: JmAppBar.task(title: 'Question this ranking'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            Insets.marginMobile,
            Insets.lg,
            Insets.marginMobile,
            Insets.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'What does the ranking miss?',
                style: JanMaangTypography.headlineSm
                    .copyWith(color: scheme.onSurface),
              ),
              const SizedBox(height: Insets.sm),
              Text(
                'Objections are recorded against this demand and reviewed by '
                'the district officer. The five scoring factors and their '
                'weights stay public either way.',
                style: JanMaangTypography.bodyMd
                    .copyWith(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: Insets.lg),
              JmCard(
                child: TextField(
                  controller: _controller,
                  maxLines: 6,
                  minLines: 4,
                  autofocus: true,
                  style:
                      JanMaangTypography.bodyMd.copyWith(color: scheme.onSurface),
                  decoration: const InputDecoration(
                    hintText: 'e.g. The people-affected count leaves out the '
                        'three hamlets across the canal.',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const Spacer(),
              FilledButton(
                onPressed: _controller.text.trim().length >= 10 && !_submitting
                    ? _submit
                    : null,
                child: _submitting
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: scheme.onPrimary,
                        ),
                      )
                    : const Text('Submit objection'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() => _submitting = true);
    try {
      await ref.read(demandsRepositoryProvider).questionRanking(
            demandId: widget.demandId,
            uid: user.uid,
            reason: _controller.text.trim(),
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Objection recorded against this demand.'),
        ),
      );
      Navigator.of(context).maybePop();
    } on Failure catch (failure) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(failure.message)));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}
