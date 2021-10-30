import '../request.dart';
import '../response.dart';
import '../typedef.dart';

/// 
/// This middleware adds the Strict-Transport-Security header to the response. 
/// This tells browsers, "hey, only use HTTPS for the next period of time".
/// 
/// Note that the header won't tell users on HTTP to switch to HTTPS, 
/// it will just tell HTTPS users to stick around. 
/// 
/// `maxAge` must be in seconds (defaults 180 days)
/// `includeSubDomains` directive is present by default.
/// 
/// Some browsers let you submit your site's HSTS to be baked into the browser. 
/// You can add `preload` to the header.
/// 
Callback strictTransportSecurity({
  int maxAge = 180 * 24 * 60 * 60,
  bool includeSubdomains = true,
  bool preload = false,
}) {
  return (Req req, Res res) {
    String value = 'max-age=$maxAge';
    if (includeSubdomains) value = '$value; includeSubDomains';
    if (preload) value = '$value; preload';
    res.set('Strict-Transport-Security', value);
  };
}