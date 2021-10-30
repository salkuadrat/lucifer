part of 'handlers.dart';

DataHandler get numericHandler {
  return DataHandler<num>(_numeric);
}

FutureOr _numeric(Req req, Res res, num data) async {
  await res.send(data.toString());
}
