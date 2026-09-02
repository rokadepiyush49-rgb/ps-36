import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/failure.dart';
import '../../../core/providers.dart';
import '../../../core/services/media_service.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/janmaang_typography.dart';
import '../../../shared/models/demand_enums.dart';
import '../../../shared/widgets/jm_app_bar.dart';
import '../../../shared/widgets/jm_card.dart';
import '../../../shared/widgets/jm_photo_dropzone.dart';
import '../../../shared/widgets/jm_states.dart';
import '../domain/verification.dart';

final verificationRequestProvider =
    FutureProvider.autoDispose.family<VerificationRequest, String>((ref, id) {
  return ref.watch(verificationRepositoryProvider).getRequest(id);
});

/// Citizen Verification — the Stitch "Closing the Loop" screen.
///
/// Before-and-after side by side, then the binary judgement. This is the step
/// that makes the whole ledger meaningful: it measures whether public money
/// actually solved the problem.
class VerifyScreen extends ConsumerStatefulWidget {
  const VerifyScreen({super.key, required this.demandId});

  final String demandId;

  @override
  ConsumerState<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends ConsumerState<VerifyScreen> {
  final List<String> _photos = <String>[];
  bool _submitting = false;

  @override
  Widget build(BuildContext context) {
    final requestAsync = ref.watch(verificationRequestProvider(widget.demandId));

    return Scaffold(
      appBar: JmAppBar.task(title: 'Verify'),
      body: requestAsync.when(
        loading: () => const JmLoader(),
        error: (error, _) => JmErrorView(
          error: error,
          onRetry: () =>
              ref.invalidate(verificationRequestProvider(widget.demandId)),
        ),
        data: (request) => _body(context, request),
      ),
    );
  }

  Widget _body(BuildContext context, VerificationRequest request) {
    final scheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        Insets.marginMobile,
        Insets.lg,
        Insets.marginMobile,
        Insets.xl,
      ),
      children: <Widget>[
        Text(
          'Is the problem fixed?',
          style:
              JanMaangTypography.displayLgMobile.copyWith(color: scheme.onSurface),
        ),
        const SizedBox(height: Insets.sm),
        RichText(
          text: TextSpan(
            style: JanMaangTypography.bodyMd
                .copyWith(color: scheme.onSurfaceVariant),
            children: <InlineSpan>[
              const TextSpan(text: 'Original Report: '),
              TextSpan(
                text: request.demandTitle,
                style: JanMaangTypography.withWeight(
                  JanMaangTypography.bodyMd,
                  FontWeight.w600,
                ).copyWith(color: scheme.onSurface),
              ),
            ],
          ),
        ),
        const SizedBox(height: Insets.lg),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: _BeforeColumn(
                photoUrl: request.beforePhotoUrl,
                caption: 'Reported ${request.reportedAgo}',
              ),
            ),
            const SizedBox(width: Insets.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'CURRENT STATUS',
                    style: JanMaangTypography.labelMd
                        .copyWith(color: scheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: Insets.sm),
                  SizedBox(
                    height: 150,
                    child: JmPhotoDropzone(
                      onTap: _capture,
                      title: 'Upload a photo',
                      subtitle: 'Optional, but helpful for verification.',
                      height: 150,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        if (_photos.isNotEmpty) ...<Widget>[
          const SizedBox(height: Insets.md),
          JmPhotoDropzone(
            onTap: _capture,
            title: 'Add another photo',
            subtitle: 'Photos are geotagged and timestamped.',
            height: 90,
            paths: _photos,
            onRemove: (i) => setState(() => _photos.removeAt(i)),
          ),
        ],

        const SizedBox(height: Insets.xl),
        Text(
          request.question,
          style: JanMaangTypography.headlineSm.copyWith(color: scheme.onSurface),
        ),
        const SizedBox(height: Insets.md),
        FilledButton.icon(
          onPressed: _submitting ? null : () => _submit(isFixed: true),
          icon: const Icon(Icons.check_circle, size: 20),
          label: const Text('Yes, it is fixed'),
          style: FilledButton.styleFrom(
            backgroundColor: scheme.tertiaryFixed,
            foregroundColor: scheme.onTertiaryFixed,
          ),
        ),
        const SizedBox(height: Insets.md),
        OutlinedButton.icon(
          onPressed: _submitting ? null : () => _submit(isFixed: false),
          icon: Icon(Icons.cancel, size: 20, color: scheme.error),
          label: Text(
            'No, still broken',
            style: JanMaangTypography.labelMd.copyWith(color: scheme.error),
          ),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: scheme.error),
            minimumSize: const Size.fromHeight(52),
          ),
        ),

        const SizedBox(height: Insets.lg),
        JmCard(
          backgroundColor: scheme.surfaceContainer,
          borderColor: scheme.outlineVariant,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(Icons.info_outline, size: 18, color: scheme.secondary),
              const SizedBox(width: Insets.sm),
              Expanded(
                child: Text(
                  'Your verification matters. It helps measure whether public '
                  'projects actually solve the problem.',
                  style: JanMaangTypography.bodySm
                      .copyWith(color: scheme.onSurfaceVariant),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _capture() async {
    final path = await ref.read(mediaServiceProvider).capturePhoto();
    if (path != null && mounted) setState(() => _photos.add(path));
  }

  Future<void> _submit({required bool isFixed}) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() => _submitting = true);
    try {
      await ref.read(verificationRepositoryProvider).submit(
            VerificationSubmission(
              demandId: widget.demandId,
              kind: VerificationKind.citizen,
              isFixed: isFixed,
              photoPaths: _photos,
            ),
            user.uid,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isFixed
                ? 'Thank you. This project is now citizen-verified.'
                : 'Recorded. The department has been notified it is unresolved.',
          ),
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

class _BeforeColumn extends StatelessWidget {
  const _BeforeColumn({required this.photoUrl, required this.caption});

  final String? photoUrl;
  final String caption;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'BEFORE',
          style:
              JanMaangTypography.labelMd.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: Insets.sm),
        ClipRRect(
          borderRadius: BorderRadius.circular(Corners.lg),
          child: Container(
            height: 150,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHigh,
              border: Border.all(color: scheme.outlineVariant),
              borderRadius: BorderRadius.circular(Corners.lg),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                if (photoUrl != null)
                  Image.network(photoUrl!, fit: BoxFit.cover)
                else
                  Center(
                    child: Icon(
                      Icons.photo_outlined,
                      size: 30,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Insets.sm,
                      vertical: Insets.xs,
                    ),
                    color: scheme.inverseSurface.withValues(alpha: 0.72),
                    child: Text(
                      caption,
                      style: JanMaangTypography.labelMd
                          .copyWith(color: scheme.onInverseSurface),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
