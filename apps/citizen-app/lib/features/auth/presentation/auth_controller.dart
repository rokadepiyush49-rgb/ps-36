import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/failure.dart';
import '../../../core/providers.dart';

@immutable
class AuthFlowState {
  const AuthFlowState({
    this.phone = '',
    this.linkAadhaar = false,
    this.verificationId,
    this.isSending = false,
    this.isVerifying = false,
    this.error,
  });

  final String phone;

  /// The optional "High-Trust Verification" toggle on the login screen.
  final bool linkAadhaar;
  final String? verificationId;
  final bool isSending;
  final bool isVerifying;
  final Failure? error;

  bool get canSendOtp => phone.length == 10 && !isSending;

  AuthFlowState copyWith({
    String? phone,
    bool? linkAadhaar,
    String? verificationId,
    bool? isSending,
    bool? isVerifying,
    Failure? error,
    bool clearError = false,
  }) =>
      AuthFlowState(
        phone: phone ?? this.phone,
        linkAadhaar: linkAadhaar ?? this.linkAadhaar,
        verificationId: verificationId ?? this.verificationId,
        isSending: isSending ?? this.isSending,
        isVerifying: isVerifying ?? this.isVerifying,
        error: clearError ? null : (error ?? this.error),
      );
}

class AuthController extends Notifier<AuthFlowState> {
  @override
  AuthFlowState build() => const AuthFlowState();

  void setPhone(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    state = state.copyWith(phone: digits, clearError: true);
  }

  void toggleAadhaar(bool value) => state = state.copyWith(linkAadhaar: value);

  /// Returns true when the OTP was dispatched and the UI should advance.
  Future<bool> sendOtp() async {
    if (!state.canSendOtp) return false;
    state = state.copyWith(isSending: true, clearError: true);
    try {
      final id =
          await ref.read(authRepositoryProvider).sendOtp('+91${state.phone}');
      state = state.copyWith(isSending: false, verificationId: id);
      return true;
    } on Failure catch (failure) {
      state = state.copyWith(isSending: false, error: failure);
      return false;
    }
  }

  Future<bool> verifyOtp(String code) async {
    final verificationId = state.verificationId;
    if (verificationId == null) return false;

    state = state.copyWith(isVerifying: true, clearError: true);
    try {
      await ref.read(authRepositoryProvider).verifyOtp(
            verificationId: verificationId,
            smsCode: code,
            linkAadhaar: state.linkAadhaar,
          );
      state = state.copyWith(isVerifying: false);
      return true;
    } on Failure catch (failure) {
      state = state.copyWith(isVerifying: false, error: failure);
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    state = state.copyWith(isSending: true, clearError: true);
    try {
      await ref.read(authRepositoryProvider).signInWithGoogle();
      state = state.copyWith(isSending: false);
      return true;
    } on Failure catch (failure) {
      state = state.copyWith(isSending: false, error: failure);
      return false;
    }
  }

  Future<void> signOut() => ref.read(authRepositoryProvider).signOut();

  void dismissError() => state = state.copyWith(clearError: true);
}

final authControllerProvider =
    NotifierProvider<AuthController, AuthFlowState>(AuthController.new);
