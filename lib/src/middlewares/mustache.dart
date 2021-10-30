import 'dart:io';

import 'package:mustache_template/mustache_template.dart';

import '../request.dart';
import '../response.dart';
import '../typedef.dart';

///
/// Middleware to handle templating with Mustache.
///
Callback mustache([String? views]) {
  return (Req req, Res res) {
    res.renderer = (String view, Map<String, dynamic> data) async {
      String directory = views ?? 'views';
      File file = File('$directory/$view.html');
      
      if (await file.exists()) {
        Template template = Template(await file.readAsString());
        String html = template.renderString(data);
        await res.send(html);
      }
    };
  };
}
