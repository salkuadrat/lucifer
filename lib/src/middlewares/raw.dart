import 'dart:typed_data';

import '../request.dart';
import '../response.dart';
import '../typedef.dart';

///
/// Middleware to fill request body with its raw bytes
///
Callback raw() {
  return (Req req, Res res) async {
    // only do it once
    if (req.body is! Uint8List) {
      req.body = await req.request.bytes;
    }
  };
}
