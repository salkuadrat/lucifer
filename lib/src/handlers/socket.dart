part of 'handlers.dart';

DataHandler get socketHandler {
  return DataHandler<SocketServer>(_socket);
}

FutureOr _socket(Req req, Res res, SocketServer socket) async {
  await socket.listen();
}
