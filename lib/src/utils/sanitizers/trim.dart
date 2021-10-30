///
/// trim characters (whitespace by default) from both sides of the input
///
String trim(data, [String? chars]) {
  if (data is! String) {
    return data;
  }

  if (chars == null) {
    return data.trim();
  }

  RegExp pattern = RegExp('^[$chars]+|[$chars]+\$');
  return data.replaceAll(pattern, '');
}

///
/// trim characters from the left-side of the input
///
String ltrim(data, [String? chars]) {
  if (data is! String) {
    return data;
  }

  if (chars == null) {
    return data.trimLeft();
  }

  RegExp pattern = RegExp('^[$chars]+');
  return data.replaceAll(pattern, '');
}

///
/// trim characters from the right-side of the input
///
String rtrim(data, [String? chars]) {
  if (data is! String) {
    return data;
  }

  if (chars == null) {
    return data.trimRight();
  }

  RegExp pattern = RegExp('[$chars]+\$');
  return data.replaceAll(pattern, '');
}
