import 'package:logger/logger.dart';

class ErrorHandlerService {
  final Logger _logger;

  ErrorHandlerService(this._logger);

  void handleError(Object error, String context) {
    _logger.e('Error in $context: $error');
    
    // Log stack trace if available
    if (error is Error) {
      _logger.e('Stack trace:', error: error, stackTrace: error.stackTrace);
    }
  }
}