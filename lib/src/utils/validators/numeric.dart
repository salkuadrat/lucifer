///
/// Check if `data` contains only numbers
///
bool isNumeric(data) {
  RegExp pattern = RegExp(r'^-?[0-9]+$');
  return data is num || (data is String && pattern.hasMatch(data));
}
