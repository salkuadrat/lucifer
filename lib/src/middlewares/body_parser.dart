import '../parsers/parsers.dart';
import '../request.dart';
import '../response.dart';
import '../typedef.dart';

///
/// Middleware to parse general request body of all types.
///
Callback bodyParser() {
  return (Req req, Res res) async {
    if (req.isMultipart) {
      final result = await parseMultipart(req);

      if (result is List && result.length == 2) {
        req.body = result[0];
        req.files = result[1];
      }
    } else if (req.isUrlencoded) {
      String body = await req.request.body;
      req.body = parseUrlEncoded(body);
    } else if (req.isJson) {
      String body = await req.request.body;
      req.body = parseJson(body);
    } else if (req.isText) {
      req.body = await req.request.body;
    } else {
      req.body = await req.request.bytes;
    }
  };
}
