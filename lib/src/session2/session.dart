import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:uuid/uuid.dart';

class Session implements HttpSession {
  bool _destroyed = false;
  bool _isNew = true;
  DateTime _lastSeen;
  Function? _timeoutCallback;

  SessionManager _sessionManager;

  Session? _prev;
  Session? _next;

  final String _id;

  final Map _data = HashMap();

  Session(this._sessionManager, this._id) : _lastSeen = DateTime.now();

  @override
  String get id => _id;

  @override
  bool get isNew => _isNew;

  DateTime get lastSeen => _lastSeen;

  @override
  void destroy() {
    assert(!_destroyed);
    _destroyed = true;
    _sessionManager._removeFromTimeoutQueue(this);
    _sessionManager._sessions.remove(id);
  }

  void _markSeen() {
    _lastSeen = DateTime.now();
    _sessionManager._bumpToEnd(this);
  }

  @override
  set onTimeout(void Function() callback) {
    _timeoutCallback = callback;
  }

  @override
  bool containsKey(key) => _data.containsKey(key);

  @override
  bool containsValue(value) => _data.containsValue(value);

  @override
  operator [](key) => _data[key];

  @override
  void operator []=(key, value) {
    _data[key] = value;
  }

  @override
  putIfAbsent(key, ifAbsent) {
    _data.putIfAbsent(key, ifAbsent);
  }

  @override
  void addAll(Map other) => _data.addAll(other);

  @override
  void addEntries(Iterable<MapEntry> entries) {
    _data.addEntries(entries);
  }

  @override
  Map<RK, RV> cast<RK, RV>() => _data.cast<RK, RV>();

  @override
  Iterable<MapEntry> get entries => _data.entries;

  @override
  void forEach(Function(dynamic key, dynamic value) fn) {
    _data.forEach(fn);
  }

  @override
  bool get isEmpty => _data.isEmpty;

  @override
  bool get isNotEmpty => _data.isNotEmpty;

  @override
  Iterable get keys => _data.keys;

  @override
  Iterable get values => _data.values;

  @override
  int get length => _data.length;

  @override
  Map<K2, V2> map<K2, V2>(
    MapEntry<K2, V2> Function(dynamic key, dynamic value) convert,
  ) {
    return _data.map(convert);
  }

  @override
  update(key, Function(dynamic value) update, {Function()? ifAbsent}) {
    _data.update(key, update, ifAbsent: ifAbsent);
  }

  @override
  void updateAll(Function(dynamic key, dynamic value) update) {
    _data.updateAll(update);
  }

  @override
  remove(key) => _data.remove(key);

  @override
  void removeWhere(bool Function(dynamic, dynamic) test) {
    _data.removeWhere(test);
  }

  @override
  void clear() => _data.clear();
}

class SessionManager {
  final Map<String, Session> _sessions = {};

  int _sessionTimeout = 20 * 60; // 20 mins.
  Session? _head;
  Session? _tail;
  Timer? _timer;

  SessionManager();

  String createSessionId() {
    return Uuid().v4();
  }

  Session? getSession(String id) => _sessions[id];

  Session createSession() {
    String id = createSessionId();

    while (_sessions.containsKey(id)) {
      id = createSessionId();
    }

    Session session = _sessions[id] = Session(this, id);
    _addToTimeoutQueue(session);
    return session;
  }

  set sessionTimeout(int timeout) {
    _sessionTimeout = timeout;
    _stopTimer();
    _startTimer();
  }

  void close() {
    _stopTimer();
  }

  void _bumpToEnd(Session session) {
    _removeFromTimeoutQueue(session);
    _addToTimeoutQueue(session);
  }

  void _addToTimeoutQueue(Session session) {
    if (_head == null) {
      assert(_tail == null);
      _tail = _head = session;
      _startTimer();
    } else {
      assert(_timer != null);
      var tail = _tail!;
      // Add to end.
      tail._next = session;
      session._prev = tail;
      _tail = session;
    }
  }

  void _removeFromTimeoutQueue(Session session) {
    var next = session._next;
    var prev = session._prev;
    session._next = session._prev = null;
    next?._prev = prev;
    prev?._next = next;

    if (_tail == session) {
      _tail = prev;
    }
    
    if (_head == session) {
      _head = next;
      // We removed the head element, start new timer.
      _stopTimer();
      _startTimer();
    }
  }

  void _timerTimeout() {
    _stopTimer(); // Clear timer.
    Session session = _head!;
    session.destroy(); // Will remove the session from timeout queue and map.
    session._timeoutCallback?.call();
  }

  void _startTimer() {
    assert(_timer == null);
    var head = _head;
    if (head != null) {
      int seconds = DateTime.now().difference(head.lastSeen).inSeconds;
      _timer = Timer(
        Duration(seconds: _sessionTimeout - seconds),
        _timerTimeout,
      );
    }
  }

  void _stopTimer() {
    var timer = _timer;
    if (timer != null) {
      timer.cancel();
      _timer = null;
    }
  }
}
