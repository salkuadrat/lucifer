import 'dart:convert';
import 'dart:io';

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

  test('it should return a string correctly', () async {
    app.get('/test', (req, res) => 'test');
    final res = await http.get(Uri.parse('$baseUrl/test'));
    expect(res.body, 'test');
  });

  test('it should return json', () async {
    app.get('/test', (req, res) => {'test': true});
    final res = await http.get(Uri.parse('$baseUrl/test'));
    expect(res.headers['content-type'], 'application/json; charset=utf-8');
    expect(res.body, '{"test":true}');
  });

  test('it should return an image', () async {
    app.get('/test', (req, res) => File('test/files/image.png'));
    final res = await http.get(Uri.parse('$baseUrl/test'));
    print(res.headers);
    expect(res.headers['content-type'], 'image/png');
  });

  test('routing should work', () async {
    app.get('/test', (req, res) => 'test_route');
    app.get('/testRoute', (req, res) => 'test_route_route');
    app.get('/a', (req, res) => 'a_route');

    expect(
      (await http.get(Uri.parse('$baseUrl/test'))).body,
      'test_route',
    );
    expect(
      (await http.get(Uri.parse('$baseUrl/testRoute'))).body,
      'test_route_route',
    );
    expect(
      (await http.get(Uri.parse('$baseUrl/a'))).body,
      'a_route',
    );
  });

  test('error default handling', () async {
    app.get('/throwserror', (req, res) => throw Exception('generic exception'));
    final res = await http.get(Uri.parse('$baseUrl/throwserror'));
    expect(res.body, 'Exception: generic exception');
  });

  test('not found default handling', () async {
    final res = await http.get(Uri.parse('$baseUrl/notfound'));
    expect(res.body, '404 ${getStatusMessage(404)}');
    expect(res.statusCode, 404);
  });

  test('not found with middleware', () async {
    app.use(cors());
    app.get('resource2', (req, res) {});

    final r1 = await http.get(Uri.parse('$baseUrl/resource1'));
    expect(r1.body, '404 ${getStatusMessage(404)}');
    expect(r1.statusCode, 404);

    final r2 = await http.get(Uri.parse('$baseUrl/resource2'));
    expect(r2.body, '');
    expect(r2.statusCode, 200);
  });

  test('not found with directory type handler', () async {
    app.get('/files', (req, res) => Directory('test/files'));
    final res = await http.get(Uri.parse('$baseUrl/files/no-file.zip'));
    expect(res.body, '404 ${getStatusMessage(404)}');
    expect(res.statusCode, 404);
  });

  /* test('not found with file type handler', () async {
    app.onNotFound = (req, res) {
      res.statusCode = HttpStatus.notFound;
      return 'Custom404Message';
    };
    app.get('/index.html', (req, res) => File('does-not.exists'));

    final res = await http.get(Uri.parse('http://localhost:$port/index.html'));
    expect(res.body, 'Custom404Message');
    expect(res.statusCode, 404);
  }); */

  test('it handles a post request', () async {
    app.post('/test', (req, res) => 'test string');
    final res = await http.post(Uri.parse('$baseUrl/test'));
    expect(res.body, 'test string');
  });

  test('it handles a put request', () async {
    app.put('/test', (req, res) => 'test string');
    final res = await http.put(Uri.parse('$baseUrl/test'));
    expect(res.body, 'test string');
  });

  test('it handles a delete request', () async {
    app.delete('/test', (req, res) => 'test string');
    final res = await http.delete(Uri.parse('$baseUrl/test'));
    expect(res.body, 'test string');
  });

  /* test('it handles an options request', () async {
    app.options('/test', (req, res) => 'test string');
    final res = await http.head(Uri.parse("$baseUrl/test"));
    expect(res.body, "test string");
  }); */

  test('it handles a HEAD request', () async {
    app.head('/test', (req, res) => 'test string');
    final res = await http.head(Uri.parse('$baseUrl/test'));
    expect(res.body.isEmpty, true);
  });

  test('it handles a patch request', () async {
    app.patch('/test', (req, res) => 'test string');
    final res = await http.patch(Uri.parse('$baseUrl/test'));
    expect(res.body, 'test string');
  });

  test('it handles a route with method all', () async {
    app.all('/test', (req, res) => 'test all');

    final resGet = await http.get(Uri.parse('$baseUrl/test'));
    final resPost = await http.post(Uri.parse('$baseUrl/test'));
    final resPut = await http.put(Uri.parse('$baseUrl/test'));
    final reDelete = await http.delete(Uri.parse('$baseUrl/test'));

    expect(resGet.body, 'test all');
    expect(resPost.body, 'test all');
    expect(resPut.body, 'test all');
    expect(reDelete.body, 'test all');
  });

  test('it executes middleware, but passes through', () async {
    var hitMiddleware = false;
    app.get(
      '/test',
      (req, res) {
        hitMiddleware = true;
      },
      (req, res) => 'test route',
    );

    final res = await http.get(Uri.parse('$baseUrl/test'));
    expect(res.body, 'test route');
    expect(hitMiddleware, true);
  });

  test('it executes middleware, but handles it and stops executing', () async {
    app.get(
      '/test',
      (req, res) {
        res.send('hit middleware');
      },
      (req, res) => 'test route',
    );

    final res = await http.get(Uri.parse('$baseUrl/test'));
    expect(res.body, 'hit middleware');
  });

  test('it closes out a request if you fail to', () async {
    app.get('/test', (req, res) => null);
    final res = await http.get(Uri.parse('$baseUrl/test'));
    expect(res.body, '');
  });

  test('it throws and handles an exception', () async {
    app.get(
      '/test',
      (req, res) => throw HttpServerException(
        360,
        message: 'exception',
      ),
    );
    final res = await http.get(Uri.parse('$baseUrl/test'));
    expect(res.body, 'exception');
    expect(res.statusCode, 360);
  });

  test('it handles a List<int>', () async {
    app.get('/test', (req, res) => <int>[1, 2, 3, 4, 5]);
    final res = await http.get(Uri.parse('$baseUrl/test'));
    expect(res.body, '\x01\x02\x03\x04\x05');
    expect(res.headers['content-type'], 'application/octet-stream');
  });

  test('it handles a Stream<List<int>>', () async {
    app.get(
      '/test',
      (req, res) => Stream.fromIterable([
        [1, 2, 3, 4, 5]
      ]),
    );

    final res = await http.get(Uri.parse('$baseUrl/test'));
    expect(res.body, '\x01\x02\x03\x04\x05');
    expect(res.headers['content-type'], 'application/octet-stream');
  });

  test('it parses a body', () async {
    app.use(json());

    app.post('/test', (req, res) async {
      final body = await req.body;
      expect(body is Map, true);
      expect(req.contentType!.mimeType, 'application/json');
      return 'test result';
    });

    final res = await http.post(
      Uri.parse('$baseUrl/test'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'test': true}),
    );

    expect(res.body, 'test result');
  });

  test('it serves a file for download', () async {
    app.get('/test', (req, res) async {
      await res.download('test/files/image.png', 'testfile.jpg');
    });

    final res = await http.get(Uri.parse('$baseUrl/test'));
    print(res.headers);
    expect(res.headers['content-type'], 'image/png');
    expect(
      res.headers['content-disposition'],
      'attachment; filename=testfile.jpg',
    );
  });

  test('it serves a pdf, setting the extension from the filename', () async {
    app.get('/test', (Req req, Res res) async {
      res.setContentTypeFromExtension('pdf');
      await res.download(File('./test/files/pdf.pdf'));
    });

    final res = await http.get(Uri.parse('$baseUrl/test'));
    print(res.headers);
    expect(res.headers['content-type'], 'application/pdf');
    expect(res.headers['content-disposition'], null);
  });

  test('it uses the json helper correctly', () async {
    app.get('/test', (req, res) async {
      await res.json({'success': true});
    });

    final res = await http.get(Uri.parse('$baseUrl/test'));
    expect(res.body, '{"success":true}');
  });

  test('it uses the send helper correctly', () async {
    app.get('/test', (req, res) async {
      await res.send('stuff');
    });

    final res = await http.get(Uri.parse('$baseUrl/test'));
    expect(res.body, 'stuff');
  });

  /* test('it serves static files', () async {
    app.get('/files', (req, res) => Directory('test/files'));

    final res = await http.get(Uri.parse('$baseUrl/files/pdf.pdf'));
    expect(res.statusCode, 200);
    expect(res.headers['content-type'], 'application/pdf');
  });

  test('it serves static files with a trailing slash', () async {
    app.get('/files', (req, res) => Directory('test/files/'));

    final res = await http.get(Uri.parse('$baseUrl/files/pdf.pdf'));
    expect(res.statusCode, 200);
    expect(res.headers['content-type'], 'application/pdf');
  });

  test('it serves static files although directories do not match', () async {
    app.get('/my/directory', (req, res) => Directory('test/files'));

    final res =
        await http.get(Uri.parse('$baseUrl/my/directory/dummy.pdf'));
    expect(res.statusCode, 200);
    expect(res.headers['content-type'], 'application/pdf');
  }); */

  /* test('it cant exit the directory', () async {
    app.get('/my/directory', (req, res) => Directory('test/files'));

    final res = await http.get(Uri.parse('$baseUrl/my/directory/../test.dart'));
    expect(res.statusCode, 404);
  }); */

  /* test('it serves static files with basic filtering', () async {
    app.get('/my/directory/*.pdf', (req, res) => Directory('test/files'));

    final r1 = await http.get(Uri.parse('$baseUrl/my/directory/pdf.pdf'));
    expect(r1.statusCode, 200);
    expect(r1.headers['content-type'], 'application/pdf');

    final r2 = await http.get(Uri.parse('$baseUrl/my/directory/image.jpg'));
    expect(r2.statusCode, 404);
  }); */*/

  /* test('it sets the mime type correctly for txt', () async {
    app.get('/spa', (req, res) => Directory('test/files/spa'));
    app.get('/spa', (req, res) => File('test/files/spa/index.html'));

    final r4 = await http.get(Uri.parse('$baseUrl/spa/assets/some.txt'));
    expect(r4.statusCode, 200);
    expect(r4.body.contains('This is some txt'), true);
    expect(r4.headers['content-type'], 'text/plain');
  }); */

  test('it routes correctly for a / url', () async {
    app.get('/', (req, res) => 'working');
    final res = await http.get(Uri.parse('$baseUrl/'));
    expect(res.body, 'working');
  });

  test('it handles params', () async {
    app.get('/test/:id', (req, res) => req.params['id']);
    final res = await http.get(Uri.parse('$baseUrl/test/15'));
    expect(res.body, '15');
  });

  test('it should implement cors correctly', () async {
    app.use(cors(origin: 'test-origin'));

    final res = await http.get(Uri.parse('$baseUrl/test'));
    expect(res.headers.containsKey('access-control-allow-origin'), true);
    expect(res.headers['access-control-allow-origin'], 'test-origin');
    expect(res.headers.containsKey('access-control-allow-headers'), true);
    expect(res.headers.containsKey('access-control-allow-methods'), true);
  });

  test("it should throw an appropriate error when a return type isn't found",
      () async {
    app.use(logger());
    app.get('/test', (req, res) => Unknown());

    final res = await http.get(Uri.parse('$baseUrl/test'));
    expect(res.statusCode, 500);
    expect(res.body.contains('Unknown'), true);
  });

  test('it prints the routes without error', () {
    app.get('/test', (req, res) => 'response');
    app.post('/test', (req, res) => 'response');
    app.put('/test', (req, res) => 'response');
    app.delete('/test', (req, res) => 'response');
    app.options('/test', (req, res) => 'response');
    app.all('/test', (req, res) => 'response');
    app.head('/test', (req, res) => 'response');
    app.checkRoutes();
  });
}

class Unknown {}
