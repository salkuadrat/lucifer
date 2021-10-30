import 'dart:async';

import 'parsers.dart';
import '../request.dart';
import '../uploaded_file.dart';

class FormParser {
  FormParser();

  void Function(String name, Object field)? _onFieldListener;
  void Function(String name, UploadedFile file)? _onFileListener;
  void Function(dynamic error)? _onErrorListener;
  void Function()? _onEndListener;

  FormParser on(String key, Function listener) {
    switch (key) {
      case 'field':
        _onFieldListener = listener as void Function(String name, Object field);
        break;
      case 'file':
        _onFileListener =
            listener as void Function(String name, UploadedFile file);
        break;
      case 'error':
        _onErrorListener = listener as void Function(dynamic error);
        break;
      case 'end':
        _onEndListener = listener as void Function();
        break;
    }

    return this;
  }

  FormParser onField(void Function(String name, Object field) listener) {
    _onFieldListener = listener;
    return this;
  }

  FormParser onFile(void Function(String name, UploadedFile file) listener) {
    _onFileListener = listener;
    return this;
  }

  FormParser onError(void Function(dynamic error) listener) {
    _onErrorListener = listener;
    return this;
  }

  FormParser onEnd(void Function() listener) {
    _onEndListener = listener;
    return this;
  }

  FutureOr parse(
    Req req, [
    void Function(
      dynamic error,
      Map<String, dynamic> fields,
      List files,
    )?
        listener,
  ]) async {
    if (req.isMultipart) {
      final result = await parseMultipart(
        req,
        onFieldListener: _onFieldListener,
        onFileListener: _onFileListener,
        onErrorListener: _onErrorListener,
        onEndListener: _onEndListener,
      );

      if (result is List && result.length == 2) {
        req.body = result[0];
        req.files = result[1];
        listener?.call(null, req.body, req.files);
      } else {
        listener?.call(result, {}, []);
      }
    }
  }
}
