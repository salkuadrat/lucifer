///
/// Check if `data` contains only letters and numbers
///
bool isAlphanumeric(data) {
  RegExp pattern = RegExp(r'^[a-zA-Z0-9]+$');
  return data is String && pattern.hasMatch(data);
}
