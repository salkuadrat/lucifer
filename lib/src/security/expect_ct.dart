import '../request.dart';
import '../response.dart';
import '../typedef.dart';

/// 
/// The Expect-CT HTTP header tells browsers to expect Certificate Transparency.
/// 
Callback expectCT({
  int maxAge = 0,
  bool enforce = false,
  String? reportUri,
}) {
  return (Req req, Res res) {
    String value = 'max-age=$maxAge';
    if (enforce) value = '$value; enforce';
    if (reportUri != null) value = '$value; report-uri=$reportUri';
    res.set('Expect-CT', value);
  };
}