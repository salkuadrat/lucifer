import '../request.dart';
import '../response.dart';
import '../typedef.dart';

/// 
/// Middleware to handle CORS.
/// 
Callback cors({
  dynamic origin = '*',
  String methods = 'GET,HEAD,PUT,PATCH,POST,DELETE',
  String allowedHeaders = '*',
  String? exposedHeaders,
  bool? credentials,
  int? maxAge,
  bool? preflightContinue,
  int? optionsSuccessStatus,
}) {
  return (Req req, Res res) {
    res.headers.set('Access-Control-Allow-Origin', origin);
    res.headers.set('Access-Control-Allow-Methods', methods);
    res.headers.set('Access-Control-Allow-Headers', allowedHeaders);

    if (exposedHeaders != null) {
      res.headers.set('Access-Control-Expose-Headers', exposedHeaders);
    }

    if (credentials != null && credentials) {
      res.headers.set('Access-Control-Allow-Credentials', credentials);
    }

    if (maxAge != null) {
      res.headers.set('Access-Control-Max-Age', maxAge);
    }

    if (req.method == 'OPTIONS') {
      res.end();
    }
  };
}
