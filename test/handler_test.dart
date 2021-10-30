import 'package:http/http.dart' as http;
import 'package:lucifer/lucifer.dart';
import 'package:test/test.dart';

void main() {
  late App app;
  late int port;
  late String baseUrl;

  setUp(() async {
    app = App();
    port = 3000;
    app.use(logger());
    await app.listen(port);
    baseUrl = 'http://${app.host}:${app.port}';
  });

  tearDown(() => app.close());

  test('it uses the serializable helper correctly', () async {
    app.get('/test1', (req, res) async {
      return _Serializable();
    });

    app.get('/test2', (req, res) async {
      return _Serializable();

    });
    app.get('/not', (req, res) async {
      return _NotSerializable();
    });

    final r1 = await http.get(Uri.parse('$baseUrl/test1'));
    expect(r1.body, '{"test":true}');

    final r2 = await http.get(Uri.parse('$baseUrl/test2'));
    expect(r2.body, '{"test":true}');

    final r3 = await http.get(Uri.parse('$baseUrl/not'));
    expect(r3.statusCode, 500);
    expect(r3.body.contains('_NotSerializable'), true);
  });
}

class _Serializable {
  Map<String, dynamic> toJson() {
    return <String, dynamic>{'test': true};
  }
}

class _NotSerializable {}
