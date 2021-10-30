import 'package:http_status_code/http_status_code.dart';

///
/// Http Server Exception
///
class HttpServerException implements Exception {
  /// Status code exception
  final int status;

  /// Exception data
  final String message;

  final StackTrace? stackTrace;

  HttpServerException(this.status, {String? message, this.stackTrace})
      : message = message ?? '$status ${getStatusMessage(status)}';

  @override
  String toString() => '$status $message';
}

///
/// Bad Request Exception.
///
class BadRequestException extends HttpServerException {
  BadRequestException({String? message, StackTrace? stackTrace})
      : super(
          StatusCode.BAD_REQUEST,
          message: message,
          stackTrace: stackTrace,
        );
}

///
/// Unauthorized Exception.
///
class UnauthorizedException extends HttpServerException {
  UnauthorizedException({String? message, StackTrace? stackTrace})
      : super(
          StatusCode.UNAUTHORIZED,
          message: message,
          stackTrace: stackTrace,
        );
}

///
/// Payment Required Exception.
///
class PaymentRequiredException extends HttpServerException {
  PaymentRequiredException({String? message, StackTrace? stackTrace})
      : super(
          StatusCode.PAYMENT_REQUIRED,
          message: message,
          stackTrace: stackTrace,
        );
}

///
/// Payment Required Exception.
///
class ForbiddenException extends HttpServerException {
  ForbiddenException({String? message, StackTrace? stackTrace})
      : super(
          StatusCode.FORBIDDEN,
          message: message,
          stackTrace: stackTrace,
        );
}

///
/// Not Found Exception.
///
class NotFoundException extends HttpServerException {
  NotFoundException({String? message, StackTrace? stackTrace})
      : super(
          StatusCode.NOT_FOUND,
          message: message,
          stackTrace: stackTrace,
        );
}

///
/// Method Not Allowed Exception.
///
class MethodNotAllowedException extends HttpServerException {
  MethodNotAllowedException({String? message, StackTrace? stackTrace})
      : super(
          StatusCode.METHOD_NOT_ALLOWED,
          message: message,
          stackTrace: stackTrace,
        );
}

///
/// Request Timeout Exception.
///
class RequestTimeoutException extends HttpServerException {
  RequestTimeoutException({String? message, StackTrace? stackTrace})
      : super(
          StatusCode.REQUEST_TIMEOUT,
          message: message,
          stackTrace: stackTrace,
        );
}

///
/// Conflict Exception.
///
class ConflictException extends HttpServerException {
  ConflictException({String? message, StackTrace? stackTrace})
      : super(
          StatusCode.CONFLICT,
          message: message,
          stackTrace: stackTrace,
        );
}

///
/// Unprocessable Entity Exception.
///
class UnprocessableException extends HttpServerException {
  UnprocessableException({String? message, StackTrace? stackTrace})
      : super(
          StatusCode.UNPROCESSABLE_ENTITY,
          message: message,
          stackTrace: stackTrace,
        );
}

///
/// Internal Server Error Exception
///
class InternalErrorException extends HttpServerException {
  InternalErrorException({String? message, StackTrace? stackTrace})
      : super(
          StatusCode.INTERNAL_SERVER_ERROR,
          message: message,
          stackTrace: stackTrace,
        );
}

///
/// Not Implemented Exception
///
class NotImplementedException extends HttpServerException {
  NotImplementedException({String? message, StackTrace? stackTrace})
      : super(
          StatusCode.NOT_IMPLEMENTED,
          message: message,
          stackTrace: stackTrace,
        );
}

///
/// Service Unavailable Exception
///
class ServiceUnavailableException extends HttpServerException {
  ServiceUnavailableException({String? message, StackTrace? stackTrace})
      : super(
          StatusCode.SERVICE_UNAVAILABLE,
          message: message,
          stackTrace: stackTrace,
        );
}
