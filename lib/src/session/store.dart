import 'package:uuid/uuid.dart';

import '../request.dart';
import 'session.dart';

class SessionStore {
  int get length => 0;

  List<Session> all() => [];

  Session? get(String sessionId) => null;

  Session? load(String sessionId) {
    return get(sessionId);
  }

  void set(String sessionId, Session session) {}

  bool destroy(String sessionId) {
    return false;
  }

  void clear() {}

  void touch(String sessionId, Session session) {}

  void Function(Req req)? generate;

  void regenerate(Req req) {
    /* if (req.session != null) {
      destroy(req.session!.id);
      generate?.call(req);
    } */
  }

  String generateSessionId() {
    return Uuid().v1();
  }

  /// 
  /// To be implemented by subclasses of `SessionStore` for use case
  /// 
  /// ```dart
  /// store.on('connect', () {
  ///   
  /// });
  /// 
  /// store.on('disconnect', () {
  ///   
  /// });
  /// ```
  void on(String event, Function callback) {}
}
