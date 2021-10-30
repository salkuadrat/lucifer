import 'dart:io';

import 'package:lucifer/lucifer.dart';

void main() async {
  final app = App();
  final port = env('PORT') ?? 3000;

  app.use(static('public'));

  app.get('/', (Req req, Res res) async {
    await res.sendFile('chat.html');
  });

  app.get('/ws', (Req req, Res res) async {
    List clients = [];

    final socket = app.socket(req, res);

    socket.on('open', (WebSocket client) {
      clients.add(client);
      for (var c in clients) {
        if (c != client) {
          c.send('New human has joined the chat');
        }
      }
    });
    socket.on('message', (WebSocket client, message) {
      for (var c in clients) {
        if (c != client) {
          c.send(message);
        }
      }
    });
    socket.on('close', (WebSocket client) {
      clients.remove(client);

      for (var c in clients) {
        c.send('A human just left the chat');
      }
    });
    socket.on('error', (WebSocket client, error) {
      res.log.e('$error');
    });

    await socket.listen();
  });

  await app.listen(port);
  print('Server running at http://${app.host}:${app.port}');
}
