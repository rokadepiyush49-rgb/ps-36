/// A user-facing failure. Data-layer exceptions are converted into these at the
/// repository boundary so presentation never has to know about Firebase.
sealed class Failure implements Exception {
  const Failure(this.message, {this.cause, this.stackTrace});

  final String message;
  final Object? cause;
  final StackTrace? stackTrace;

  @override
  String toString() => '$runtimeType: $message';
}

class NetworkFailure extends Failure {
  const NetworkFailure([
    super.message = 'You appear to be offline. Your report is saved and will '
        'be sent when the connection returns.',
    Object? cause,
    StackTrace? stackTrace,
  ]) : super(cause: cause, stackTrace: stackTrace);
}

class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.cause, super.stackTrace});
}

class PermissionFailure extends Failure {
  const PermissionFailure(super.message, {super.cause, super.stackTrace});
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'We could not find that record.']);
}

class ServerFailure extends Failure {
  const ServerFailure([
    super.message = 'Something went wrong on our side. Please try again.',
    Object? cause,
    StackTrace? stackTrace,
  ]) : super(cause: cause, stackTrace: stackTrace);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}
