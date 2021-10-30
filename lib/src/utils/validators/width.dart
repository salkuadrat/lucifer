///
/// Check if `data` contains any full-width chars
///
bool isFullWidth(data) {
  RegExp pattern = RegExp(
    r'[^\u0020-\u007E\uFF61-\uFF9F\uFFA0-\uFFDC\uFFE8-\uFFEE0-9a-zA-Z]',
  );
  return data is String && pattern.hasMatch(data);
}

///
/// Check if `data` contains any half-width chars
///
bool isHalfWidth(data) {
  RegExp pattern = RegExp(
    r'[\u0020-\u007E\uFF61-\uFF9F\uFFA0-\uFFDC\uFFE8-\uFFEE0-9a-zA-Z]',
  );
  return data is String && pattern.hasMatch(data);
}

/// 
/// Check if `data` contains a mixture of full and half-width chars
/// 
bool isVariableWidth(data) {
  return isFullWidth(data) && isHalfWidth(data);
}