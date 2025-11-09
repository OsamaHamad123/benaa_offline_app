import '../errors/failure.dart';

sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failed<T>;

  T? get valueOrNull => switch (this) {
    Success(value: final v) => v,
    Failed() => null,
  };

  Failure? get failureOrNull => switch (this) {
    Success() => null,
    Failed(failure: final f) => f,
  };

  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(Failure failure) onFailure,
  }) {
    return switch (this) {
      Success(value: final v) => onSuccess(v),
      Failed(failure: final f) => onFailure(f),
    };
  }

  Result<R> map<R>(R Function(T value) transform) {
    return switch (this) {
      Success(value: final v) => Success(transform(v)),
      Failed(failure: final f) => Failed(f),
    };
  }

  Future<Result<R>> mapAsync<R>(Future<R> Function(T value) transform) async {
    return switch (this) {
      Success(value: final v) => Success(await transform(v)),
      Failed(failure: final f) => Failed(f),
    };
  }

  Result<R> flatMap<R>(Result<R> Function(T value) transform) {
    return switch (this) {
      Success(value: final v) => transform(v),
      Failed(failure: final f) => Failed(f),
    };
  }
}

class Success<T> extends Result<T> {
  final T value;

  const Success(this.value);

  @override
  String toString() => 'Success($value)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Success &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;
}

class Failed<T> extends Result<T> {
  final Failure failure;

  const Failed(this.failure);

  @override
  String toString() => 'Failed($failure)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failed &&
          runtimeType == other.runtimeType &&
          failure == other.failure;

  @override
  int get hashCode => failure.hashCode;
}

// Helper extension for working with Results
extension ResultExtension<T> on Result<T> {
  T getOrThrow() {
    return switch (this) {
      Success(value: final v) => v,
      Failed(failure: final f) => throw Exception(f.message),
    };
  }

  T getOrElse(T Function() defaultValue) {
    return switch (this) {
      Success(value: final v) => v,
      Failed() => defaultValue(),
    };
  }
}

// Helper for async operations
Future<Result<T>> resultFrom<T>(Future<T> Function() operation) async {
  try {
    final value = await operation();
    return Success(value);
  } on Failure catch (e) {
    return Failed(e);
  } catch (e, stack) {
    return Failed(
      UnknownFailure(message: e.toString(), error: e, stackTrace: stack),
    );
  }
}

Result<T> resultFromSync<T>(T Function() operation) {
  try {
    final value = operation();
    return Success(value);
  } on Failure catch (e) {
    return Failed(e);
  } catch (e, stack) {
    return Failed(
      UnknownFailure(message: e.toString(), error: e, stackTrace: stack),
    );
  }
}
