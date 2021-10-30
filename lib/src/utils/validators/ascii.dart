///
/// Check if `data` contains ASCII chars only
///
bool isAscii(data) {
  RegExp pattern = RegExp(r'^[\x00-\x7F]+$');
  return data is String && pattern.hasMatch(data);
}
