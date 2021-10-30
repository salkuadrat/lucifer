///
/// Convert the input to an integer, or NAN if the input is not an integer
///
num toInt(data, {int radix = 10}) {
  if (data is int) {
    return data;
  }

  try {
    return int.parse(data, radix: radix);
  } catch (_) {
    try {
      return double.parse(data).toInt();
    } catch (_) {
      return double.nan;
    }
  }
}
