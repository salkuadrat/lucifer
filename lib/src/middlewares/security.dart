import '../request.dart';
import '../response.dart';
import '../typedef.dart';
import '../security/security.dart';

/// 
/// Middleware to handle all security.
/// 
Callback security() {
  return (Req req, Res res) {
    contentSecurityPolicy()(req, res);
    noSniffMimetype()(req, res);
    crossDomain()(req, res);
    crossOriginEmbedderPolicy()(req, res);
    crossOriginOpenerPolicy()(req, res);
    crossOriginResourcePolicy()(req, res);
    dnsPrefetchControl()(req, res);
    xDownloadOptions()(req, res);
    expectCT()(req, res);
    xFrameOptions()(req, res);
    hidePoweredBy()(req, res);
    originAgentCluster()(req, res);
    referrerPolicy()(req, res);
    strictTransportSecurity()(req, res);
    xXssProtection()(req, res);
  };
}