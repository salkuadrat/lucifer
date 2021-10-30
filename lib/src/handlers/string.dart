part of 'handlers.dart';

DataHandler get stringHandler {
  return DataHandler<String>(_string);
}

FutureOr _string(Req req, Res res, String data) async {
  await res.send(data);
}
