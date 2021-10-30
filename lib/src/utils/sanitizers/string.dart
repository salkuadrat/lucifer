///
/// Convert `data` to a string
///
String toString(data) {
  if (data == null ||
      (data is List && data.isEmpty) ||
      (data is Map && data.isEmpty)) {
    return '';
  }

  return data.toString();
}
