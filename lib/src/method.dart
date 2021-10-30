/// 
/// HTTP Methods supported by Lucifer
/// 
/// Reference:
/// https://developer.mozilla.org/en-US/docs/Web/HTTP/Methods
/// 
enum Method {
  get,
  post,
  put,
  delete,
  patch,
  options,
  head,
  all
}

extension StringExtension on String {
  /// Convert string to [Method] enum
  Method get httpMethod {
    switch (this) {
      case 'POST':
        return Method.post;
      case 'PUT':
        return Method.put;
      case 'DELETE':
        return Method.delete;
      case 'PATCH':
        return Method.patch;
      case 'OPTIONS':
        return Method.options;
      case 'HEAD':
        return Method.head;
      default:
        return Method.get;
    }
  }
}