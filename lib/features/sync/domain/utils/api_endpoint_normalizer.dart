String normalizeApiEndpoint({
  required String endpoint,
  required String baseUrl,
}) {
  final normalized = endpoint.startsWith('/') ? endpoint : '/$endpoint';
  final basePath = Uri.tryParse(baseUrl)?.path ?? '';

  if (basePath.endsWith('/api') && normalized.startsWith('/api/')) {
    return normalized.substring(4);
  }

  return normalized;
}
