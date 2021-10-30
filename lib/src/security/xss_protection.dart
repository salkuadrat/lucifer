import '../request.dart';
import '../response.dart';
import '../typedef.dart';

///
/// X-XSS-Protection is a feature of Internet Explorer and Chrome that stops
/// pages from loading when they detect reflected
/// cross-site scripting (XSS) attacks.
///
/// Although these protections are largely unnecessary in modern
/// browsers when sites implement a strong Content Security Policy that
/// disables the use of inline JavaScript ('unsafe-inline'), they can
/// still provide protections for users of older web browsers
/// that don’t yet support CSP.
///
Callback xXssProtection() {
  return (Req req, Res res) {
    res.set('X-XSS-Protection', '1; mode=block');
  };
}
