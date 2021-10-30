import '../request.dart';
import '../response.dart';
import '../typedef.dart';

///
/// This middleware sets the Cross-Origin-Opener-Policy header.
///
Callback crossOriginOpenerPolicy({String policy = 'same-origin'}) {
  List<String> allowed = [
    'same-origin',
    'same-origin-allow-popups',
    'unsafe-none',
  ];

  return (Req req, Res res) {
    String value = allowed.contains(policy) ? policy : 'same-origin';
    res.set('Cross-Origin-Opener-Policy', value);
  };
}
