import '../request.dart';
import '../response.dart';
import '../typedef.dart';

///
/// Content Security Policy (CSP) helps prevent unwanted content from being
/// injected/loaded into your webpages.
///
/// This can mitigate cross-site scripting (XSS) vulnerabilities, clickjacking,
/// formjacking, malicious frames, unwanted trackers, and other
/// web client-side attacks.
///
/// This middleware helps set Content Security Policies.
///
Callback contentSecurityPolicy() {
  return (Req req, Res res) {
    // TODO
  };
}
