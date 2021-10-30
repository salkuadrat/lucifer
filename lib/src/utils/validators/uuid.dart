/// 
/// Check if `data` is a UUID (version 3, 4 or 5).
/// 
bool isUUID(data, [version]) {
  if (version == null) {
    version = 'all';
  } else {
    version = version.toString();
  }

  Map patterns = {
    '3': RegExp(
      r'^[0-9A-F]{8}-[0-9A-F]{4}-3[0-9A-F]{3}-[0-9A-F]{4}-[0-9A-F]{12}$',
    ),
    '4': RegExp(
      r'^[0-9A-F]{8}-[0-9A-F]{4}-4[0-9A-F]{3}-[89AB][0-9A-F]{3}-[0-9A-F]{12}$',
    ),
    '5': RegExp(
      r'^[0-9A-F]{8}-[0-9A-F]{4}-5[0-9A-F]{3}-[89AB][0-9A-F]{3}-[0-9A-F]{12}$',
    ),
    'all': RegExp(
      r'^[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}$',
    )
  };

  RegExp? pattern = patterns[version];
  return data is String && pattern != null && pattern.hasMatch(data.toUpperCase());
}
