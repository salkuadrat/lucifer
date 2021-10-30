///
/// Check if `data` is a number that's divisible by another
///
/// [n] is a String or an int.
///
bool isDivisibleBy(data, n) {
  try {
    return double.parse(data) % int.parse(n) == 0;
  } catch (e) {
    return false;
  }
}
