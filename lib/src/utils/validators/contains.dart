///
/// check if `data` contains the `seed`
///
bool contains(data, seed) {
  return data is String && data.contains(seed.toString());
}
