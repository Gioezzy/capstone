import 'app_exception.dart';

// Value wrapper around AppException for use in state/UI.
class Failure {
  final AppException exception;

  const Failure(this.exception);

  factory Failure.from(Object error) {
    if (error is AppException) {
      return Failure(error);
    }
    return const Failure(UnknownException());
  }

  String get message => exception.message;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure &&
          other.exception.runtimeType == exception.runtimeType &&
          other.exception.message == exception.message;

  @override
  int get hashCode => Object.hash(exception.runtimeType, exception.message);

  @override
  String toString() => 'Failure(${exception.runtimeType}: ${exception.message})';
}
