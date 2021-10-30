import '../parsers/parsers.dart';
import '../request.dart';
import '../response.dart';
import '../typedef.dart';

/// 
/// Middleware to parse json request body.
/// 
Callback json() {
  return (Req req, Res res) async {
    if (req.isJson) {
      String body = await req.request.body;
      req.body = parseJson(body);
    }
  };
}