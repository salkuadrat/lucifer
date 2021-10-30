import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http_status_code/http_status_code.dart';
import 'package:mime_type/mime_type.dart';

import 'log.dart';
import 'request.dart';
import 'utils/cookies.dart';
import 'app.dart';
import 'local.dart';
import 'exceptions.dart';

///
/// Response object to handle response to the client.
///
class Res {
  ///
  /// Internal local key shared with corresponding Res response object
  ///
  final String _localKey;

  ///
  /// Internal HttpResponse used by this response
  ///
  final HttpResponse _res;

  ///
  Res(this._localKey, this._res);

  ///
  /// HttpResponse object attached to this response
  ///
  HttpResponse get response => _res;

  ///
  /// Checks if this response has been closed.
  ///
  /// It's important to prevent a 'headers have been sent' error.
  ///
  bool closed = false;

  ///
  /// Check if this response is still open to send data
  ///
  bool get open => !closed;

  ///
  /// Get local data attached with this response
  ///
  LocalData? get _localData {
    return findLocal(_localKey);
  }

  ///
  /// Get a value from local data associated with the specified key
  ///
  /// If `value` is set, it will write to local data.
  ///
  T? local<T>(String key, [value]) {
    if (value == null) {
      return _localData?.tryGet<T>(key);
    }

    _localData?.set(key, value);
    return value;
  }

  ///
  /// Remove value in local data associated with the specified key
  ///
  T? removeLocal<T>(String key) {
    return _localData?.remove(key);
  }

  ///
  /// Reference to the App instance that use this response.
  ///
  App? get app {
    return local<App>('___app___');
  }

  Req? get _req {
    return local<Req>('___req___');
  }

  ///
  /// Logger attached to this response
  ///
  /// ```dart
  /// res.log.v(message);
  /// res.log.d(message);
  /// res.log.i(message);
  /// res.log.w(message);
  /// res.log.e(message);
  /// ```
  ///
  Log log = Log();

  ///
  /// Result from a previous middleware.
  ///
  dynamic result;

  ///
  /// Check if this response has a valid result from previous middleware.
  ///
  bool get hasValidResult => result != null && result is! bool;

  ///
  /// `SecureCookie` object to be used to set secure cookies.
  ///
  Cookies? secureCookie;

  ///
  /// Sets the HTTP response header `field` to `value`.
  ///
  /// To set multiple fields at once, pass a map object as the parameter.
  ///
  void set(dynamic name, [String? value]) {
    if (value == null && name is Map<String, String>) {
      name.forEach((k, v) {
        _res.headers.set(k, v);
      });
    }

    if (name is String && value is String) {
      _res.headers.set(name, value);
    }
  }

  ///
  /// Get the HTTP response header associated with the specified field.
  ///
  String? get(String name) {
    return headers.value(name);
  }

  void remove(String name) {
    _res.headers.removeAll(name);
  }

  ///
  /// Can be used for both set or get the headers value.
  ///
  /// ```dart
  /// res.header('x-access-token'); // get header value
  /// ```
  ///
  /// or
  ///
  /// ```dart
  /// res.header('x-access-token', token); // set header value
  /// ```
  ///
  String? header(String name, [String? value]) {
    if (value == null) {
      return get(name);
    } else {
      set(name, value);
    }
  }

  ///
  /// Set the response status code.
  ///
  Res status(int statusCode) {
    _res.statusCode = statusCode;
    return this;
  }

  ///
  /// Set the response status code and send a message containing
  /// the associated status string.
  ///
  Future sendStatus(int statusCode) async {
    status(statusCode);
    await send('$statusCode ${getStatusMessage(statusCode)}');
  }

  ///
  /// Update the response content type associated with the specified type.
  ///
  /// Can use both
  ///
  /// ```dart
  /// res.type('json');
  ///
  /// or
  ///
  /// res.type('application/json');
  /// ```
  ///
  void type(String type) {
    if (type.contains('/')) {
      _res.headers.set('Content-Type', type);
    } else {
      _res.headers.set(
        'Content-Type',
        mimeFromExtension(type) ?? 'text/plain',
      );
    }
  }

