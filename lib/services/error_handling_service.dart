import 'package:flutter/foundation.dart';

class ErrorHandlingService {
  static final ErrorHandlingService instance = ErrorHandlingService._internal();
  factory ErrorHandlingService() => instance;
  ErrorHandlingService._internal();

  void handleError(String context, dynamic error, StackTrace? stackTrace) {
    // Log the error
    debugPrint('🚨 Error in $context: $error');
    if (stackTrace != null) {
      debugPrint('Stack trace: $stackTrace');
    }

    // In debug mode, show more detailed errors
    if (kDebugMode) {
      debugPrint('Detailed error information for debugging:');
      debugPrint('Context: $context');
      debugPrint('Error: $error');
      debugPrint('Stack trace: $stackTrace');
    }

    // TODO: Add crash reporting service integration here (e.g., Sentry, Crashlytics)
  }

  Future<T?> wrapError<T>(
    String context,
    Future<T> Function() operation, {
    T? fallbackValue,
  }) async {
    try {
      return await operation();
    } catch (error, stackTrace) {
      handleError(context, error, stackTrace);
      return fallbackValue;
    }
  }

  T? wrapSyncError<T>(
    String context,
    T Function() operation, {
    T? fallbackValue,
  }) {
    try {
      return operation();
    } catch (error, stackTrace) {
      handleError(context, error, stackTrace);
      return fallbackValue;
    }
  }
}
