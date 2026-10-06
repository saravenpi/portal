import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;

class MetadataResult {
  final String? title;
  final String? description;
  final String? faviconUrl;

  const MetadataResult({
    this.title,
    this.description,
    this.faviconUrl,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! MetadataResult) return false;
    return title == other.title &&
        description == other.description &&
        faviconUrl == other.faviconUrl;
  }

  @override
  int get hashCode => Object.hash(title, description, faviconUrl);

  @override
  String toString() {
    return 'MetadataResult(title: $title, description: $description, faviconUrl: $faviconUrl)';
  }
}

class MetadataFetcher {
  final http.Client? client;

  const MetadataFetcher({this.client});

  Future<MetadataResult> fetchMetadata(
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
        return const MetadataResult();
      }

      final http.Response response = await httpClient
          .get(
            uri,
            headers: const <String, String>{
              'User-Agent': 'Mozilla/5.0 (compatible; Portal/1.0)',
            },
          )
          .timeout(timeout);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return const MetadataResult();
      }

      final Document document = html_parser.parse(response.body);

      final String? ogTitle = _getMetaProperty(document, 'og:title');
      final String? tagTitle = document.querySelector('title')?.text.trim();
      final String? title = (ogTitle != null && ogTitle.isNotEmpty)
          ? ogTitle
          : (tagTitle != null && tagTitle.isNotEmpty ? tagTitle : null);

      final String? ogDesc = _getMetaProperty(document, 'og:description');
      final String? metaDesc = _getMetaName(document, 'description');
      final String? description = (ogDesc != null && ogDesc.isNotEmpty)
          ? ogDesc
          : (metaDesc != null && metaDesc.isNotEmpty ? metaDesc : null);

      final String? iconHref = _getFaviconHref(document);
      final String faviconUrl = iconHref != null
          ? _resolveUrl(uri, iconHref)
          : _resolveUrl(uri, '/favicon.ico');

      return MetadataResult(
        title: title,
        description: description,
        faviconUrl: faviconUrl,
      );
    } catch (_) {
      return const MetadataResult();
    } finally {
      if (shouldClose) {
        httpClient.close();
      }
    }
  }

  String? _getMetaProperty(Document document, String property) {
    final Element? meta = document.querySelector('meta[property="$property"]');
    final String? content = meta?.attributes['content'];
    return content != null && content.trim().isNotEmpty ? content.trim() : null;
  }

  String? _getMetaName(Document document, String name) {
    final Element? meta = document.querySelector('meta[name="$name"]');
    final String? content = meta?.attributes['content'];
    return content != null && content.trim().isNotEmpty ? content.trim() : null;
  }

  String? _getFaviconHref(Document document) {
    const List<String> selectors = <String>[
      'link[rel~="icon"]',
      'link[rel="shortcut icon"]',
      'link[rel="apple-touch-icon"]',
    ];
    for (final String selector in selectors) {
      final Element? el = document.querySelector(selector);
      final String? href = el?.attributes['href'];
      if (href != null && href.trim().isNotEmpty) {
        return href.trim();
      }
    }
    return null;
  }

  String _resolveUrl(Uri baseUri, String pathOrUrl) {
    final Uri? parsed = Uri.tryParse(pathOrUrl);
    if (parsed == null) {
      return pathOrUrl;
    }
    if (parsed.hasScheme) {
      return parsed.toString();
    }
    return baseUri.resolveUri(parsed).toString();
  }
}
