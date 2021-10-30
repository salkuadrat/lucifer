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

  test('it should return image', () async {
    app.use(static('test/files'));
    app.get('/', (req, res) => res.send('Test'));

    final res = await http.get(Uri.parse('$baseUrl/image.png'));
    print(res.headers);
    expect(res.headers['content-type'], 'image/png');
  });

  test('it should serve static', () async {
    app.use(static('test'));
    app.get('/', (req, res) => res.send('Test'));

    final res = await http.get(Uri.parse('$baseUrl/files/image.png'));
    print(res.headers);
    expect(res.headers['content-type'], 'image/png');
  });
}
