import '../request.dart';
import '../response.dart';
import '../typedef.dart';

///
/// This middleware lets you set the X-DNS-Prefetch-Control to control
/// browsers' DNS prefetching.
///
/// ```dart
/// // Set X-DNS-Prefetch-Control: off
/// app.use(dnsPrefetchControl());
///
/// // Set X-DNS-Prefetch-Control: off
/// app.use(dnsPrefetchControl({ allow: false }));
///
/// // Set X-DNS-Prefetch-Control: on
/// app.use(dnsPrefetchControl({ allow: true }));
/// ```
Callback dnsPrefetchControl({bool allow = false}) {
  return (Req req, Res res) {
    res.set('X-DNS-Prefetch-Control', allow ? 'on' : 'off');
  };
}
