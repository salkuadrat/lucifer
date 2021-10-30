///
/// Check if `data` is a float
///
bool isFloat(data) {
  RegExp pattern = RegExp(
    r'^(?:-?(?:[0-9]+))?(?:\.[0-9]*)?(?:[eE][\+\-]?(?:[0-9]+))?$',
  );
  return data is double || (data is String && pattern.hasMatch(data));
}
