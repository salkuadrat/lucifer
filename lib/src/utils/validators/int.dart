///
/// Check if `data` is an integer
///
bool isInt(data) {
  RegExp pattern = RegExp(r'^(?:-?(?:0|[1-9][0-9]*))$');
  return data is int || (data is String && pattern.hasMatch(data));
}
