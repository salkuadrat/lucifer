/// 
/// Check if `data` is a hexadecimal number
/// 
bool isHexadecimal(String str) {
  return RegExp(r'^[0-9a-fA-F]+$').hasMatch(str);
}