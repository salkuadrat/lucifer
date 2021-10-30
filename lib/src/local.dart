///
/// Local data for all requests
///
final Map<String, LocalData> locals = {};

///
/// Generate a new `LocalData` object with its corresponding unique key.
///
List generateLocal() {
  String key = DateTime.now().millisecondsSinceEpoch.toString();
  LocalData local = LocalData();
  addLocal(key, local);
  return [key, local];
}

///
/// Get `LocalData` associated with the specified key
///
LocalData? findLocal(String key) {
  return locals[key];
}

///
/// Set `LocalData` for the specified key
///
void addLocal(String key, LocalData local) {
  locals[key] = local;
}

///
/// Remove LocalData associated with the specified key
///
void removeLocal(String key) {
  if (locals.containsKey(key)) {
    locals.remove(key);
  }
}

///
/// Simple key value store to organize local data in the application
///
class LocalData {
  ///
  /// data holder
  ///
  final Map<String, dynamic> _data = {};

  ///
  /// Check if local data contains value of the specified key
  ///
  /// ```dart
  /// bool exist = req.locals.contains('user');
  /// ```
  ///
  bool contains(String key) {
    return _data.containsKey(key);
  }

  ///
  /// Save a value to local data with the specified key
  ///
  /// ```dart
  /// req.locals.set('user', User());
  /// ```
  ///
  set(String key, dynamic value) {
    _data[key] = value;
  }

  ///
  /// Returns a value associated with the specifed [key]
  /// Throw error if `null` or there's no value for this [key]
  ///
  /// ```dart
  /// User user = req.locals.get<User>('user');
  /// ```
  ///
  T get<T>(String key) {
    assert(contains(key), 'Store does not have value for $key');
    dynamic value = _data[key];
    assert(value is T, 'Store value for $key does not match type $T');
    return value as T;
  }

  ///
  /// Returns value associated with the specifed [key]
  /// Return [null] if there's no value for this [key]
  ///
  /// ```dart
  /// User? user = req.locals.get<User>('user');
  /// ```
  ///
  T? tryGet<T>(String key) {
    if (!contains(key)) return null;
    dynamic value = _data[key];
    assert(value is T, 'Store value for $key does not match type $T');
    return value as T;
  }

  ///
  /// Remove a value from local data associated with the specified [key]
  ///
  /// ```dart
  /// final removed = req.locals.remove('user');
  /// ```
  ///
  T? remove<T>(String key) {
    return _data.remove(key);
  }

  ///
  /// Clear all values in this local data
  ///
  /// ```dart
  /// req.locals.clear();
  /// ```
  ///
  clear() {
    _data.clear();
  }
}
