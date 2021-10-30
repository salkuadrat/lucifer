import '../method.dart';
import '../typedef.dart';
import '../utils/path.dart';

class Route {
  /// 
  /// Path of this route
  /// 
  final String path;

  /// 
  /// Http Method of this route
  /// 
  final Method method;

  /// 
  /// List of combined stack of middlewares and callback
  /// 
  final List<Callback> stack;

  /// 
  /// List of middlewares atteached to this route
  /// 
  final List<Callback> middleware;

  /// 
  /// The handler callback for this route
  /// 
  Callback? callback;

  /// 
  /// Regular expression matcher associated with the route path
  /// 
  final RegExp matcher;

  /// 
  /// Check if this route has callback
  /// 
  bool get hasCallback => callback != null;

  /// 
  /// Checks if this route path contains wildcard (*)
  /// 
  bool get hasWildcard => path.contains('*');

  /// 
  /// Check if this route is not a wildcard path
  /// 
  bool get notWildcard => path != '*';

  Route({
    required this.method,
    required this.path,
    this.middleware = const [],
    this.callback,
  })  : stack = [...middleware, if (callback != null) callback],
        matcher = _matcher(path);

  /// 
  /// Build a Regex matcher from route path.
  ///
  static RegExp _matcher(String path) {
    // Clean path
    path = '/' + cleanPath(path);

    // Parse segments from route path
    final segments = Uri.parse(path).pathSegments;

    String matcher = '^';

    for (String segment in segments) {
      bool isFirst = segment == segments.first;
      bool isLast = segment == segments.last;
      bool notFirst = !isFirst;
      bool notLast = !isLast;

      if (segment == '*' && isLast && notFirst) {
        matcher += '?.*';
        break;
      }

      matcher += segment
          .replaceAll('.', r'\.') // escape dot character
          .replaceAll(RegExp(':.+'), '[^/]+?') // convert path (':any')
          .replaceAll('*', '.*?'); // convert wildcard ('*')

      if (notLast) {
        matcher += '/';
      }
    }

    matcher += r'$';
    return RegExp(matcher, caseSensitive: false);
  }

  String get methodString {
    switch (method) {
      case Method.get:
        return '\x1B[33mGET\x1B[0m';
      case Method.post:
        return '\x1B[31mPOST\x1B[0m';
      case Method.put:
        return '\x1B[32mPUT\x1B[0m';
      case Method.delete:
        return '\x1B[34mDELETE\x1B[0m';
      case Method.patch:
        return '\x1B[35mPATCH\x1B[0m';
      case Method.options:
        return '\x1B[36mOPTIONS\x1B[0m';
      case Method.all:
        return '\x1B[37mALL\x1B[0m';
      case Method.head:
        return '\x1B[38mHEAD\x1B[0m';
    }
  }

  @override
  String toString() => '$methodString\t$path';
}
