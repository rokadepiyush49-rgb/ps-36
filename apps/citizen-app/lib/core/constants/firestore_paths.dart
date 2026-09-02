/// Single source of truth for Firestore collection names, so a rename never has
/// to be hunted through string literals.
abstract final class FirestorePaths {
  static const users = 'users';
  static const demands = 'demands';
  static const clusters = 'clusters';
  static const verifications = 'verifications';
  static const ledgerEntries = 'ledgerEntries';
  static const allocations = 'allocations';

  // Sub-collections
  static const supporters = 'supporters';
  static const timeline = 'timeline';

  // Storage buckets
  static String reportPhoto(String uid, String demandId, String fileName) =>
      'reports/$uid/$demandId/$fileName';

  static String verificationPhoto(String verificationId, String fileName) =>
      'verifications/$verificationId/$fileName';

  // Callable Cloud Functions
  static const fnAnalyzeReport = 'analyzeReport';
  static const fnFindSimilarDemands = 'findSimilarDemands';
  static const fnSubmitVerification = 'submitVerification';
  static const fnJoinDemand = 'joinDemand';
}
