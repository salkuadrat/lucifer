import 'dart:convert';
/// 
/// Check if `data` is valid JSON
/// 
bool isJson(data) {
  try {
    jsonDecode(data);
  } catch (_) {
    return false;
  }
  return true;
}