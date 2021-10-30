import '../validators/email.dart';

///
/// Canonicalize an email address.
///
/// `options` is an `Map` which defaults to
/// `{ lowercase: true }`. With lowercase set to true, the local part of the
/// email address is lowercased for all domains; the hostname is always
/// lowercased and the local part of the email address is always lowercased
/// for hosts that are known to be case-insensitive (currently only Gmail).
///
/// Normalization follows special rules for known providers: currently,
/// Gmail addresses have dots removed in the local part and are stripped of
/// tags (e.g. `some.one+tag@gmail.com` becomes `someone@gmail.com`) and all
/// `@googlemail.com` addresses are normalized to `@gmail.com`.
///
String normalizeEmail(data, {bool lowercase = true}) {
  if (isEmail(data) == false) {
    return '';
  }

  List parts = data.split('@');
  parts[1] = parts[1].toLowerCase();

  if (lowercase) {
    parts[0] = parts[0].toLowerCase();
  }

  if (parts[1] == 'gmail.com' || parts[1] == 'googlemail.com') {
    if (!lowercase) {
      parts[0] = parts[0].toLowerCase();
    }

    parts[0] = parts[0].replaceAll('.', '').split('+')[0];
    parts[1] = 'gmail.com';
  }

  return parts.join('@');
}

Map merge(Map? obj, defaults) {
  obj ??= {};
  defaults.forEach((key, val) => obj!.putIfAbsent(key, () => val));
  return obj;
}
