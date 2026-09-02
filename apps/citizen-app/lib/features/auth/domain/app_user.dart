import 'package:flutter/foundation.dart';

/// The signed-in citizen.
@immutable
class AppUser {
  const AppUser({
    required this.uid,
    this.phoneNumber,
    this.displayName,
    this.email,
    this.photoUrl,
    this.district = '',
    this.state = '',
    this.ward = '',
    this.aadhaarVerified = false,
    this.isFieldOfficer = false,
  });

  final String uid;
  final String? phoneNumber;
  final String? displayName;
  final String? email;
  final String? photoUrl;
  final String district;
  final String state;
  final String ward;

  /// Set by the optional "High-Trust Verification" toggle on the login screen.
  /// Linking Aadhaar accelerates service access; it is never required.
  final bool aadhaarVerified;

  /// Field officers additionally get the evidence-capture tool.
  final bool isFieldOfficer;

  String get greetingName {
    final name = displayName?.trim();
    if (name == null || name.isEmpty) return '';
    return name.split(' ').first;
  }

  String get locationLabel =>
      district.isEmpty ? '' : (state.isEmpty ? district : '$district, $state');

  AppUser copyWith({
    String? displayName,
    String? photoUrl,
    String? district,
    String? state,
    String? ward,
    bool? aadhaarVerified,
  }) =>
      AppUser(
        uid: uid,
        phoneNumber: phoneNumber,
        displayName: displayName ?? this.displayName,
        email: email,
        photoUrl: photoUrl ?? this.photoUrl,
        district: district ?? this.district,
        state: state ?? this.state,
        ward: ward ?? this.ward,
        aadhaarVerified: aadhaarVerified ?? this.aadhaarVerified,
        isFieldOfficer: isFieldOfficer,
      );
}
