/// 
/// replace `<`, `>`, `&`, `'` and `"` with HTML entities
/// 
String escape(data) {
  if (data is! String) {
    return data;
  }

  return data
      .replaceAll(RegExp(r'&'), '&amp;')
      .replaceAll(RegExp(r'"'), '&quot;')
      .replaceAll(RegExp(r"'"), '&#x27;')
      .replaceAll(RegExp(r'<'), '&lt;')
      .replaceAll(RegExp(r'>'), '&gt;');
}
