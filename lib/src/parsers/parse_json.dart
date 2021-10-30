import 'dart:convert';

/// Parse json request body into map
/// 
Map<String, dynamic> parseJson(String body) {
  final json = jsonDecode(body);

  Map<String, dynamic> result = {};

  // convert all non-string key in json into string
  for (final key in json.keys) {
    result[key.toString()] = json[key];
  }

  return result;
}
