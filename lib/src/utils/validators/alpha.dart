///
/// check if the string `data` contains only letters (a-zA-Z).
///
bool isAlpha(data) {
  RegExp pattern = RegExp(r'^[a-zA-Z]+$');
  return data is String && pattern.hasMatch(data);
}
