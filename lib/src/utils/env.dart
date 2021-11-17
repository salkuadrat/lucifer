import 'package:dotenv/dotenv.dart' as d;

/// get environment variable value based on key
dynamic env(String key) {
  String? value = d.env[key];

  if (value == null) {
    d.load();
    value = d.env[key];
  }

  if (value != null) {
    try {
      var numValue = num.tryParse(value);

      if (numValue != null && !numValue.isNaN) {
        return numValue;
      }
    } catch (_) {}
  }

  return value;
}
