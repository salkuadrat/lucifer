import '../parsers/parsers.dart';
import '../request.dart';
import '../response.dart';
import '../typedef.dart';

/// 
/// Middleware to parse urlencoded request body.
/// 
Callback urlencoded() {
  return (Req req, Res res) async {
    if (req.isUrlencoded) {
      String body = await req.request.body;
      req.body = parseUrlEncoded(body);
    }
  };
}
