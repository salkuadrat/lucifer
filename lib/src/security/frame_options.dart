import '../request.dart';
import '../response.dart';
import '../typedef.dart';

///
/// The X-Frame-Options HTTP header restricts who can put your site in
/// a frame which can help mitigate things like clickjacking attacks.
///
/// https://en.wikipedia.org/wiki/Clickjacking
///
/// The header has two modes: DENY and SAMEORIGIN.
///
/// This header is superseded by the frame-ancestors Content Security Policy
/// directive but is still useful on old browsers.
///
/// If your app does not need to be framed (and most don't)
/// you can use DENY.
///
/// If your site can be in frames from the same origin,
/// you can set it to SAMEORIGIN.
///
Callback xFrameOptions({String action = 'SAMEORIGIN'}) {
  return (Req req, Res res) {
    action = action.toUpperCase();

    switch (action) {
      case 'SAME-ORIGIN':
        res.header('X-Frame-Options', 'SAMEORIGIN');
        break;
      case 'DENY':
      case 'SAMEORIGIN':
        res.header('X-Frame-Options', action);
        break;
      case "ALLOW-FROM":
        throw Exception(
          "X-Frame-Options no longer supports `ALLOW-FROM` due to poor browser support. See <https://github.com/helmetjs/helmet/wiki/How-to-use-X%E2%80%93Frame%E2%80%93Options's-%60ALLOW%E2%80%93FROM%60-directive> for more info.",
        );
      default:
        throw Exception(
          'X-Frame-Options received an invalid action $action',
        );
    }
  };
}
