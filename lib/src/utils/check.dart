import '../typedef.dart';
import 'sanitizers/sanitizers.dart' as s;
import 'validators/validators.dart' as v;

class Check {
  Check(this.name);

  final String name;

  bool? _result;

  String? _key = '';
  final Map<String, String> _messages = {};
  final List<Callback> _checks = [];
  final List<String> _errors = [];

  bool hasMessage(String key) => _messages.containsKey(key);

  void _check(bool? result, String key) {
    if (result == false) {
      if (hasMessage(key)) {
        _errors.add(_messages[key] as String);
      }
    }
  }

  Check isLength(int min, [int? max]) {
    _key = 'isLength';

    _checks.add((req, res) {
      _result = v.isLength(req.data(name), min);
      _check(_result, 'isLength');
    });

    return this;
  }

  Check isEmail() {
    _key = 'isEmail';

    _checks.add((req, res) {
      _result = v.isEmail(req.data(name));
      _check(_result, 'isEmail');
    });

    return this;
  }

  Check isNumeric() {
    _key = 'isNumeric';

    _checks.add((req, res) {
      _result = v.isNumeric(req.data(name));
      _check(_result, 'isNumeric');
    });

    return this;
  }

  Check contains(seed) {
    _key = 'contains';

    _checks.add((req, res) {
      _result = v.contains(req.data(name), seed);
      _check(_result, 'contains');
    });

    return this;
  }

  Check equals(comparison) {
    _key = 'equals';

    _checks.add((req, res) {
      _result = v.equals(req.data(name), comparison);
      _check(_result, 'equals');
    });

    return this;
  }

  Check isAlpha() {
    _key = 'isAlpha';

    _checks.add((req, res) {
      _result = v.isAlpha(req.data(name));
      _check(_result, 'isAlpha');
    });

    return this;
  }

  Check isAlphanumeric() {
    _key = 'isAlpha';

    _checks.add((req, res) {
      _result = v.isAlphanumeric(req.data(name));
      _check(_result, 'isAlpha');
    });

    return this;
  }

  Check isAscii() {
    _key = 'isAscii';

    _checks.add((req, res) {
      _result = v.isAscii(req.data(name));
      _check(_result, 'isAscii');
    });

    return this;
  }

  Check isBase64() {
    _key = 'isBase64';

    _checks.add((req, res) {
      _result = v.isBase64(req.data(name));
      _check(_result, 'isBase64');
    });

    return this;
  }

  Check isBoolean() {
    _key = 'isBoolean';

    _checks.add((req, res) {
      _result = req.data(name) is bool;
      _check(_result, 'isBoolean');
    });

    return this;
  }

  /// TODO
  Check isCurrency() {
    _key = 'isCurrency';

    _checks.add((req, res) {
      //_result = req.data(name) is bool;
      _check(_result, 'isCurrency');
    });

    return this;
  }

  Check isDecimal() {
    _key = 'isDecimal';

    _checks.add((req, res) {
      _result = v.isFloat(req.data(name));
      _check(_result, 'isDecimal');
    });

    return this;
  }

  Check isEmpty() {
    _key = 'isEmpty';

    _checks.add((req, res) {
      _result = v.isEmpty(req.data(name));
      _check(_result, 'isEmpty');
    });

    return this;
  }

  Check isFloat() {
    _key = 'isFloat';

    _checks.add((req, res) {
      _result = v.isFloat(req.data(name));
      _check(_result, 'isFloat');
    });

    return this;
  }

  // TODO
  Check isHash() {
    _key = 'isHash';

    _checks.add((req, res) {
      //_result = v.isFloat(req.data(name));
      _check(_result, 'isHash');
    });

    return this;
  }

  Check isHexColor() {
    _key = 'isHexColor';

    _checks.add((req, res) {
      _result = v.isHexColor(req.data(name));
      _check(_result, 'isHexColor');
    });

    return this;
  }

  Check isIP() {
    _key = 'isIP';

    _checks.add((req, res) {
      _result = v.isIP(req.data(name));
      _check(_result, 'isIP');
    });

    return this;
  }

  Check isInt() {
    _key = 'isInt';

    _checks.add((req, res) {
      _result = v.isInt(req.data(name));
      _check(_result, 'isInt');
    });

    return this;
  }

  Check isJson() {
    _key = 'isJson';

    _checks.add((req, res) {
      _result = v.isJson(req.data(name));
      _check(_result, 'isJson');
    });

    return this;
  }

  // TODO
  Check isLatLong() {
    _key = 'isLatLong';

    _checks.add((req, res) {
      //_result = v.isJson(req.data(name));
      _check(_result, 'isLatLong');
    });

    return this;
  }

  Check isLowercase() {
    _key = 'isLowercase';

    _checks.add((req, res) {
      _result = v.isLowercase(req.data(name));
      _check(_result, 'isLowercase');
    });

    return this;
  }

  /// TODO
  Check isMobilePhone() {
    return this;
  }

  Check isPostalCode(String locale) {
    _key = 'isPostalCode';

    _checks.add((req, res) {
      _result = v.isPostalCode(req.data(name), locale);
      _check(_result, 'isPostalCode');
    });

    return this;
  }

  Check isURL() {
    _key = 'isURL';

    _checks.add((req, res) {
      _result = v.isURL(req.data(name));
      _check(_result, 'isURL');
    });

    return this;
  }

