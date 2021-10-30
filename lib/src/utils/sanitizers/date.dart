///
/// Convert the input to a date, or null if the input is not a date
///
DateTime? toDate(data) {
  try {
    return DateTime.parse(data);
  } catch (_) {
    return null;
  }
}
