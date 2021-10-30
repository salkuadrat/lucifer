import 'dart:async';
import 'dart:isolate';

import 'package:lucifer/lucifer.dart';

void main() async {
  // Start the default app
  await startApp();

  // Spawn 10 new app in isolates
  for (int i = 0; i < 10; i++) {
    Isolate.spawn(spawnApp, null);
  }
}

void spawnApp(data) async {
  await startApp();
}

Future<App> startApp() async {
  final app = App();
  final port = 3000;

  app.get('/', (Req req, Res res) async {
    await res.send('Hello Detective');
  });

  // define the details of your routes here

  await app.listen(port);
  print('Server running at http://${app.host}:${app.port}');

  return app;
}
