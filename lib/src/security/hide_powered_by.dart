import '../request.dart';
import '../response.dart';
import '../typedef.dart';

/// 
/// Simple middleware to remove the X-Powered-By HTTP header if it's set.
/// 
Callback hidePoweredBy() {
  return (Req req, Res res) {
    res.remove('X-Powered-By');
  };
}