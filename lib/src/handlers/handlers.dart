import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import '../exceptions.dart';
import '../request.dart';
import '../response.dart';
import '../socket.dart';

part 'binary.dart';
part 'file.dart';
part 'json.dart';
part 'numeric.dart';
part 'serializable.dart';
part 'socket.dart';
part 'string.dart';

class DataHandler<T> {
  final FutureOr Function(Req, Res, T) _process;

  DataHandler(this._process);

  FutureOr process(Req req, Res res, dynamic data) {
    return _process(req, res, data);
  }

  bool canHandle(dynamic data) {
    return data is T;
  }
}

///
/// beware of changing the order of this handlers
///
List<DataHandler> handlers = [
  numericHandler,
  stringHandler,
  listIntHandler,
  uint8ListHandler,
  binaryStreamHandler,
  jsonListHandler,
  jsonHandler,
  fileHandler,
  socketHandler,
  serializableHandler,
];
