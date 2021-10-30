import 'dart:isolate';

import 'package:lucifer/lucifer.dart';
import 'package:test/test.dart';

import 'package:http/http.dart' as http;

Future<App> startApp() async {
  final app = App();
  final port = 3000;

  app.get('/', (Req req, Res res) async {
    await res.send('Hello Detective');
  });

  await app.listen(port, () {
    print('Server running at http://${app.host}:${app.port}');
  });

  return app;
}

void spawnApp(data) async {
  await startApp();
}

main() {
  late App app;
  late String baseUrl;

  setUp(() async {
    app = await startApp();
    baseUrl = 'http://${app.host}:${app.port}';

    for (int i = 0; i < 10; i++) {
      Isolate.spawn(spawnApp, null);
    }
  });

  tearDown(() => app.close());

  test('it should run parallel apps correctly', () async {
    final res = await http.get(Uri.parse(baseUrl));
    expect(res.body, 'Hello Detective');
  });
}
