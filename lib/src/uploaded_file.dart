/// Uploaded File Data
class UploadedFile {
  /// The MIME type of the file
  final String type;

  /// Name of the file field from the request
  final String name;

  /// Filename
  final String filename;

  /// The bytes file data
  final List<int> data;

  UploadedFile({
    required this.type,
    required this.name,
    required this.filename,
    required this.data,
  });
}