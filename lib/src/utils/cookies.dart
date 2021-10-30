import 'dart:convert';
import 'dart:io';

import 'package:cryptography/cryptography.dart';

///
/// Utility for encryption & decryption of secure cookie
///
class Cookies {
  final List<int> secret;

  Cookies(this.secret) {
    if (secret.length != 32) {
      throw Exception(
        'Expected secret key length is 32, but got: ${secret.length}',
      );
    }
  }

  Future<Cookie> encrypt(Cookie cookie) async {
    final algorithm = AesGcm.with256bits(nonceLength: 12);
    final key = await algorithm.newSecretKeyFromBytes(secret);
    final valueBytes = utf8.encode(cookie.value);
    final secretBox = await algorithm.encrypt(valueBytes, secretKey: key);
    final encryptedValue = base64Url.encode(secretBox.concatenation());

    return _cookie(
      cookie.name,
      encryptedValue,
      domain: cookie.domain,
      path: cookie.path,
      expires: cookie.expires,
      httpOnly: cookie.httpOnly,
      secure: cookie.secure,
      maxAge: cookie.maxAge,
    );
  }

  Future<Cookie> decrypt(Cookie encryptedCookie) async {
    Cookie cookie = _cookie(
      encryptedCookie.name,
      encryptedCookie.value,
      domain: encryptedCookie.domain,
      path: encryptedCookie.path,
      expires: encryptedCookie.expires,
      httpOnly: encryptedCookie.httpOnly,
      secure: encryptedCookie.secure,
      maxAge: encryptedCookie.maxAge,
    );

    final decoded = base64Url.decode(cookie.value);

    if (decoded.length <= 12 + 16) {
      throw Exception('Wrong encrypted cookie length');
    }

    final algorithm = AesGcm.with256bits();
    final key = await algorithm.newSecretKeyFromBytes(secret);
    final cipherText = decoded.skip(12).take(decoded.length - 12 - 16).toList();
    final nonce = decoded.take(12).toList();
    final length = nonce.length + cipherText.length;
    final mac = decoded.skip(length).take(16).toList();

    final box = SecretBox(
      cipherText,
      nonce: nonce,
      mac: Mac(mac),
    );

    final bytes = await algorithm.decrypt(box, secretKey: key);
    cookie.value = utf8.decode(bytes);
    return cookie;
  }

  Cookie _cookie(
    String name,
    String value, {
    String? domain,
    String? path,
    DateTime? expires,
    bool? httpOnly,
    bool? secure,
    int? maxAge,
  }) {
    Cookie cookie = Cookie(name, value);

    if (domain != null) cookie.domain = domain;
    if (path != null) cookie.path = path;
    if (expires != null) cookie.expires = expires;
    if (httpOnly != null) cookie.httpOnly = httpOnly;
    if (secure != null) cookie.secure = secure;
    if (maxAge != null) cookie.maxAge = maxAge;

    return cookie;
  }
}
