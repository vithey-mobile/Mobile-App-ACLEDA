import 'package:flutter_test/flutter_test.dart';
import 'package:aub_connect_app/core/utils/media_url_resolver.dart';

void main() {
  group('MediaUrlResolver', () {
    test('handles null, empty, and whitespace strings gracefully', () {
      expect(MediaUrlResolver.resolve(null).isEmpty, isTrue);
      expect(MediaUrlResolver.resolve('').isEmpty, isTrue);
      expect(MediaUrlResolver.resolve('   ').isEmpty, isTrue);
      expect(MediaUrlResolver.resolveUrl(null), isNull);
      expect(MediaUrlResolver.resolveUrl(''), isNull);
    });

    test('preserves asset paths as assets', () {
      final res = MediaUrlResolver.resolve('assets/images/placeholder.png');
      expect(res.isAsset, isTrue);
      expect(res.isLocalFile, isFalse);
      expect(res.url, 'assets/images/placeholder.png');
    });

    test('normalizes file:// URIs to local filesystem paths', () {
      final res =
          MediaUrlResolver.resolve('file:///data/user/0/cache/picker_123.jpg');
      expect(res.isLocalFile, isTrue);
      expect(res.isAsset, isFalse);
      expect(res.url.startsWith('file://'), isFalse);
      expect(res.url, contains('picker_123.jpg'));
    });

    test('treats raw local filesystem paths as local files', () {
      final res =
          MediaUrlResolver.resolve('/data/user/0/app/cache/photo.jpg');
      expect(res.isLocalFile, isTrue);
      expect(res.url, '/data/user/0/app/cache/photo.jpg');
    });

    test('preserves public external internet URLs untouched', () {
      const publicUrl = 'https://picsum.photos/seed/poster1/600/420';
      final res = MediaUrlResolver.resolve(publicUrl);
      expect(res.isNetwork, isTrue);
      expect(res.url, publicUrl);
      expect(res.headers, isNull);
    });

    test('remaps localhost:19000 MinIO URL and preserves signed Host header', () {
      const minioUrl =
          'http://localhost:19000/posters/user-1/file-1/img.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Signature=123456&X-Amz-SignedHeaders=host';
      final res = MediaUrlResolver.resolve(minioUrl);
      expect(res.isNetwork, isTrue);

      final uri = Uri.parse(res.url);
      // Host should not be localhost on Android fallback
      expect(uri.path, '/posters/user-1/file-1/img.png');
      expect(uri.port, 19000);

      // Preserves Host header for AWS SigV4
      expect(res.headers, isNotNull);
      expect(res.headers!['Host'], 'localhost:19000');
    });

    test('remaps Docker-internal minio:9000 URL to host port 19000 and preserves Host header', () {
      const dockerMinioUrl =
          'http://minio:9000/posters/user-1/file-1/img.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Signature=abcdef&X-Amz-SignedHeaders=host';
      final res = MediaUrlResolver.resolve(dockerMinioUrl);
      expect(res.isNetwork, isTrue);

      final uri = Uri.parse(res.url);
      expect(uri.path, '/posters/user-1/file-1/img.png');
      expect(uri.port, 19000);

      // Preserves original Host header for MinIO HMAC verification
      expect(res.headers, isNotNull);
      expect(res.headers!['Host'], 'minio:9000');
    });

    test('resolveUrl helper returns the resolved URL string', () {
      const publicUrl = 'https://picsum.photos/600/400';
      expect(MediaUrlResolver.resolveUrl(publicUrl), publicUrl);
    });
  });
}
