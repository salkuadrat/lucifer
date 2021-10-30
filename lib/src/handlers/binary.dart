part of 'handlers.dart';

DataHandler get listIntHandler {
  return DataHandler<List<int>>(_binary);
}

DataHandler get uint8ListHandler {
  return DataHandler<Uint8List>(_binary);
}

DataHandler get binaryStreamHandler {
  return DataHandler<Stream<List<int>>>(_stream);
}

FutureOr _binary(Req req, Res res, dynamic data) async {
  if (res.contentType == null || res.isContentText) {
    res.setContentType(ContentType.binary);
  }
  res.add(data);
  await res.close();
}

FutureOr _stream(Req req, Res res, Stream<List<int>> data) async {
  if (res.contentType == null || res.isContentText) {
    res.setContentType(ContentType.binary);
  }
  await res.addStream(data);
  await res.close();
}
