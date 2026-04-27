/// Normalizes configured API origin by trimming trailing slash and trailing
/// `/api` segments so endpoint paths can consistently start with `/api/api/...`.
String normalizeApiOriginForDio(String rawBaseUrl) {
  var s = rawBaseUrl.trim();
  if (s.isEmpty) return s;
  while (s.endsWith('/')) {
    s = s.substring(0, s.length - 1);
  }
  while (s.toLowerCase().endsWith('/api')) {
    s = s.substring(0, s.length - 4);
    while (s.endsWith('/')) {
      s = s.substring(0, s.length - 1);
    }
  }
  return s;
}
