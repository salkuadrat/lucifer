import 'dart:convert';

import 'package:sanitize_html/sanitize_html.dart';

import '../request.dart';
import '../response.dart';
import '../typedef.dart';

/// 
/// Middleware to handle xss filtering.
/// 
Callback xssClean() {
  return (Req req, Res res) {
    var body = req.body;
    
    if (body is String) {
      req.body = sanitizeHtml(body);
    }

    if (body is Map || body is List) {
      req.body = jsonDecode(sanitizeHtml(jsonEncode(body)));
    }
  };
}
