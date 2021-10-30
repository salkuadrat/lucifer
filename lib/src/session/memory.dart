import 'session.dart';
import 'store.dart';

class MemoryStore extends SessionStore {
  final Map<String, Session> _sessions = {};

  @override
  int get length => _sessions.length;

  @override
  List<Session> all() {
    return _sessions.entries.map((e) => e.value).toList();
  }

  @override
  Session? get(String sessionId) {
    return _getSession(sessionId);
  }

  @override
  void set(String sessionId, Session session) {
    _sessions[sessionId] = session;
  }

  @override
  bool destroy(String sessionId) {
    _sessions.remove(sessionId);
    return !_sessions.containsKey(sessionId);
  }

  @override
  void clear() {
    _sessions.clear();
  }

  @override
  void touch(String sessionId, Session session) {}

  Session? _getSession(String sessionId) {
    if (_sessions.containsKey(sessionId)) {
      Session session = _sessions[sessionId]!;

      if (session.hasCookie) {
        final expires = session.cookie?.expires;
        final now = DateTime.now().millisecondsSinceEpoch;

        if (expires != null && expires.millisecondsSinceEpoch <= now) {
          destroy(sessionId);
          return null;
        }
      }

      return session;
    }

    return null;
  }
}
