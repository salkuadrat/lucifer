import 'package:logger/logger.dart';

import '../log.dart';
import '../request.dart';
import '../response.dart';
import '../typedef.dart';

///
/// Middleware to handle logging with package `logger`
/// https://pub.dev/packages/logger
///
/// Feel free to create a custom logging middleware
/// with other logging method.
///
Callback logger({
  Level level = Level.verbose,
  LogPrinter? printer,
}) {
  Logger.level = level;
  Logger logger = Logger(
    filter: ProductionFilter(),
    printer: printer ?? SimplePrinter(printTime: true),
  );
  return (Req req, Res res) async {
    Log log = Log();
    log.v = logger.v;
    log.d = logger.d;
    log.i = logger.i;
    log.w = logger.w;
    log.e = logger.e;
    req.log = res.log = log;
  };
}
