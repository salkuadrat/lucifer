///
/// Log object to be used as interface between 
/// logging middleware and Req Res
///
class Log {
  void Function(String message) v = print;
  void Function(String message) d = print;
  void Function(String message) i = print;
  void Function(String message) w = print;
  void Function(String message) e = print;
}