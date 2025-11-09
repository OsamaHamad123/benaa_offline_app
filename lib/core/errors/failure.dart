sealed class Failure {
  final String message;
  final String? code;
  final dynamic error;
  final StackTrace? stackTrace;

  const Failure({
    required this.message,
    this.code,
    this.error,
    this.stackTrace,
  });

  @override
  String toString() => 'Failure: $message ${code != null ? '($code)' : ''}';
}

class NetworkFailure extends Failure {
  const NetworkFailure({
    required super.message,
    super.code,
    super.error,
    super.stackTrace,
  });
}

class DatabaseFailure extends Failure {
  const DatabaseFailure({
    required super.message,
    super.code,
    super.error,
    super.stackTrace,
  });
}

class AuthFailure extends Failure {
  const AuthFailure({
    required super.message,
    super.code,
    super.error,
    super.stackTrace,
  });
}

class ValidationFailure extends Failure {
  final Map<String, List<String>>? fieldErrors;

  const ValidationFailure({
    required super.message,
    super.code,
    this.fieldErrors,
    super.error,
    super.stackTrace,
  });
}

class SyncFailure extends Failure {
  const SyncFailure({
    required super.message,
    super.code,
    super.error,
    super.stackTrace,
  });
}

class FileFailure extends Failure {
  const FileFailure({
    required super.message,
    super.code,
    super.error,
    super.stackTrace,
  });
}

class EncryptionFailure extends Failure {
  const EncryptionFailure({
    required super.message,
    super.code,
    super.error,
    super.stackTrace,
  });
}

class UnknownFailure extends Failure {
  const UnknownFailure({
    required super.message,
    super.code,
    super.error,
    super.stackTrace,
  });
}
