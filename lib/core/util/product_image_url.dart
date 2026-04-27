/// Normalizes product image URLs from APIs. Some third-party CDNs block
/// hotlinked app requests (403), which spams errors and shows broken images.
String? sanitizeProductImageUrl(String? raw) {
  if (raw == null) return null;
  final s = raw.trim();
  if (s.isEmpty) return null;
  final uri = Uri.tryParse(s);
  if (uri == null || !uri.hasScheme) return s;
  if (uri.scheme != 'http' && uri.scheme != 'https') return s;
  final host = uri.host.toLowerCase();
  if (host == 'cdn.grofers.com' || host.endsWith('.grofers.com')) {
    return null;
  }
  return s;
}
