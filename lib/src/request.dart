import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:mime/mime.dart';
import 'package:sanitize_html/sanitize_html.dart';

import 'log.dart';
import 'multipart.dart';
import 'method.dart';
import 'local.dart';
import 'app.dart';
import 'parsers/parsers.dart';
import 'uploaded_file.dart';

part 'request_extension.dart';

///
/// Req request object to handle incoming request.
///
class Req {
  ///
  /// Internal local key shared with the corresponding Res object
  ///
  final String _localKey;

  ///
  /// Internal HttpRequest used by this request
  ///
  final HttpRequest _req;

  ///
  Req(this._localKey, this._req);

  ///
  /// Reference to raw HttpRequest object.
  ///
  HttpRequest get request => _req;

  ///
  /// Session Store
  ///
  /// SessionStore? sessionStore;

  /// Session? session;

  ///
  /// Get local data attached with this request
  ///
  LocalData? get _localData {
    return findLocal(_localKey);
  }

  ///
  /// Get a value from local data associated with the specified key
  ///
  /// If `value` is set, it will write to local data.
  ///
  T? _local<T>(String key, [value]) {
    if (value == null) {
      return _localData?.tryGet<T>(key);
    }

    _localData?.set(key, value);
    return value;
  }

  ///
  /// Reference to the App instance that use request.
  ///
  App? get app {
    return _local<App>('___app___');
  }

  ///
  /// Logger attached to this request 
  /// 
  /// ```dart
  /// req.log.v(message);
  /// req.log.d(message);
  /// req.log.i(message);
  /// req.log.w(message);
  /// req.log.e(message);
  /// ```
  ///
  Log log = Log();

  ///
  /// logs the appropriate request messages
  ///
  void logs() {
    log.i('');
    log.i('$method ${uriString.trim()}');

    if (params.isNotEmpty) {
      log.i('Params: $params');
    }

    if (query.isNotEmpty) {
      log.i('Query: $query');
    }

    log.i('');
  }

  ///
  /// Get Content Type of this request.
  ///
  ContentType? get contentType => _req.contentType;

  String? get mimeType => contentType?.mimeType;

  bool get isJson => mimeType == 'application/json';

  bool get isUrlencoded => mimeType == 'application/x-www-form-urlencoded';

  bool get isText => mimeType == 'text/plain';

  bool get isMultipart =>
      contentType != null &&
      contentType!.primaryType == 'multipart' &&
      contentType!.parameters.containsKey('boundary');

  ///
  /// Get route params associated with this request.
  ///
  Map<String, dynamic> params = {};

  dynamic param(String key) {
    if (params.containsKey(key)) {
      return params[key];
    }
    return null;
  }
  
  ///
  /// Holds the list of uploaded files from multipart request body
  ///
  List<UploadedFile> files = [];

  ///
  /// Contains data submitted in the request body.
  ///
  /// By default, it is empty, and will be populated with
  /// key-value pairs when we use use the built in body parser middleware,
  /// such as `text()`, `json()`, `urlencoded()`, `multipart()` or `bodyParser()`
  ///
  /// Use `raw()` to save the raw bytes into this body.
  ///
  /// ```dart
  /// final app = App();
  ///
  /// app.use(json());
  /// app.use(urlencoded());
  /// app.use(multipart());
  ///
  /// app.post('/', (req, res) {
  ///   print(req.body);
  /// });
  /// ```
  ///
  dynamic body;

  ///
  /// Returns data from the body associated with the specified key.
  ///
  /// ```dart
  /// req.data('username');
  /// ```
  ///
  /// It's an alias for accessing req.body directly.
  ///
  /// ```dart
  /// req.body['username'];
  /// ```
  ///
  /// Use it also to add or replace data in the body.
  ///
  /// ```dart
  /// req.data('username', 'lucifer');
  /// ```
  ///
  dynamic data(String key, [value]) {
    if (body is Map<String, dynamic>) {
      if (value != null) {
        body[key] = value;
      }
      return body[key];
    }
    return null;
  }

  ///
  /// Checks if the request body contains the specified key
  ///
  bool hasData(String key) {
    if (body is Map<String, dynamic>) {
      return body.containsKey(key);
    }
    return false;
  }

  ///
  /// Contains the parsed query string from url.
  ///
  Map<String, dynamic> get query {
    if (_query.isEmpty) {
      final rawQuery = uri.query;
      final parsedQuery = parseUrlEncoded(rawQuery);
      _query = jsonDecode(sanitizeHtml(jsonEncode(parsedQuery)));
    }
    return _query;
  }

  ///
  /// Internal holder for the parsed query string
  ///
  Map<String, dynamic> _query = {};

  ///
  /// Returns query string value associated with the specified key.
  ///
  /// ```dart
  /// final username = req.q('username');
  /// ```
  ///
  /// It's an alias for accessing query directly.
  ///
  /// ```dart
  /// final username = req.query['username'];
  /// ```
  ///
  dynamic q(String key) => query[key];

  ///
  /// The content length of the request body.
  ///
  /// If the size of the request body is not known in advance,
  /// this value is -1
  ///
  int get contentLength => _req.contentLength;

  ///
  /// The method, such as 'GET' or 'POST', for the request.
  ///
  String get method => _req.method;

  ///
  /// The HTTP method, as [Method] enum
  ///
  Method get httpMethod => method.httpMethod;

  /// The URI for the request.
  ///
  /// This provides access to the path and query string for the request.
  ///
  Uri get uri => _req.uri;

  ///
  /// The URI String
  ///
  String get uriString => uri.toString();

  ///
  /// The URI path component
  ///
  String get path => uri.path;

  /// The request headers.
  ///
  /// The returned [HttpHeaders] are immutable.
  ///
  HttpHeaders get headers => _req.headers;

  String? header(String name) {
    return headers.value(name);
  }

  String? get(String name) {
    return header(name);
  }

  ///
  /// The cookies in the request, from the "Cookie" headers.
  ///
  List<Cookie> get cookies => _req.cookies;

  ///
  /// The client certificate of the client making the request.
  ///
  /// This value is null if the connection is not a secure TLS or SSL connection,
  /// or if the server does not request a client certificate, or if the client
  /// does not provide one.
  ///
  X509Certificate? get certificate => _req.certificate;

  ///
  /// true if a TLS connection is established
  ///
  bool get secure => certificate != null;

  ///
  /// Contains the request protocol string,
  /// either http or (for TLS requests) https
  ///
  String get protocol => certificate != null ? 'https' : 'http';

  ///
  /// Get or set session
  ///
  /// ```dart
  /// req.session(); // get all session values
  ///
  /// req.session('username'); // get a session value
  ///
  /// req.session('username', 'lucifer'); // set a session value
  /// ```
  ///
  session([String? name, value]) {
    if (name is String) {
      if (value != null) {
        _req.session[name] = value;
      }
      return _req.session[name];
    }

    Map sessions = <String, dynamic>{};

    for (var key in _req.session.keys) {
      sessions[key] = _req.session[key];
    }
    return sessions;
  }

  ///
  /// Check if the request is an XMLHttpRequest
  ///
  bool get xhr => headers.value('X-Requested-With') == 'xmlhttprequest';

  /// 
  /// Upgrade this request into a web socket
  /// 
  Future<WebSocket> get socket => WebSocketTransformer.upgrade(_req);
}
