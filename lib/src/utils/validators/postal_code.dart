bool isPostalCode(data, String locale) {
  RegExp? pattern = _postalCodePatterns[locale];
  return pattern != null ? pattern.hasMatch(data) : false;
}

var _threeDigit = RegExp(r'^\d{3}$');
var _fourDigit = RegExp(r'^\d{4}$');
var _fiveDigit = RegExp(r'^\d{5}$');
var _sixDigit = RegExp(r'^\d{6}$');
var _postalCodePatterns = {
  "AD": RegExp(r'^AD\d{3}$'),
  "AT": _fourDigit,
  "AU": _fourDigit,
  "BE": _fourDigit,
  "BG": _fourDigit,
  "CA": RegExp(
      r'^[ABCEGHJKLMNPRSTVXY]\d[ABCEGHJ-NPRSTV-Z][\s\-]?\d[ABCEGHJ-NPRSTV-Z]\d$',
      caseSensitive: false),
  "CH": _fourDigit,
  "CZ": RegExp(r'^\d{3}\s?\d{2}$'),
  "DE": _fiveDigit,
  "DK": _fourDigit,
  "DZ": _fiveDigit,
  "EE": _fiveDigit,
  "ES": _fiveDigit,
  "FI": _fiveDigit,
  "FR": RegExp(r'^\d{2}\s?\d{3}$'),
  "GB": RegExp(r'^(gir\s?0aa|[a-z]{1,2}\d[\da-z]?\s?(\d[a-z]{2})?)$',
      caseSensitive: false),
  "GR": RegExp(r'^\d{3}\s?\d{2}$'),
  "HR": RegExp(r'^([1-5]\d{4}$)'),
  "HU": _fourDigit,
  "ID": _fiveDigit,
  "IL": _fiveDigit,
  "IN": _sixDigit,
  "IS": _threeDigit,
  "IT": _fiveDigit,
  "JP": RegExp(r'^\d{3}\-\d{4}$'),
  "KE": _fiveDigit,
  "LI": RegExp(r'^(948[5-9]|949[0-7])$'),
  "LT": RegExp(r'^LT\-\d{5}$'),
  "LU": _fourDigit,
  "LV": RegExp(r'^LV\-\d{4}$'),
  "MX": _fiveDigit,
  "NL": RegExp(r'^\d{4}\s?[a-z]{2}$', caseSensitive: false),
  "NO": _fourDigit,
  "PL": RegExp(r'^\d{2}\-\d{3}$'),
  "PT": RegExp(r'^\d{4}\-\d{3}?$'),
  "RO": _sixDigit,
  "RU": _sixDigit,
  "SA": _fiveDigit,
  "SE": RegExp(r'^\d{3}\s?\d{2}$'),
  "SI": _fourDigit,
  "SK": RegExp(r'^\d{3}\s?\d{2}$'),
  "TN": _fourDigit,
  "TW": RegExp(r'^\d{3}(\d{2})?$'),
  "UA": _fiveDigit,
  "US": RegExp(r'^\d{5}(-\d{4})?$'),
  "ZA": _fourDigit,
  "ZM": _fiveDigit
};
