import '../parsers/parsers.dart';
import '../request.dart';
import '../response.dart';
import '../typedef.dart';

///
/// Middleware to parse multipart request body.
///
Callback multipart() {
  return (Req req, Res res) async {
    if (req.isMultipart) {
      final result = await parseMultipart(req);

      if (result is List && result.length == 2) {
        req.body = result[0];
        req.files = result[1];
      }
    }
  };
}
