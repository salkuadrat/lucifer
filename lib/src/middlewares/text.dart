import '../request.dart';
import '../response.dart';
import '../typedef.dart';

/// 
/// Middleware to get request body as string.
/// 
Callback text() {
  return (Req req, Res res) async {
    // only do it once
    if (req.isText) {
      req.body = await req.request.body;
    }
  };
}
