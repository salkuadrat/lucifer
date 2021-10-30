part of 'handlers.dart';

DataHandler get fileHandler {
  return DataHandler<File>(_file);
}

FutureOr _file(Req req, Res res, File file) async {
  await res.download(file);
}
