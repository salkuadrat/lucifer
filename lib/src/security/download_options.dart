import '../request.dart';
import '../response.dart';
import '../typedef.dart';

///
/// This middleware sets the X-Download-Options header to noopen to
/// prevent Internet Explorer users from executing downloads
/// in your site's context.
///
/// Some web applications will serve untrusted HTML for download.
///
/// By default, some versions of IE will allow you to open those HTML files
/// in the context of your site, which means that an untrusted HTML page
/// could start doing bad things in the context of your pages.
///
Callback xDownloadOptions() {
  return (Req req, Res res) {
    res.set('X-Download-Options', 'noopen');
  };
}
