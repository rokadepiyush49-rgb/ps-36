/// Compile-time configuration.
///
/// `--dart-define=USE_MOCKS=false` switches the app from the in-memory
/// fixtures over to live Firebase, and `--dart-define=MAPS_ENABLED=true`
/// turns on the Google Maps surfaces once an API key is provisioned in the
/// native manifests.
///
/// No secret ever lives here. Gemini and any other server-side key stays in
/// Cloud Functions; the client only calls callable functions.
abstract final class AppConfig {
  static const appName = 'JanMaang';

  /// Defaults to true so the whole UI is navigable before a Firebase project
  /// is attached. Flipped by `flutterfire configure` + `--dart-define`.
  static const useMocks =
      bool.fromEnvironment('USE_MOCKS', defaultValue: true);

  /// Google Maps needs a platform API key in the Android manifest / iOS plist.
  /// Until that is provisioned the map surfaces render the styled static
  /// placeholder the Stitch designs show.
  static const mapsEnabled =
      bool.fromEnvironment('MAPS_ENABLED', defaultValue: false);

  /// Starts the mock build already signed in.
  ///
  /// For demos, screenshots and UI review, where stepping through OTP every
  /// reload is friction with no informational value. Has no effect once
  /// [useMocks] is false — real auth always requires real credentials.
  static const demoSignedIn =
      bool.fromEnvironment('DEMO_SIGNED_IN') && useMocks;

  static const defaultDistrict = 'Yadgir';
  static const defaultState = 'Karnataka';
  static const supportPhone = '1800-000-0000';

  /// Region the Cloud Functions are deployed to.
  static const functionsRegion = 'asia-south1';
}
