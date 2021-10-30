///
/// Convert the input to a boolean.
///
/// Everything except for '0', 'false' and ''
/// returns `true`. In `strict` mode only '1' and 'true' return `true`.
///
bool toBool(data, [bool? strict]) {
  if (strict == true) {
    return data == true || data == 1 || data == '1' || data == 'true';
  }

  return data != null &&
      data != false &&
      data != 0 &&
      data != '0' &&
      data != 'false' &&
      data != '';
}
