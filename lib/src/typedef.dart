import 'dart:async';

import 'request.dart';
import 'response.dart';

///
/// Type definition for both Middleware and Route Handler
///
typedef Callback = FutureOr Function(Req req, Res res);