  ///
  /// Redirects to the URL derived from the specified path,
  /// with specified status, a positive integer that corresponds
  /// to an HTTP status code.
  ///
  /// If not specified, status defaults to `302`.
  ///
  /// ```dart
  /// res.redirect('/foo/bar');
  /// res.redirect('http://example.com');
  /// res.redirect(301, 'http://example.com');
  /// res.redirect('../login');
  /// ```
  ///
  Future redirect(path, [String? fallback]) async {
    if (closed) {
      return;
    }

    int status = 302;

    if (path is int && fallback != null) {
      status = path;
      path = fallback;
    }

    if (path is String) {
      if (path.startsWith('..')) {
        return await back();
      }

      log.i('Redirect: $path');
      await _res.redirect(Uri.parse(path), status: status);
      await close();
    }
  }

  Future to(path, [String? fallback]) async {
    await redirect(path, fallback);
  }

  ///
  /// Redirect back to previous path, based on Referer from request header.
  ///
  Future back() async {
    String referer = _req?.get('Referer') ?? _req?.get('Referrer') ?? '/';
    await redirect(referer);
  }

  ///
  /// Send a file to download with optional filename.
  ///
  /// Alias of `res.sendFile()`
  ///
  Future download(file, [String? filename]) async {
    return await sendFile(file, filename);
  }

  ///
  /// Send a file to the response with optional filename.
  ///
  Future sendFile(file, [String? filename]) async {
    if (closed) {
      return;
    }

    file = file is File
        ? file
        : file is String
            ? File(file)
            : null;

    if (file is File && await file.exists()) {
      if (filename is String) {
        header(
          'Content-Disposition',
          'attachment; filename=$filename',
        );
      }

      try {
        setContentTypeFromFile(file);
        await addStream(file.openRead());
        await close();
      } catch (e) {
        throw InternalErrorException(message: e.toString());
      }
    } else {
      throw NotFoundException(
        message: 'Requested File Not Found',
      );
    }
  }

  ///
  /// Contents of `Set-Cookie` header of this response
  ///
  List<Cookie> get cookies => _res.cookies;

  ///
  /// Add or edit a response cookie.
  ///
  Future cookie(
    String name,
    dynamic value, {
    String? domain,
    String path = '/',
    DateTime? expires,
    int? maxAge,
    bool httpOnly = true,
    bool secure = false,
    bool signed = false,
  }) async {
    Cookie cookie = Cookie(name, value);

    cookie.domain = domain;
    cookie.path = path;
    cookie.expires = expires;
    cookie.maxAge = maxAge;
    cookie.httpOnly = httpOnly;
    cookie.secure = secure;

    int index = cookies.indexWhere((c) => c.name == name);

    if (index >= 0) {
      cookies.removeAt(index);
      cookies.insert(index, cookie);
    } else {
      cookies.add(cookie);
    }
  }

  ///
  /// Clear a cookie by name.
  ///
  void clearCookie(String name) {
    _res.cookies.removeWhere((c) => c.name == name);
  }

  ///
  /// Clear all cookies.
  ///
  void clearCookies() {
    _res.cookies.clear();
  }

  ///
  /// Secure cookies if the app use secure cookie mechanism,
  /// either set from `secureCookie` middleware or from `session` middleware
  ///
  FutureOr _secureCookies() async {
    if (secureCookie is Cookies) {
      for (int i = 0; i < cookies.length; i++) {
        Cookie cookie = await secureCookie!.encrypt(_res.cookies[i]);
        cookies.removeAt(i);
        cookies.insert(i, cookie);
      }
    }
  }

  ///
  /// Sends the HTTP response.
  ///
  /// The `data` can be any dart object.
  ///
  Future send(Object data) async {
    if (closed) {
      return;
    }

    await _secureCookies();

    if (data is String || data is num) {
      setContentType(ContentType.html);
    }

    if (data is Map || data is List) {
      setContentType(ContentType.json);
      data = jsonEncode(data);
    }

    _res.write(data);

    await _res.flush();
    await close();

    log.i('Response: ${_res.statusCode} $data');
  }

