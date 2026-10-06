import 'package:http/http.dart' as http;
import '../models/link_item.dart';

class LinkValidator {
  final http.Client? client;

  const LinkValidator({this.client});

  Future<LinkHealth> checkHealth(
    String urlString, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final http.Client httpClient = client ?? http.Client();
    final bool shouldClose = client == null;

    try {
      final String trimmed = urlString.trim();
      final String normalizedUrl = trimmed.startsWith('www.')
          ? 'https://$trimmed'
          : (!RegExp(r'^[a-z][a-z0-9+.-]*:', caseSensitive: false).hasMatch(trimmed)
              ? 'https://$trimmed'
              : trimmed);

      final Uri? uri = Uri.tryParse(normalizedUrl);
      if (uri == null || !uri.hasScheme) {
        return LinkHealth.broken;
      }

      try {
        final http.Response headResponse = await httpClient
            .head(
              uri,
              headers: const <String, String>{
                'User-Agent': 'Mozilla/5.0 (compatible; Portal/1.0)',
              },
            )
            .timeout(timeout);

        if (headResponse.statusCode >= 200 && headResponse.statusCode < 400) {
          return LinkHealth.healthy;
        }
      } catch (_) {}

      final http.Response getResponse = await httpClient
          .get(
            uri,
            headers: const <String, String>{
              'User-Agent': 'Mozilla/5.0 (compatible; Portal/1.0)',
            },
          )
          .timeout(timeout);

      if (getResponse.statusCode >= 200 && getResponse.statusCode < 400) {
        return LinkHealth.healthy;
      }

      return LinkHealth.broken;
    } catch (_) {
      return LinkHealth.broken;
    } finally {
      if (shouldClose) {
        httpClient.close();
      }
    }
  }
}
