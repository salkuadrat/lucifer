import '../request.dart';
import '../response.dart';
import '../typedef.dart';

/// 
/// Some browsers will try to "sniff" mimetypes. For example, if my server 
/// serves file.txt with a text/plain content-type, some browsers can still 
/// run that file with <script src="file.txt"></script>. 
/// 
/// Many browsers will allow file.js to be run even if the content-type 
/// isn't for JavaScript.
/// 
/// Browsers' same-origin policies generally prevent remote resources from 
/// being loaded dangerously, but vulnerabilities in web browsers can cause 
/// this to be abused. 
/// 
/// Some browsers, like Chrome, will further isolate memory if 
/// the X-Content-Type-Options header is seen.
/// 
Callback noSniffMimetype() {
  return (Req req, Res res) {
    res.set('X-Content-Type-Options', 'nosniff');
  };
}