  ///
  /// Sends a JSON response.
  ///
  /// This method sends a response (with the correct content-type)
  /// that is the parameter converted to a JSON string using [jsonEncode].
  ///
  FutureOr json(Object data) async {
    await send(data);
  }

  ///
  /// Ends the response by sending empty string to the client,
  /// and close the connection
  ///
  FutureOr end() async {
    await send('');
  }

  FutureOr Function(String view, Map<String, dynamic> data)? renderer;

  ///
  /// Render a template view
  ///
  // ignore: prefer_function_declarations_over_variables
  FutureOr render(String view, Map<String, dynamic> data) async {
    await renderer?.call(view, data);
  }

  FutureOr view(String view, Map<String, dynamic> data) async {
    await render(view, data);
  }

  /// The status code of the response.
  ///
  /// Any integer value is accepted. For
  /// the official HTTP status codes use the fields from
  /// [HttpStatus]. If no status code is explicitly set the default
  /// value [HttpStatus.ok] is used.
  ///
  /// The status code must be set before the body is written
  /// to. Setting the status code after writing to the response body or
  /// closing the response will throw a `StateError`.
  ///
  int get statusCode => _res.statusCode;

  /// Returns the response headers.
  ///
  /// The response headers can be modified until the response body is
  /// written to or closed. After that they become immutable.
  ///
  HttpHeaders get headers => _res.headers;

  /// Check if content type of response is `text/plain`
  ///
  bool get isContentText => contentType?.value == 'text/plain';

  /// Response Content-Type header.
  ///
  ContentType? get contentType => headers.contentType;

  /// Set response content type.
  ///
  void setContentType(ContentType? contentType) {
    headers.contentType = contentType;
  }

  /// Set response content type from file.
  ///
  void setContentTypeFromFile(File file) {
    if (file.contentType != null) {
      setContentType(file.contentType);
    } else {
      setContentType(ContentType.binary);
    }
  }

  /// Set the content type from the extension ie. 'pdf'
  ///
  void setContentTypeFromExtension(String extension) {
    final mime = mimeFromExtension(extension);

    if (mime != null) {
      final split = mime.split('/');

      if (split.length == 2) {
        headers.contentType = ContentType(
          split[0],
          split[1],
        );
      }
    }
  }

  /// Adds byte [data] to the target consumer, ignoring [encoding].
  ///
  /// The [encoding] does not apply to this method, and the [data] list is passed
  /// directly to the target consumer as a stream event.
  ///
  /// This function must not be called when a stream is currently being added
  /// using [addStream].
  ///
  /// This operation is non-blocking. See [flush] or [done] for how to get any
  /// errors generated by this call.
  ///
  /// The data list should not be modified after it has been passed to `add`.
  ///
  void add(List<int> data) {
    _res.add(data);
  }

  ///
  /// Adds all elements of the given [stream].
  ///
  /// Returns a [Future] that completes when
  /// all elements of the given [stream] have been added.
  ///
  /// If the stream contains an error, the `addStream` ends at the error,
  /// and the returned future completes with that error.
  ///
  /// This function must not be called when a stream is currently being added
  /// using this function.
  ///
  Future addStream(Stream<List<int>> stream) async {
    await _res.addStream(stream);
  }

  ///
  /// Close the target consumer.
  ///
  /// NOTE: Writes to the [IOSink] may be buffered, and may not be flushed by
  /// a call to `close()`. To flush all buffered writes, call `flush()` before
  /// calling `close()`.
  Future close() async {
    closed = true;
    await _res.close();
  }
}

extension FileExtension on File {
  ///
  /// Get mime type of this file.
  ///
  String? get mimeType => mime(path);

  ///
  /// Get content type of this file.
  ///
  ContentType? get contentType {
    if (mimeType != null) {
      final types = mimeType!.split('/');

      if (types.length > 1) {
        return ContentType(types[0], types[1]);
      }
    }
  }
}
