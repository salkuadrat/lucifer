///
/// check if `data` is empty
///
bool isEmpty(data) {
  if (data is String || data is List || data is Map) {
    return data.isEmpty;
  }
  return false;
}
