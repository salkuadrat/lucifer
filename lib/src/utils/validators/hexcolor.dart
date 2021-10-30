///
/// Check if `data` is a hexadecimal color
///
bool isHexColor(data) {
  RegExp pattern = RegExp(r'^#?([0-9a-fA-F]{3}|[0-9a-fA-F]{6})$');
  return data is String && pattern.hasMatch(data);
}
