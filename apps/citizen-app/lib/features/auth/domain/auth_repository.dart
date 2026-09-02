import 'app_user.dart';

/// Authentication contract. Phone/OTP is the primary route because the product
/// targets citizens who may have nothing but a mobile number; Google Sign-In is
/// offered as a convenience.
abstract interface class AuthRepository {
  Stream<AppUser?> authStateChanges();

  AppUser? get currentUser;

  /// Sends an OTP and returns an opaque verification id to pair with the code.
  Future<String> sendOtp(String phoneNumber);

  Future<AppUser> verifyOtp({
    required String verificationId,
    required String smsCode,
    bool linkAadhaar = false,
  });

  Future<AppUser> signInWithGoogle();

  Future<void> signOut();

  Future<void> updateProfile(AppUser user);
}
