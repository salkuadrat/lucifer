import '../request.dart';
import '../response.dart';
import '../typedef.dart';

///
/// This middleware sets the Cross-Origin-Embedder-Policy header.
///
Callback crossOriginEmbedderPolicy() {
  return (Req req, Res res) {
    res.set('Cross-Origin-Embedder-Policy', 'require-corp');
  };
}