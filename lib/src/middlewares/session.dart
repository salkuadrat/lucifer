import 'dart:convert';
import 'dart:io';

import 'package:cryptography/cryptography.dart';

import '../utils/cookies.dart';
import '../request.dart';
import '../response.dart';
import '../typedef.dart';

///
/// Middleware to manage sessions.
///
Callback session({required String secret}) {
  return (Req req, Res res) async {
    Hash hash = await Sha256().hash(utf8.encode(secret));
    Cookies cookies = Cookies(hash.bytes);

    for (int i = 0; i < req.cookies.length; i++) {
      try {
        Cookie cookie = await cookies.decrypt(req.cookies[i]);
        req.cookies.replaceRange(i, i + 1, [cookie]);
      } catch (_) {}
    }

    res.secureCookie = cookies;
  };
}
