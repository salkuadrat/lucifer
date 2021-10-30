/// 
/// Convert the input to a float, or NAN if the input is not a float
/// 
double toFloat(data) {
  if (data is double) {
    return data;
  }

  try {
    return double.parse(data);
  } catch (_) {
    return double.nan;
  }
}

/// 
/// Convert the input to a float, or NAN if the input is not a float
/// 
double toDouble(data) {
  return toFloat(data);
}