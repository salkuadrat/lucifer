///
/// Check if `data` is base64 encoded
///
bool isBase64(data) {
  RegExp pattern = RegExp(
    r'^(?:[A-Za-z0-9+\/]{4})*(?:[A-Za-z0-9+\/]{2}==|[A-Za-z0-9+\/]{3}=|[A-Za-z0-9+\/]{4})$',
  );
  return data is String && pattern.hasMatch(data);
}
