import 'dart:io';

import 'package:lucifer/lucifer.dart';
import 'package:test/test.dart';

main() {
  late App app;
  late int port;
  late String baseUrl;

  setUp(() async {
    app = App();
    port = 3000;
    await app.listen(port);
    baseUrl = 'ws://${app.host}:${app.port}';
  });

  tearDown(() => app.close());

  test('it can handle web sockets', () async {
    bool isOpened = false;
    bool isClosed = false;

    String? message;

    app.get('/', (Req req, Res res) async {
      final socket = app.socket(req, res);
      socket.on('open', (_) => isOpened = true);
      socket.on('close', (_) => isClosed = true);
      socket.on('message', (WebSocket client, data) {
        message = data as String;
        client.send('hello $message');
      });
      await socket.listen();
    });

    WebSocket client = await WebSocket.connect(baseUrl);
    client.add('detective');

    String response = (await client.first) as String;

    expect(isOpened, true);
    expect(isClosed, false);
    expect(message, 'detective');
    expect(response, 'hello detective');

    await client.close();
    await Future.delayed(Duration(milliseconds: 100));

    expect(isClosed, true);
  });
}
