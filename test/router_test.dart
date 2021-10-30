import 'package:lucifer/lucifer.dart';
import 'package:test/test.dart';

Callback get _callback => (req, res) {};

void main() {
  late App app;

  setUp(() async {
    app = App();
    await app.listen(3000);
  });

  tearDown(() => app.close());

  test('it can compose requests', () async {
    var path = app.router();

    path.get('a', _callback);
    path.post('b', _callback);
    path.put('c', _callback);
    path.patch('d', _callback);
    path.delete('e', _callback);
    path.options('f', _callback);
    path.all('g', _callback);

    app.use('/path', path);

    expect(app.routes.map((r) => '${r.path}:${r.method}').toList(), [
      '/path/a:Method.get',
      '/path/b:Method.post',
      '/path/c:Method.put',
      '/path/d:Method.patch',
      '/path/e:Method.delete',
      '/path/f:Method.options',
      '/path/g:Method.all',
    ]);
  });
}