part of 'handlers.dart';

DataHandler get serializableHandler {
  return DataHandler(_serializable);
}

FutureOr _serializable(Req req, Res res, data) async {
  try {
    data = data.toJson();
    await res.json(data);
  } on NoSuchMethodError catch (e) {
    throw HttpServerException(
      500,
      message: e.toString(),
      stackTrace: e.stackTrace,
    );
  }
}
