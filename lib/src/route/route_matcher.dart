import '../method.dart';
import '../parsers/parsers.dart';
import '../utils/path.dart';
import 'route.dart';

class RouteMatcher {
  ///
  /// Filter routes that match the speficied method and uri.
  ///
  static Iterable<Route> match({
    required Method method,
    required String path,
    required List<Route> routes,
  }) sync* {
    String p = cleanPath(path);

    for (Route route in routes) {
      if (route.method != method && route.method != Method.all) {
        continue;
      }

      if (route.matcher.hasMatch(p)) {
        yield route;
      }
    }
  }

  ///
  /// Generate request params from the specified route and uri string.
  ///
  static Map<String, dynamic> params(String route, String uri) {
    final routePath = cleanPath(route);
    final uriPath = cleanPath(uri);

    final routeSegments = routePath.split('/');
    final uriSegments = uriPath.split('/');
    final params = <String, dynamic>{};

    bool mismatch = routeSegments.length != uriSegments.length;

    if (mismatch) {
      return params;
    }

    for (var i = 0; i < routeSegments.length; i++) {
      final routeSegment = routeSegments[i];
      final uriSegment = uriSegments[i];

      bool isParam = routeSegment.contains(':');

      if (isParam) {
        String key = routeSegment.replaceAll(':', '');
        String value = Uri.decodeComponent(uriSegment);

        if (value.contains('?')) {
          value = value.split('?').first;
        }

        params[key] = parseValue(value);
      }
    }

    return params;
  }
}
