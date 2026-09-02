import 'package:flutter_test/flutter_test.dart';
import 'package:janmaang/features/auth/data/auth_repository_mock.dart';

void main() {
  late MockAuthRepository repository;

  setUp(() => repository = MockAuthRepository());
  tearDown(() => repository.dispose());

  test('rejects a short mobile number', () {
    expect(() => repository.sendOtp('12345'), throwsA(isA<Exception>()));
  });

  test('signs the citizen in with the right code and keeps the number',
      () async {
    final id = await repository.sendOtp('+919876543210');
    final user = await repository.verifyOtp(
      verificationId: id,
      smsCode: MockAuthRepository.mockOtp,
    );

    expect(user.phoneNumber, '+919876543210');
    expect(user.district, 'Yadgir');
    expect(repository.currentUser, isNotNull);
  });

  test('carries the optional Aadhaar link through verification', () async {
    final id = await repository.sendOtp('9876543210');
    final user = await repository.verifyOtp(
      verificationId: id,
      smsCode: MockAuthRepository.mockOtp,
      linkAadhaar: true,
    );
    expect(user.aadhaarVerified, isTrue);
  });

  test('rejects a wrong code', () async {
    final id = await repository.sendOtp('9876543210');
    expect(
      () => repository.verifyOtp(verificationId: id, smsCode: '000000'),
      throwsA(isA<Exception>()),
    );
  });

  test('sign-out clears the current user', () async {
    final id = await repository.sendOtp('9876543210');
    await repository.verifyOtp(
      verificationId: id,
      smsCode: MockAuthRepository.mockOtp,
    );
    await repository.signOut();
    expect(repository.currentUser, isNull);
  });
}
