/// A message suitable for the UI, without raw server responses or stack traces.
class AppException implements Exception {
  const AppException(this.message);
  final String message;
  @override
  String toString() => message;
}

String errorMessage(Object error) => error is AppException
    ? error.message
    : 'Das hat leider nicht geklappt. Bitte erneut versuchen.';
