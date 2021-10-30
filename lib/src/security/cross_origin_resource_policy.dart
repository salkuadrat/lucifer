import '../request.dart';
import '../response.dart';
import '../typedef.dart';

///
/// This middleware sets the Cross-Origin-Resource-Policy header.
/// 
Callback crossOriginResourcePolicy({String policy = 'same-origin'}) {
  List<String> allowed = [
    'same-origin',
    'same-site',
    'cross-origin',
  ];

  return (Req req, Res res) {
    String value = allowed.contains(policy) ? policy : 'same-origin';
    res.set('Cross-Origin-Resource-Policy', value);
  };
}
