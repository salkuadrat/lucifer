///
/// Remove characters that do not appear in the whitelist.
///
/// The characters are used in a RegExp and so you will need to escape
/// some chars.
///
String whitelist(data, String chars) {
  if (data is! String) {
    return data;
  }

  RegExp pattern = RegExp('[^' + chars + ']+');
  return data.replaceAll(pattern, '');
}
