import 'package:lucifer/lucifer.dart';

import 'controller/user_controller.dart';

void main() async {
  final app = App();
  final port = env('PORT') ?? 3000;

  app.use(logger());
  app.use(security());
  app.use(cors());

  // app.use(secureCookie('super-s3cr3t-key'));
  app.use(session(secret: 'super-s3cr3t-key'));
  app.use(mustache());
  app.use(xssClean());

  // testJwt();

  final auth = app.router();

  auth.get('/login', (req, res) {
    res.send('Login');
  });

  app.get('/', (Req req, Res res) async {
    await res.render('index', {
      'title': 'Hello Detective',
    });
  });

  app.get('/string', (req, res) => 'string');
  app.get('/int', (req, res) => 25);
  app.get('/double', (req, res) => 3.14);
  app.get('/json', (req, res) => {'name': 'lucifer'});
  app.get('/list', (req, res) => ['Lucifer', 'Detective']);

  app.get('/empty', (req, res) {});

  app.get('/redirect', (req, res) {
    res.redirect('/profile/lucifer');
  });

  app.get('/to', (req, res) {
    res.to('/profile/lucifer?age=999999');
  });

  app.get('/profile/:username', (Req req, Res res) async {
    await res.json({
      'username': req.param('username'),
      'age': req.q('age') ?? 10000,
    });
  });

  app.use('/auth', auth);

  final user = UserController(app);

  app.route('/user', user).get('/vip', user.vip);

  /* app.route('/user')
    .get('/', user.list)
    .get('/:id', user.view)
    .post('/', user.create)
    .put('/', user.edit)
    .delete('/', user.deleteAll)
    .delete('/:id', user.delete); */

  await app.listen(port);

  print('Server running at http://${app.host}:${app.port}');
  app.checkRoutes();
}

void testJwt() {
  /* final jwt = Jwt();
  final secret = 'secret';

  final payload = <String, dynamic>{
    'username': 'lucifer',
    'age': 10000,
  };

  final token = jwt.sign(
    payload,
    secret,
    expiresIn: Duration(seconds: 86400),
  );

  print(token);

  jwt.verify(token, secret, (error, data) {
    if (data != null) {
      print(data);
      print(data['username']);
    }

    if (error != null) {
      print(error);
    }
  });

  try {
    final data = jwt.verify(token, secret);

    if (data != null) {
      print(data['username']);
    }
  } on JWTExpiredError {
    print('JWTExpiredError');
  } on JWTError catch (e) {
    print('JWTError: ${e.message}');
  } on Exception catch (e) {
    print('Exception: $e');
  } */
}
