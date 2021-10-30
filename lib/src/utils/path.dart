///
/// Clean route path before being used to build Regexp matcher
///
String cleanPath(String path) {
  path = path.trim();

  if (path.startsWith('/')) {
    return cleanPath(path.substring(1));
  }

  if (path.trim().endsWith('/')) {
    return cleanPath(path.substring(0, path.length - 1));
  }

  return path;
}

String combinePath(String basePath, String path) {
  basePath = cleanPath(basePath);
  path = cleanPath(path);

  return basePath.isEmpty
      ? '/$path'
      : path.isEmpty
          ? '/$basePath'
          : '/$basePath/$path';
}
