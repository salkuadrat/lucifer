///
/// Check if `data` length (in bytes) falls in a range.
///
bool isByteLength(data, int min, [int? max]) {
  return data.length >= min && (max == null || data.length <= max);
}
