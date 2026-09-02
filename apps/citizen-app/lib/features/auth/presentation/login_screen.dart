import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/janmaang_typography.dart';
import '../../../shared/widgets/jm_app_bar.dart';
import '../../../shared/widgets/jm_card.dart';
import '../../../shared/widgets/jm_logo.dart';
import 'auth_controller.dart';

/// Citizen Login — the Stitch login screen.
///
/// A minimal brand-only header (no trailing action, to keep focus), the +91
/// mobile field, the optional Aadhaar high-trust toggle, and the Send OTP
/// action pinned to the bottom. No bottom navigation: this is transactional.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
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
      appBar: const JmAppBar(showBrand: true, actions: <Widget>[]),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
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
                        'Citizen Login',
                        style: JanMaangTypography.displayLgMobile
                            .copyWith(color: scheme.onSurface),
                      ),
                      const SizedBox(height: Insets.sm),
                      Text(
                        'Enter your mobile number to access civic services.',
                        style: JanMaangTypography.bodyMd
                            .copyWith(color: scheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: Insets.lg),

                      Text(
                        'Mobile Number',
                        style: JanMaangTypography.labelMd
                            .copyWith(color: scheme.onSurface),
                      ),
                      const SizedBox(height: Insets.xs),
                      TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        autofocus: true,
                        textInputAction: TextInputAction.done,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        style: JanMaangTypography.tabularNums.copyWith(
                          fontSize: 18,
                          color: scheme.onSurface,
                        ),
                        decoration: InputDecoration(
                          hintText: '00000 00000',
                          counterText: '',
                          prefixIcon: Padding(
                            padding: const EdgeInsets.only(
                              left: Insets.md,
                              right: Insets.sm,
                            ),
                            child: Text(
                              '+91',
                              style: JanMaangTypography.bodyMd
                                  .copyWith(color: scheme.onSurfaceVariant),
                            ),
                          ),
                          prefixIconConstraints:
                              const BoxConstraints(minWidth: 0, minHeight: 0),
                        ),
                        onChanged: controller.setPhone,
                        onSubmitted: (_) => _send(context),
                      ),
                      const SizedBox(height: Insets.lg),

                      _AadhaarToggle(
                        value: state.linkAadhaar,
                        onChanged: controller.toggleAadhaar,
                      ),

                      const Spacer(),
                      const SizedBox(height: Insets.lg),

                      FilledButton(
                        onPressed: state.canSendOtp ? () => _send(context) : null,
                        child: state.isSending
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: scheme.onPrimary,
                                    ),
                                  ),
                                  const SizedBox(width: Insets.sm),
                                  const Text('Sending…'),
                                ],
                              )
                            : const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Text('Send OTP'),
                                  SizedBox(width: Insets.sm),
                                  Icon(Icons.arrow_forward, size: 20),
                                ],
                              ),
                      ),
                      const SizedBox(height: Insets.md),

                      Row(
                        children: <Widget>[
                          Expanded(child: Divider(color: scheme.outlineVariant)),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: Insets.md),
                            child: Text(
                              'or',
                              style: JanMaangTypography.labelMd
                                  .copyWith(color: scheme.onSurfaceVariant),
                            ),
                          ),
                          Expanded(child: Divider(color: scheme.outlineVariant)),
                        ],
                      ),
                      const SizedBox(height: Insets.md),
                      OutlinedButton.icon(
                        onPressed: state.isSending
                            ? null
                            : () async {
                                final ok = await controller.signInWithGoogle();
                                if (ok && context.mounted) {
                                  context.goNamed(AppRoute.home.name);
                                }
                              },
                        icon: const Icon(Icons.g_mobiledata, size: 24),
                        label: const Text('Continue with Google'),
                      ),

                      const SizedBox(height: Insets.md),
                      Center(
                        child: Text.rich(
                          TextSpan(
                            style: JanMaangTypography.labelMd
                                .copyWith(color: scheme.onSurfaceVariant),
                            children: const <InlineSpan>[
                              TextSpan(text: 'By proceeding, you agree to the '),
                              TextSpan(text: 'Terms of Service'),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _send(BuildContext context) async {
    final sent = await ref.read(authControllerProvider.notifier).sendOtp();
    if (sent && context.mounted) context.pushNamed(AppRoute.otp.name);
  }
}

/// The high-trust card: linking Aadhaar is explicitly optional, and the copy
/// says so, because requiring it would exclude the people the product is for.
class _AadhaarToggle extends StatelessWidget {
  const _AadhaarToggle({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return JmCard(
      onTap: () => onChanged(!value),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(Icons.verified_user,
                        size: 18, color: scheme.onTertiaryContainer),
                    const SizedBox(width: Insets.xs),
                    Text(
                      'High-Trust Verification',
                      style: JanMaangTypography.titleLg
                          .copyWith(color: scheme.onSurface),
                    ),
                  ],
                ),
                const SizedBox(height: Insets.xs),
                Text(
                  'Link Aadhaar for accelerated service access (Optional)',
                  style: JanMaangTypography.bodySm
                      .copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(width: Insets.sm),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
