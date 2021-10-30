import 'dart:async';
import 'dart:io';

import 'request.dart';
import 'response.dart';

class SocketServer {
  final Req req;

  final Res res;

  SocketServer(this.req, this.res);

  SocketOpenCallback? _onOpen;
  SocketCloseCallback? _onClose;
  SocketErrorCallback? _onError;
  SocketMessageCallback? _onMessage;

  SocketServer on(String event, Function listener) {
    if (event == 'open' && listener is SocketOpenCallback) {
      _onOpen = listener;
    } else if (event == 'close' && listener is SocketCloseCallback) {
      _onClose = listener;
    } else if (event == 'error' && listener is SocketErrorCallback) {
      _onError = listener;
    } else if (event == 'message' && listener is SocketMessageCallback) {
      _onMessage = listener;
    }
    return this;
  }

  Future<void> listen() async {
    res.closed = true;
    WebSocket socket = await req.socket;

    _onOpen?.call(socket);

    try {
      socket.listen((data) {
        try {
          _onMessage?.call(socket, data);
        } catch (e) {
          _onError?.call(socket, e);
        }
      }, onError: (error) {
        _onError?.call(socket, error);
      }, onDone: () {
        _onClose?.call(socket);
      });
    } catch (e) {
      print('Error $e');
      _onError?.call(socket, e);
      await socket.close();
    }
  }
}

extension WebSocketExtension on WebSocket {
  void send(data) {
    add(data);
  }
}

typedef SocketOpenCallback = FutureOr Function(WebSocket socket);

typedef SocketCloseCallback = FutureOr Function(WebSocket socket);

typedef SocketErrorCallback = FutureOr Function(
  WebSocket socket,
  dynamic error,
);

typedef SocketMessageCallback = FutureOr Function(
  WebSocket socket,
  dynamic data,
);
