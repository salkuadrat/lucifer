///
/// check if `data` is a date
///
bool isDate(data) {
  try {
    DateTime.parse(data);
    return true;
  } catch (e) {
    return false;
  }
}

/// Check if `data` is a date after the specified date
///
/// If `date` is not passed, it defaults to now.
///
bool isAfter(data, [date]) {
  if (date == null) {
    date = DateTime.now();
  } else if (isDate(date)) {
    date = DateTime.parse(date);
  } else {
    return false;
  }

  try {
    return DateTime.parse(data).isAfter(date);
  } catch (e) {
    return false;
  }
}

/// Check if `data` is a date before the specified date
///
/// If `date` is not passed, it defaults to now.
bool isBefore(data, [date]) {
  if (date == null) {
    date = DateTime.now();
  } else if (isDate(date)) {
    date = DateTime.parse(date);
  } else {
    return false;
  }

  try {
    return DateTime.parse(data).isBefore(date);
  } catch (e) {
    return false;
  }
}
