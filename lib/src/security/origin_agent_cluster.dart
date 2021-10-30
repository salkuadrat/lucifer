import '../request.dart';
import '../response.dart';
import '../typedef.dart';

///
/// Origin-Agent-Cluster is a new HTTP response header that instructs
/// the browser to prevent synchronous scripting access between same-site
/// cross-origin pages.
///
/// Browsers may also use Origin-Agent-Cluster as a hint that your origin
/// should get its own, separate resources, such as a dedicated process.
///
Callback originAgentCluster() {
  return (Req req, Res res) {
    res.set('Origin-Agent-Cluster', '?1');
  };
}
