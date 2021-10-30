import 'dart:convert';

/// Parse string value into its appropriate type
///
parseValue(String value) {
  // try parse null
  final isNull = value.trim().toLowerCase() == 'null';

  if (isNull) {
    return null;
  }

  // try parse json
  final isJson = value.startsWith('{') && value.endsWith('}');

  if (isJson) {
    final map = jsonDecode(value);

    if (map != null) {
      return map;
    }
  }

  // try parse json list
  final isJsonList = value.startsWith('[') && value.endsWith(']');

  if (isJsonList) {
    final list = jsonDecode(value);

    if (list != null) {
      return list;
    }
  }

  // try parse numeric
  final numValue = num.tryParse(value);

  if (numValue != null && !numValue.isNaN) {
    return numValue;
  }

  return value;
}
