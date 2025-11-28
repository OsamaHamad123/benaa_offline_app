/// 🎯 Result Pattern
///
/// Functional error handling pattern that makes errors explicit.
///
/// Usage:
/// ```dart
/// Future<Result<User>> getUser(int id) async {
///   try {
///     final user = await database.getUser(id);
///     return Success(user);
///   } catch (e) {
///     return Failure(DatabaseFailure(e.toString()));
///   }
/// }
///
/// final result = await getUser(1);
/// if (result.isSuccess) {
///   final user = result.getOrThrow();
/// }
/// ```
sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  /// Get value or throw
  T getOrThrow() {
    return switch (this) {
      Success(value: final v) => v,
      Failure(error: final e) => throw e,
    };
  }

  /// Get value or default
  T getOrElse(T defaultValue) {
    return switch (this) {
      Success(value: final v) => v,
      Failure() => defaultValue,
    };
  }

  /// Get value or null
  T? getOrNull() {
    return switch (this) {
      Success(value: final v) => v,
      Failure() => null,
    };
  }
}

/// ✅ Success
final class Success<T> extends Result<T> {
  final T value;
  const Success(this.value);

  @override
  String toString() => 'Success($value)';
}

/// ❌ Failure
final class Failure<T> extends Result<T> {
  final AppFailure error;
  const Failure(this.error);

  @override
  String toString() => 'Failure($error)';
}

/// 🚨 Base Failure Class
///
/// All application failures should extend this class.
abstract class AppFailure implements Exception {
  final String message;
  final StackTrace? stackTrace;

  const AppFailure(this.message, [this.stackTrace]);

  @override
  String toString() => message;
}

/// 💾 Database Failures
class DatabaseFailure extends AppFailure {
  const DatabaseFailure(super.message, [super.stackTrace]);
}

/// 🌐 Network Failures
class NetworkFailure extends AppFailure {
  const NetworkFailure(super.message, [super.stackTrace]);
}

/// ✅ Validation Failures
class ValidationFailure extends AppFailure {
  final Map<String, String>? errors;

  const ValidationFailure(super.message, [this.errors, super.stackTrace]);
}

/// 🔐 Permission Failures
class PermissionFailure extends AppFailure {
  const PermissionFailure(super.message, [super.stackTrace]);
}

/// 🔍 Not Found Failures
class NotFoundFailure extends AppFailure {
  const NotFoundFailure(super.message, [super.stackTrace]);
}

/// ⚙️ Server Failures
class ServerFailure extends AppFailure {
  final int? statusCode;

  const ServerFailure(super.message, [this.statusCode, super.stackTrace]);
}

/// 📝 Cache Failures
class CacheFailure extends AppFailure {
  const CacheFailure(super.message, [super.stackTrace]);
}

/// ❓ Unknown Failures
class UnknownFailure extends AppFailure {
  const UnknownFailure(super.message, [super.stackTrace]);
}

/// 🔄 Sync Failures
class SyncFailure extends AppFailure {
  const SyncFailure(super.message, [super.stackTrace]);
}

/// 📁 File Failures
class FileFailure extends AppFailure {
  const FileFailure(super.message, [super.stackTrace]);
}

/// 🔒 Authentication Failures
class AuthFailure extends AppFailure {
  const AuthFailure(super.message, [super.stackTrace]);
}

/// 🛡️ Authorization Failures
class AuthorizationFailure extends AppFailure {
  const AuthorizationFailure(super.message, [super.stackTrace]);
}

/// ⏱️ Timeout Failures
class TimeoutFailure extends AppFailure {
  const TimeoutFailure(super.message, [super.stackTrace]);
}

/// 🔌 Connection Failures
class ConnectionFailure extends AppFailure {
  const ConnectionFailure(super.message, [super.stackTrace]);
}
