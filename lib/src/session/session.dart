import 'dart:async';
import 'dart:io';

import '../request.dart';

class Session {
  final Req req;
  final String id;

  Session(this.req, this.id);

  Cookie? cookie;

  bool get hasCookie => cookie != null;

  void touch() {

  }

  void resetMaxAge() {

  }

  void save() {
    // req.sessionStore?.set(id, this);
  }

  FutureOr reload() async {
    /* Session? session = req.sessionStore?.get(id);

    if (session != null) {

    } */
  }

  void destroy() {
    // req.sessionStore?.destroy(id);
  }

  void regenerate() async {
    // req.sessionStore?.regenerate(req);
  }
}