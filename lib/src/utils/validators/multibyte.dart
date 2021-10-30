/// 
/// check if `data` contains one or more multibyte chars
/// 
bool isMultibyte(data) {
  return RegExp(r'[^\x00-\x7F]').hasMatch(data);
}