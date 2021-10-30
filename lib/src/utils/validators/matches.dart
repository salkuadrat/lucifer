///
/// check if `data` matches the [pattern].
///
bool matches(data, pattern) {
  RegExp re = RegExp(pattern);
  return data is String && re.hasMatch(data);
}
