import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:mime/mime.dart';

import '../multipart.dart';
import '../request.dart';
import '../uploaded_file.dart';
import 'parse_json.dart';
import 'parse_urlencoded.dart';

class RequestBody {
  Map<String, dynamic> body = {};
  List<UploadedFile> files = [];
  Map<String, dynamic> query = {};
  dynamic error;
  StackTrace? stack;
}

///
/// parse raw body of a HttpRequest into `RequestBody` data
///
Future<RequestBody> parseBody(HttpRequest request) async {
  RequestBody result = RequestBody();

  try {
    final contentType = request.contentType;

    if (contentType != null) {
      bool isTypeMultipart = contentType.primaryType == 'multipart';
      bool hasBoundary = contentType.parameters.containsKey('boundary');
      bool isMultipart = isTypeMultipart && hasBoundary;

      bool isJson = contentType.mimeType == 'application/json';
      bool isUrlencoded =
          contentType.mimeType == 'application/x-www-form-urlencoded';

      if (isMultipart) {
        final stream = request;
        final boundary = contentType.parameters['boundary'] as String;
        final parts = MimeMultipartTransformer(boundary).bind(stream).map(
              (part) => HttpMultipartFormData.parse(
                part,
                defaultEncoding: utf8,
              ),
            );

        await for (HttpMultipartFormData part in parts) {
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

            result.files.add(UploadedFile(
              name: name,
              filename: filename!,
              type: mimeType,
              data: data,
            ));
          } else if (part.isText) {
            final name = part.contentDisposition.parameters["name"];
            final values = await part.join();
            final body = parseUrlEncoded('$name=$values');
            result.body.addAll(body);
          }
        }
      } else if (isJson) {
        final body = await request.body;
        result.body = parseJson(body);
      } else if (isUrlencoded) {
        final body = await request.body;
        result.body = parseUrlEncoded(body);
      }
    } else {
      if (request.uri.hasQuery) {
        result.query = parseUrlEncoded(request.uri.query);
      }
    }
  } catch (e, s) {
    result.error = e;
    result.stack = s;
  }

  return result;
}
