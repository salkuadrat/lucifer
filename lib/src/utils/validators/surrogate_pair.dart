/// 
/// Check if `data` contains any surrogate pairs chars
/// 
bool isSurrogatePair(data) {
  RegExp pattern = RegExp(r'[\uD800-\uDBFF][\uDC00-\uDFFF]');
  return pattern.hasMatch(data);
}