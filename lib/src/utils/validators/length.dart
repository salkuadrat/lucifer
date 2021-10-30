///
/// Check if the length of `data` falls in a range
///
bool isLength(data, int min, [int? max]) {
  if (data is! String) {
    return false;
  }

  List pairs = RegExp(
    r'[\uD800-\uDBFF][\uDC00-\uDFFF]',
  ).allMatches(data).toList();

  int len = data.length - pairs.length;
  return len >= min && (max == null || len <= max);
}
