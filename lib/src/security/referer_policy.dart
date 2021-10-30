import '../request.dart';
import '../response.dart';
import '../typedef.dart';

///
/// The Referer HTTP header is typically set by web browsers to tell the server
/// where it's coming from.
///
/// For example, if you click a link on example.com/index.html that takes you
/// to wikipedia.org, Wikipedia's servers will see Referer: example.com.
///
/// This can have privacy implications—websites can see where you are
/// coming from. The new Referrer-Policy HTTP header lets authors control
/// how browsers set the Referer header.
///
Callback referrerPolicy({policy = 'no-referrer'}) {
  List<String> allowed = [
    'no-referrer',
    'no-referrer-when-downgrade',
    'same-origin',
    'origin',
    'strict-origin',
    'origin-when-cross-origin',
    'strict-origin-when-cross-origin',
    'unsafe-url',
    '',
  ];

  return (Req req, Res res) {
    String value = 'no-referer';

    if (policy is String) {
      if (allowed.contains(policy)) {
        value = policy;
      }
    }

    if (policy is List<String>) {
      List<String> values = [];

      for (String p in policy) {
        if (allowed.contains(p) && !values.contains(p)) {
          values.add(p);
        }
      }

      if (values.isNotEmpty) {
        value = values.join(',');
      }
    }

    res.set('Referrer-Policy', value);
  };
}
