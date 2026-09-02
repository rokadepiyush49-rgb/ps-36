import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_config.dart';
import '../../../core/routing/routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/janmaang_typography.dart';
import '../../../shared/widgets/jm_app_bar.dart';
import '../../../shared/widgets/jm_logo.dart';
import '../data/auth_repository_mock.dart';
import 'auth_controller.dart';

/// OTP entry. Not a Stitch screen — the login design ends at "Send OTP" — so
/// it is built strictly from that screen's language: same display heading,
/// same 8px fields, same pinned primary action.
class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _controller = TextEditingController();
  String _code = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final state = ref.watch(authControllerProvider);
    final controller = ref.read(authControllerProvider.notifier);

    ref.listen(authControllerProvider, (previous, next) {
      final error = next.error;
      if (error != null && previous?.error != error && mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(error.message)));
        controller.dismissError();
      }
    });

    return Scaffold(
      appBar: JmAppBar.task(title: ''),
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
              Center(child: JmLogo.mark(size: 56)),
              const SizedBox(height: Insets.lg),
              Text(
                'Enter the code',
                style: JanMaangTypography.displayLgMobile
                    .copyWith(color: scheme.onSurface),
              ),
              const SizedBox(height: Insets.sm),
              Text(
                'We sent a 6-digit code to +91 ${state.phone}.',
                style: JanMaangTypography.bodyMd
                    .copyWith(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: Insets.lg),
              TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
                maxLength: 6,
                autofocus: true,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
                style: JanMaangTypography.tabularNums.copyWith(
                  fontSize: 24,
                  letterSpacing: 8,
                  color: scheme.onSurface,
                ),
                decoration: const InputDecoration(
                  hintText: '––––––',
                  counterText: '',
                ),
                onChanged: (value) => setState(() => _code = value),
                onSubmitted: (_) => _verify(context),
              ),
              if (AppConfig.useMocks) ...<Widget>[
                const SizedBox(height: Insets.sm),
                Text(
                  'Development build — use ${MockAuthRepository.mockOtp}.',
                  style: JanMaangTypography.bodySm
                      .copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
              const Spacer(),
              FilledButton(
                onPressed:
                    _code.length == 6 && !state.isVerifying ? () => _verify(context) : null,
                child: state.isVerifying
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: scheme.onPrimary,
                        ),
                      )
                    : const Text('Verify & continue'),
              ),
              const SizedBox(height: Insets.md),
              Center(
                child: TextButton(
                  onPressed: state.isSending
                      ? null
                      : () async {
                          await controller.sendOtp();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Code resent.')),
                            );
                          }
                        },
                  child: const Text('Resend code'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _verify(BuildContext context) async {
    final ok = await ref.read(authControllerProvider.notifier).verifyOtp(_code);
    if (ok && context.mounted) context.goNamed(AppRoute.home.name);
  }
}
