import 'dart:async';

import '../app.dart';
import '../request.dart';
import '../response.dart';

///
/// Base Controller to be used in Lucifer application
///
class Controller {
  final App app;

  Controller(this.app);

  String get classname => runtimeType.toString();

  FutureOr index(Req req, Res res) {}

  FutureOr view(Req req, Res res) {}

  FutureOr create(Req req, Res res) {}

  FutureOr edit(Req req, Res res) {}

  FutureOr delete(Req req, Res res) {}

  FutureOr deleteAll(Req req, Res res) {}
}
