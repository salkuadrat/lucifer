import 'blacklist.dart';

///
/// Remove characters with a numerical value < 32 and 127.
///
/// If `keep_new_lines` is `true`, newline characters are preserved
/// `(\n and \r, hex 0xA and 0xD)`.
String stripLow(data, [bool? keepNewLines]) {
  String chars =
      keepNewLines == true ? '\x00-\x09\x0B\x0C\x0E-\x1F\x7F' : '\x00-\x1F\x7F';
  return blacklist(data, chars);
}
