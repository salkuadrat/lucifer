import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:lucifer/lucifer.dart';
import 'package:test/test.dart';

const token = '''
  eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiIxMjcuMC4wLjEiLCJleHAiOi0xLCJpYXQiOiIyMDE2LTEyLTIyVDEyOjQ5OjUwLjM2MTQ0NiIsImlzcyI6ImFuZ2VsX2F1dGgiLCJzdWIiOiIxMDY2OTQ4Mzk2MDIwMjg5ODM2NTYifQ==.PYw7yUb-cFWD7N0sSLztP7eeRvO44nu1J2OgDNyT060=
''';

String jsonEncodeBody(RequestBody result) {
  return jsonEncode({
    'query': result.query,
    'body': result.body,
    'files': result.files.map((f) {
      return {
        'name': f.name,
        'type': f.type,
        'filename': f.filename,
        'data': f.data,
      };
    }).toList(),
    'error': result.error?.toString(),
    'stack': result.stack?.toString(), //result.stack.toString(),
  });
}

main() {
  HttpServer? server;
  String? url;
  http.Client? client;

  setUp(() async {
    server = await HttpServer.bind('127.0.0.1', 0);
    server!.listen((HttpRequest request) async {
      //Server will simply return a JSON representation of the parsed body
      request.response.write(jsonEncodeBody(await parseBody(request)));
      await request.response.close();
    });

    url = 'http://localhost:${server!.port}';
    print('Test server listening on $url');

    client = http.Client();
  });

  tearDown(() async {
    await server?.close(force: true);
    client?.close();
    server = null;
    url = null;
    client = null;
  });

  group('query string', () {
    test('GET Simple', () async {
      print('GET $url/?hello=world');

      var response = await client!.get(Uri.parse('$url/?hello=world'));
      print('Response: ${response.body}');

      var result = jsonDecode(response.body);
      expect(result['body'], equals({}));
      expect(result['query'], equals({'hello': 'world'}));
      expect(result['files'], equals([]));
    });

    test('GET Complex', () async {
      var postData =
          'hello=world&nums%5B%5D=1&nums%5B%5D=2.0&nums%5B%5D=${3 - 1}&map.foo.bar=baz';
      print('Body: $postData');
      var response = await client!.get(Uri.parse('$url/?$postData'));
      print('Response: ${response.body}');
      var query = jsonDecode(response.body)['query'];
      expect(query['hello'], equals('world'));
      expect(query['nums'][2], equals(2));
      expect(query['map'] is Map, equals(true));
      expect(query['map']['foo'], equals({'bar': 'baz'}));
    });

    test('JWT', () async {
      var postData = 'token=$token';
      print('Body: $postData');
      var response = await client!.get(Uri.parse('$url/?$postData'));
      print('Response: ${response.body}');
      var query = jsonDecode(response.body)['query'];
      expect(query['token'], equals(token));
    });
  });

  group('urlencoded', () {
    Map<String, String> headers = {
      'content-type': 'application/x-www-form-urlencoded'
    };
    test('POST Simple', () async {
      print('Body: hello=world');
      var response = await client!
          .post(Uri.parse(url!), headers: headers, body: 'hello=world');
      print('Response: ${response.body}');
      var result = jsonDecode(response.body);
      expect(result['query'], equals({}));
      expect(result['body'], equals({'hello': 'world'}));
      expect(result['files'], equals([]));
    });

    test('Post Complex', () async {
      var postData =
          'hello=world&nums%5B%5D=1&nums%5B%5D=2.0&nums%5B%5D=${3 - 1}&map.foo.bar=baz';
      var response =
          await client!.post(Uri.parse(url!), headers: headers, body: postData);
      print('Response: ${response.body}');
      var body = jsonDecode(response.body)['body'];
      expect(body['hello'], equals('world'));
      expect(body['nums'][2], equals(2));
      expect(body['map'] is Map, equals(true));
      expect(body['map']['foo'], equals({'bar': 'baz'}));
    });

    test('JWT', () async {
      var postData = 'token=$token';
      var response =
          await client!.post(Uri.parse(url!), headers: headers, body: postData);
      var body = jsonDecode(response.body)['body'];
      expect(body['token'], equals(token));
    });
  });

  group('json', () {
    Map<String, String> headers = {'content-type': 'application/json'};
    test('Post Simple', () async {
      var postData = jsonEncode({'hello': 'world'});
      print('Body: $postData');
      var response =
          await client!.post(Uri.parse(url!), headers: headers, body: postData);
      print('Response: ${response.body}');
      var result = jsonDecode(response.body);
      expect(result['body'], equals({'hello': 'world'}));
      expect(result['query'], equals({}));
      expect(result['files'], equals([]));
    });

    test('Post Complex', () async {
      var postData = jsonEncode({
        'hello': 'world',
        'nums': [1, 2.0, 3 - 1],
        'map': {
          'foo': {'bar': 'baz'}
        }
      });
      print('Body: $postData');
      var response =
          await client!.post(Uri.parse(url!), headers: headers, body: postData);
      print('Response: ${response.body}');
      var body = jsonDecode(response.body)['body'];
      expect(body['hello'], equals('world'));
      expect(body['nums'][2], equals(2));
      expect(body['map'] is Map, equals(true));
      expect(body['map']['foo'], equals({'bar': 'baz'}));
    });
  });

  test('No upload', () async {
    String boundary = 'myBoundary';
    Map<String, String> headers = {
      'content-type': 'multipart/form-data; boundary=$boundary'
    };

    String postData = '''
--$boundary
Content-Disposition: form-data; name="hello"

world
--$boundary--
'''
        .replaceAll("\n", "\r\n");

    print(
        'Form Data: \n${postData.replaceAll("\r", "\\r").replaceAll("\n", "\\n")}');

    var response = await client!.post(
      Uri.parse(url!),
      headers: headers,
      body: postData,
    );
    print('Response: ${response.body}');

    Map jsons = jsonDecode(response.body);

    var files = jsons['files'].map((map) {
      return map?.keys.fold<Map<String, dynamic>>(
        <String, dynamic>{},
        (out, k) => out..[k.toString()] = map[k],
      );
    });

    expect(files.length, equals(0));
    expect(jsons['body']['hello'], equals('world'));
  });

  test('Single upload', () async {
    String boundary = 'myBoundary';
    Map<String, String> headers = {
      'content-type': ContentType(
        "multipart",
        "form-data",
        parameters: {"boundary": boundary},
      ).toString()
    };

    String postData = '''
--$boundary
Content-Disposition: form-data; name="hello"

world
--$boundary
Content-Disposition: form-data; name="file"; filename="app.dart"
Content-Type: application/dart

Hello world
--$boundary--
'''
        .replaceAll("\n", "\r\n");

    print(
      'Form Data: \n${postData.replaceAll("\r", "\\r").replaceAll("\n", "\\n")}',
    );

    var response = await client!.post(
      Uri.parse(url!),
      headers: headers,
      body: postData,
    );

    print('Response: ${response.body}');

    Map jsons = jsonDecode(response.body);
    var files = jsons['files'];

    expect(files.length, equals(1));
    expect(files[0]['name'], equals('file'));
    expect(files[0]['type'], equals('application/dart'));
    expect(files[0]['data'].length, equals(11));
    expect(files[0]['filename'], equals('app.dart'));
    expect(jsons['body']['hello'], equals('world'));
  });

  test('Multiple upload', () async {
    String boundary = 'myBoundary';
    Map<String, String> headers = {
      'content-type': 'multipart/form-data; boundary=$boundary'
    };

    String postData = '''
--$boundary
Content-Disposition: form-data; name="json"

god
--$boundary
Content-Disposition: form-data; name="num"

14.50000
--$boundary
Content-Disposition: form-data; name="file"; filename="app.dart"
Content-Type: text/plain

Hello world
--$boundary
Content-Disposition: form-data; name="entry-point"; filename="main.js"
Content-Type: text/javascript

function main() {
  console.log("Hello, world!");
}
--$boundary--
'''
        .replaceAll("\n", "\r\n");

    print(
      'Form Data: \n${postData.replaceAll("\r", "\\r").replaceAll("\n", "\\n")}',
    );

    var response = await client!.post(
      Uri.parse(url!),
      headers: headers,
      body: postData,
    );
    print('Response: ${response.body}');

    Map jsons = jsonDecode(response.body);
    var body = jsons['body'];
    var files = jsons['files'];
    print(body);

    expect(files.length, equals(2));
    expect(files[0]['name'], equals('file'));
    expect(files[0]['type'], equals('text/plain'));
    expect(files[0]['data'].length, equals(11));
    expect(files[1]['name'], equals('entry-point'));
    expect(files[1]['filename'], equals('main.js'));
    expect(files[1]['type'], equals('text/javascript'));
    expect(body['json'], equals('god'));
    expect(body['num'], equals(14.5));
  });
}
