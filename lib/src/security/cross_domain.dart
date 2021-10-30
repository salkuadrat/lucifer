import '../request.dart';
import '../response.dart';
import '../typedef.dart';

///
/// The X-Permitted-Cross-Domain-Policies header tells some web clients
/// (like Adobe Flash or Adobe Acrobat) your domain's policy
/// for loading cross-domain content.
///
/// ```dart
/// // Sets X-Permitted-Cross-Domain-Policies: none
/// app.use(crossDomain());
///
/// // You can use any of the following values:
/// app.use(crossDomain({ permitted: 'none' }));
/// app.use(crossDomain({ permitted: 'master-only' }));
/// app.use(crossDomain({ permitted: 'by-content-type' }));
/// app.use(crossDomain({ permitted: 'all' }));
/// ```
Callback crossDomain({String permitted = 'none'}) {
  List<String> allowed = [
    'none',
    'master-only',
    'by-content-type',
    'all',
  ];

  return (Req req, Res res) {
    String value = allowed.contains(permitted) ? permitted : 'none';
    res.set('X-Permitted-Cross-Domain-Policies', value);
  };
}
