import 'dart:io';

import '../uploaded_file.dart';
import '../multipart.dart';
import '../request.dart';
import 'parse_urlencoded.dart';

///
/// Parse multipart request into map body and uploaded files
///
Future parseMultipart(
  Req req, {
  void Function(String name, Object field)? onFieldListener,
  void Function(String name, UploadedFile file)? onFileListener,
  void Function(dynamic error)? onErrorListener,
  void Function()? onEndListener,
}) async {
  var multiparts = await req.request.multiparts;
  
  Map<String, dynamic> body = {};
  List<UploadedFile> files = [];

  if (multiparts != null) {
    try {
      await for (HttpMultipartFormData part in multiparts) {
        final parameters = part.contentDisposition.parameters;
        final name = parameters['name'] ?? 'file';
        final filename = parameters['filename'];

        if (part.isBinary || filename != null) {
          // combine each bytes in part data
          final builder = await part.fold(
            BytesBuilder(copy: false),
            (BytesBuilder bytes, data) {
              if (data is String) {
                return bytes..add((data).codeUnits);
              } else {
                return bytes..add(data as List<int>);
              }
            },
          );

          final data = builder.takeBytes();
          final mimeType = part.contentType!.mimeType;

          files.add(UploadedFile(
            name: name,
            filename: filename!,
            type: mimeType,
            data: data,
          ));
        } else if (part.isText) {
          // call sanitizeHtml for xss clean
          final value = await part.join();
          final name = part.contentDisposition.parameters["name"];

          if (name != null) {
            body.addAll(parseUrlEncoded('$name=$value'));
            onFieldListener?.call(name, body[name]);
          }
        }
      }
    } catch (e) {
      onErrorListener?.call(e);
      return e;
    } finally {
      onEndListener?.call();
    }
  }

  return [body, files];
}


