import 'package:lucifer/lucifer.dart';

void main() async {
  final app = App();
  final port = 3000;

  app.use(cors(origin: '*'));

  app.get('/', (Req req, Res res) async {
    await res.send('Hello Detective');
  });

  await app.listen(port);
  print('Server running at http://${app.host}:${app.port}');
}
