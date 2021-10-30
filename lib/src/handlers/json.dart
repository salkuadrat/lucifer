part of 'handlers.dart';

DataHandler get jsonHandler {
  return DataHandler<Map<String, dynamic>>(_json);
}

DataHandler get jsonListHandler {
  return DataHandler<List<dynamic>>(_json);
}

FutureOr _json(Req req, Res res, data) async {
  await res.json(data);
}
