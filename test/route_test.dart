import 'package:lucifer/lucifer.dart';
import 'package:test/test.dart';

import 'package:http/http.dart' as http;

void main() {
  late App app;
  late int port;
  late String baseUrl;

  setUp(() async {
    app = App();
    port = 3000;
    await app.listen(port);
    baseUrl = 'http://${app.host}:${app.port}';
  });

  tearDown(() => app.close());

  test('it should redirect', () async {
    app.get('/', (req, res) => res.send('Home'));

    final res = await http.get(Uri.parse('$baseUrl/'));
    // expect(res.headers['content-type'], 'image/png');
  });
}