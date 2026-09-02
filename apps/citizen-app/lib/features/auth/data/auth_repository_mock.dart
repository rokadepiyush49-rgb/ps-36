import 'dart:async';

import '../../../core/config/app_config.dart';
import '../../../core/errors/failure.dart';
import '../domain/app_user.dart';
import '../domain/auth_repository.dart';

/// Local stand-in for Firebase Auth. Any 6-digit code is accepted; the OTP the
/// mock "sent" is 123456 and is surfaced in the UI hint during development.
class MockAuthRepository implements AuthRepository {
  MockAuthRepository() {
    if (AppConfig.demoSignedIn) _user = demoUser;
  }

  final _controller = StreamController<AppUser?>.broadcast();
  AppUser? _user;
  String? _pendingPhone;

  /// The citizen the seeded corpus is written around.
  static const demoUser = AppUser(
    uid: 'mock-uid',
    phoneNumber: '+919876543210',
    displayName: 'Rajesh',
    district: AppConfig.defaultDistrict,
    state: AppConfig.defaultState,
    ward: 'Ward 4',
  );

  static const mockOtp = '123456';
  static const _latency = Duration(milliseconds: 700);

  @override
  Stream<AppUser?> authStateChanges() async* {
    yield _user;
    yield* _controller.stream;
  }

  @override
  AppUser? get currentUser => _user;

  @override
  Future<String> sendOtp(String phoneNumber) async {
    await Future<void>.delayed(_latency);
    final digits = phoneNumber.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 10) {
      throw const ValidationFailure('Enter a valid 10-digit mobile number.');
    }
    // Callers pass the number with or without the country code; keep the
    // subscriber digits only so it is never prefixed twice.
    _pendingPhone = digits.substring(digits.length - 10);
    return 'mock-verification-id';
  }

  @override
  Future<AppUser> verifyOtp({
    required String verificationId,
    required String smsCode,
    bool linkAadhaar = false,
  }) async {
    await Future<void>.delayed(_latency);
    if (smsCode.trim() != mockOtp) {
      throw const AuthFailure('That code did not match. Please try again.');
    }
    final user = AppUser(
      uid: 'mock-uid',
      phoneNumber: '+91${_pendingPhone ?? '9000000000'}',
      displayName: 'Rajesh',
      district: AppConfig.defaultDistrict,
      state: AppConfig.defaultState,
      ward: 'Ward 4',
      aadhaarVerified: linkAadhaar,
    );
    _user = user;
    _controller.add(user);
    return user;
  }

  @override
  Future<AppUser> signInWithGoogle() async {
    await Future<void>.delayed(_latency);
    const user = AppUser(
      uid: 'mock-uid-google',
      email: 'citizen@example.com',
      displayName: 'Rajesh',
      district: AppConfig.defaultDistrict,
      state: AppConfig.defaultState,
      ward: 'Ward 4',
    );
    _user = user;
    _controller.add(user);
    return user;
  }

  @override
  Future<void> signOut() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    _user = null;
    _controller.add(null);
  }

  @override
  Future<void> updateProfile(AppUser user) async {
    await Future<void>.delayed(_latency);
    _user = user;
    _controller.add(user);
  }

  void dispose() => _controller.close();
}
