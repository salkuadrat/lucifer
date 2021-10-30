part of 'request.dart';

extension HttpRequestExtension on HttpRequest {
  ///
  /// Get the body request as raw bytes.
  ///
  Future<Uint8List> get bytes async {
    final builder = await fold<BytesBuilder>(
      BytesBuilder(copy: false),
      (a, b) => a..add(b),
    );
    return builder.takeBytes();
  }

  ///
  /// Get the body request as text string data.
  ///
  Future<String> get body async {
    return utf8.decode(await bytes, allowMalformed: false);
  }

  ///
  /// Get multipart data of this request
  ///
  Future<Stream<HttpMultipartFormData>?> get multiparts async {
    if (contentType != null) {
      Stream<Uint8List> stream = this;
      final boundary = contentType!.parameters['boundary'] as String;
      // transform stream into multipart form data
      return MimeMultipartTransformer(boundary).bind(stream).map((part) {
        return HttpMultipartFormData.parse(part, defaultEncoding: utf8);
      });
    }
    return null;
  }

  ///
  /// Return contentType
  ///
  ContentType? get contentType {
    return headers.contentType;
  }
}
