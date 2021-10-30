import 'package:lucifer/lucifer.dart';
import 'package:test/test.dart';

main() {
  String url = 'http://localhost:3000';

  test('Parse null string', () {
    expect(parseValue('null'), equals(null));
    expect(parseValue('Null'), equals(null));
    expect(parseValue('NUll'), equals(null));
    expect(parseValue('NULl'), equals(null));
    expect(parseValue('NULL'), equals(null));
    expect(parseValue('nulL'), equals(null));
    expect(parseValue('nuLL'), equals(null));
    expect(parseValue('nuLL'), equals(null));
  });

  test('Parse integer', () {
    expect(parseValue('0'), equals(0));
    expect(parseValue('-1'), equals(-1));
    expect(parseValue('20'), equals(20));
    expect(parseValue('30000'), equals(30000));
  });

  test('Parse double', () {
    expect(parseValue('0.5'), equals(0.5));
    expect(parseValue('-3.14'), equals(-3.14));
    expect(parseValue('20.30'), equals(20.30));
  });

  test('Parse list', () {
    expect(parseValue('[]'), equals([]));
    expect(parseValue('[1, 2, 3, 4]'), equals([1, 2, 3, 4]));
    expect(parseValue('[1, "", 3, ""]'), equals([1, '', 3, '']));
    expect(parseValue('[1, "string", 3, "s"]'), equals([1, 'string', 3, 's']));
    expect(parseValue('[1, "null", 2, "d"]'), equals([1, 'null', 2, 'd']));
    expect(
      parseValue('[{"name": "lucifer"}, {"name": "decker"}]'),
      equals([
        {'name': 'lucifer'},
        {'name': 'decker'}
      ]),
    );
  });

  test('Parse json', () {
    expect(
      parseValue('{"name": "lucifer", "age": 10000, "d": 2.5}'),
      equals({'name': 'lucifer', 'age': 10000, 'd': 2.5}),
    );

    expect(
      parseJson('{"name": "lucifer", "10000": "age"}'),
      equals({'name': 'lucifer', '10000': 'age'}),
    );
  });

  test('Parse UrlEncoded', () {
    var query =
        parseUrlEncoded(Uri.parse('$url/?hello=detective&name=lucifer').query);
    expect(query, equals({'hello': 'detective', 'name': 'lucifer'}));
    expect(query['name'], equals('lucifer'));

    var body = parseUrlEncoded(
        'hello=detective&nums%5B%5D=1&nums%5B%5D=2.0&nums%5B%5D=${3 - 1}&map.foo.bar=baz&enabled');

    expect(body['hello'], equals('detective'));
    expect(body['nums'].length, equals(3));
    expect(body['nums'][0], equals(1));
    expect(body['nums'][1], equals(2.0));
    expect(body['nums'][2], equals(2));
    expect(body['map'] is Map, equals(true));
    expect(body['map']['foo'], equals({'bar': 'baz'}));
    expect(body['enabled'], equals(true));

    expect(
      body,
      equals({
        'hello': 'detective',
        'nums': [1, 2.0, 2],
        'map': {
          'foo': {'bar': 'baz'}
        },
        'enabled': true,
      }),
    );
  });
}