  Check isUppercase() {
    _key = 'isUppercase';

    _checks.add((req, res) {
      _result = v.isUppercase(req.data(name));
      _check(_result, 'isUppercase');
    });

    return this;
  }

  /// TODO
  Check isWhitelisted() {
    return this;
  }

  Check isIn(List values) {
    _key = 'isIn';

    _checks.add((req, res) {
      _result = v.isIn(req.data(name), values);
      _check(_result, 'isIn');
    });

    return this;
  }

  Check isFQDN({
    bool requireTld = true,
    bool allowUnderscores = false,
  }) {
    _key = 'isFQDN';

    _checks.add((req, res) {
      _result = v.isFQDN(
        req.data(name),
        requireTld: requireTld,
        allowUnderscores: allowUnderscores,
      );
      _check(_result, 'isFQDN');
    });

    return this;
  }

  // For Dates

  Check isBefore([date]) {
    _key = 'isBefore';

    _checks.add((req, res) {
      _result = v.isBefore(req.data(name), date);
      _check(_result, 'isBefore');
    });

    return this;
  }

  Check isAfter([date]) {
    _key = 'isAfter';

    _checks.add((req, res) {
      _result = v.isAfter(req.data(name), date);
      _check(_result, 'isAfter');
    });

    return this;
  }

  /// TODO
  /* Check isISO8601() {
    _key = 'isISO8601';

    _checks.add((req, res) {
      //_result = v.isISO8601(req.data(name));
      _check(_result, 'isISO8601');
    });

    return this;
  } */

  /// TODO
  /* Check isRFC3339() {
    _key = 'isRFC3339';

    _checks.add((req, res) {
      //_result = v.isRFC3339(req.data(name));
      _check(_result, 'isRFC3339');
    });

    return this;
  } */

  // Regex

  Check matches(pattern) {
    _key = 'matches';

    _checks.add((req, res) {
      _result = v.matches(req.data(name), pattern);
      _check(_result, 'matches');
    });

    return this;
  }

  Check custom(String key, Function fn) {
    _key = key;

    _checks.add((req, res) {
      _result = fn.call(req.data(name));
      _check(_result, key);
    });

    return this;
  }

  Check withMessage(String message) {
    if (_key is String) {
      _messages[_key!] = message;
    }
    return this;
  }

  // Sanitize

  Check trim([String? chars]) {
    _checks.add((req, res) {
      dynamic data = req.data(name);
      if (data != null) {
        req.data(name, s.trim(data, chars));
      }
    });
    return this;
  }

  Check escape() {
    _checks.add((req, res) {
      dynamic data = req.data(name);
      if (data != null) {
        req.data(name, s.escape(data));
      }
    });
    return this;
  }

  Check normalizeEmail({bool lowercase = true}) {
    _checks.add((req, res) {
      dynamic data = req.data(name);
      if (data != null) {
        req.data(name, s.normalizeEmail(data, lowercase: lowercase));
      }
    });
    return this;
  }

  Check blacklist(String chars) {
    _checks.add((req, res) {
      dynamic data = req.data(name);
      if (data != null) {
        req.data(name, s.blacklist(data, chars));
      }
    });
    return this;
  }

  Check whitelist(String chars) {
    _checks.add((req, res) {
      dynamic data = req.data(name);
      if (data != null) {
        req.data(name, s.whitelist(data, chars));
      }
    });
    return this;
  }

  /// TODO
  /* Check unescape() {
    _checks.add((req, res) {
      dynamic data = req.data(name);
      if (data != null) {
        req.data(name, s.escape(data));
      }
    });
    return this;
  } */

  Check ltrim() {
    _checks.add((req, res) {
      dynamic data = req.data(name);
      if (data != null) {
        req.data(name, s.ltrim(data));
      }
    });
    return this;
  }

  Check rtrim() {
    _checks.add((req, res) {
      dynamic data = req.data(name);
      if (data != null) {
        req.data(name, s.rtrim(data));
      }
    });
    return this;
  }

  Check stripLow([bool? keepNewLines]) {
    _checks.add((req, res) {
      dynamic data = req.data(name);
      if (data != null) {
        req.data(name, s.stripLow(data, keepNewLines));
      }
    });
    return this;
  }

  Check toBool([bool? strict]) {
    _checks.add((req, res) {
      dynamic data = req.data(name);
      if (data != null) {
        req.data(name, s.toBool(data, strict));
      }
    });
    return this;
  }

  Check toDate() {
    _checks.add((req, res) {
      dynamic data = req.data(name);
      if (data != null) {
        req.data(name, s.toDate(data));
      }
    });
    return this;
  }

  Check toDouble() {
    _checks.add((req, res) {
      dynamic data = req.data(name);
      if (data != null) {
        req.data(name, s.toDouble(data));
      }
    });
    return this;
  }

  Check toInt({int radix = 10}) {
    _checks.add((req, res) {
      dynamic data = req.data(name);
      if (data != null) {
        req.data(name, s.toInt(data, radix: radix));
      }
    });
    return this;
  }

  Check customSanitizer(Function fn) {
    _checks.add((req, res) {
      dynamic data = req.data(name);
      if (data != null) {
        req.data(name, fn(data));
      }
    });
    return this;
  }
}
