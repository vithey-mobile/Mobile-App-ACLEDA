import 'dart:io';

import 'package:aub_connect_app/core/config/app_config.dart';

/// Represents a media reference resolved for display on the current platform/device.
class ResolvedMedia {
  const ResolvedMedia({
    required this.url,
    this.headers,
    this.isAsset = false,
    this.isLocalFile = false,
  });

  /// The final URL or local path to load.
  final String url;

  /// HTTP headers to supply (e.g. `Host` header for AWS S3 / MinIO SigV4).
  final Map<String, String>? headers;

  /// True if [url] points to a Flutter bundle asset (`assets/...`).
  final bool isAsset;

  /// True if [url] points to a local filesystem file.
  final bool isLocalFile;

  bool get isEmpty => url.isEmpty;
  bool get isNotEmpty => url.isNotEmpty;
  bool get isNetwork => !isAsset && !isLocalFile && isNotEmpty;
}

/// Central resolver that normalizes media URLs across Android emulator, physical devices,
/// local MinIO object storage, Docker networks, and the filesystem.
class MediaUrlResolver {
  MediaUrlResolver._();

  static const _localOrDockerHosts = {
    'localhost',
    '127.0.0.1',
    '0.0.0.0',
    'minio',
    'vithey-minio',
    'superapp-minio',
  };

  /// Resolves any media URL into a [ResolvedMedia] with host remapping and HTTP headers.
  static ResolvedMedia resolve(String? rawUrl) {
    if (rawUrl == null || rawUrl.trim().isEmpty) {
      return const ResolvedMedia(url: '');
    }

    final trimmed = rawUrl.trim();

    // 1. Asset path
    if (trimmed.startsWith('assets/')) {
      return ResolvedMedia(url: trimmed, isAsset: true);
    }

    // 2. file:// URI
    if (trimmed.startsWith('file://')) {
      final path =
          Uri.tryParse(trimmed)?.toFilePath() ?? trimmed.replaceFirst('file://', '');
      return ResolvedMedia(url: path, isLocalFile: true);
    }

    // 3. Local filesystem path or relative API path
    final isNetworkUrl =
        trimmed.startsWith('http://') || trimmed.startsWith('https://');
    if (!isNetworkUrl) {
      if (trimmed.startsWith('/')) {
        // Relative API path (e.g. /api/v1/files/... or /files/...)
        final apiBase = _getApiBaseUrl();
        if (apiBase.isNotEmpty) {
          final uri = Uri.tryParse(apiBase);
          if (uri != null) {
            final origin =
                '${uri.scheme}://${uri.host}${uri.hasPort ? ':${uri.port}' : ''}';
            final full = '$origin$trimmed';
            return _resolveNetworkUrl(full);
          }
        }
      }
      return ResolvedMedia(url: trimmed, isLocalFile: true);
    }

    // 4. Network URL
    return _resolveNetworkUrl(trimmed);
  }

  /// Convenience method returning just the resolved URL string.
  static String? resolveUrl(String? rawUrl) {
    if (rawUrl == null || rawUrl.trim().isEmpty) return null;
    final resolved = resolve(rawUrl);
    return resolved.url.isNotEmpty ? resolved.url : null;
  }

  static ResolvedMedia _resolveNetworkUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null || uri.host.isEmpty) {
      return ResolvedMedia(url: url);
    }

    final originalHost = uri.host.toLowerCase();
    final originalPort = uri.hasPort ? uri.port : null;

    if (!_isLocalOrDevHost(originalHost, originalPort, uri.path)) {
      // Remote public URL (e.g. https://picsum.photos or public cloud storage)
      return ResolvedMedia(url: url);
    }

    // Target host where the phone/emulator can actually reach the host machine.
    final targetHost = _getTargetHost();
    if (targetHost.isEmpty) {
      return ResolvedMedia(url: url);
    }

    // Port mapping: MinIO default external port in Vithey compose is 19000.
    // If the URL used Docker-internal minio:9000 and targetHost is external,
    // point to 19000 on the host machine.
    int? targetPort = originalPort;
    if ((originalPort == 9000 || originalPort == 19000) &&
        (originalHost.contains('minio') || targetHost != 'minio')) {
      targetPort = 19000;
    }

    final rewrittenUri = uri.replace(
      host: targetHost,
      port: targetPort,
    );

    // MinIO AWS S3 SigV4 signature preservation:
    // If the URL has query parameters with X-Amz-Signature, the Host header was signed!
    // Passing the original Host header allows MinIO to verify the HMAC signature.
    Map<String, String>? headers;
    final hasSig = uri.queryParameters.containsKey('X-Amz-Signature') ||
        uri.queryParameters.containsKey('x-amz-signature');
    if (hasSig) {
      final originalHostHeader = originalPort != null
          ? '$originalHost:$originalPort'
          : originalHost;
      headers = {'Host': originalHostHeader};
    }

    return ResolvedMedia(
      url: rewrittenUri.toString(),
      headers: headers,
    );
  }

  static bool _isLocalOrDevHost(String host, int? port, String path) {
    if (_localOrDockerHosts.contains(host)) return true;
    if (port == 19000 || port == 9000) return true;
    if (_isPrivateIp(host)) return true;
    if (_isMinioBucketPath(path) && (port != null && port > 1024)) return true;
    return false;
  }

  static bool _isPrivateIp(String host) {
    final parts = host.split('.');
    if (parts.length != 4) return false;
    final octets = parts.map(int.tryParse).toList();
    if (octets.any((o) => o == null || o < 0 || o > 255)) return false;

    final o1 = octets[0]!;
    final o2 = octets[1]!;

    if (o1 == 10) return true; // 10.0.0.0/8 (includes Android emulator 10.0.2.2)
    if (o1 == 127) return true; // 127.0.0.0/8 (loopback)
    if (o1 == 192 && o2 == 168) return true; // 192.168.0.0/16
    if (o1 == 172 && o2 >= 16 && o2 <= 31) return true; // 172.16.0.0/12

    return false;
  }

  static bool _isMinioBucketPath(String path) {
    final lower = path.toLowerCase();
    return lower.startsWith('/posters/') ||
        lower.startsWith('/chat-media/') ||
        lower.startsWith('/reels/') ||
        lower.startsWith('/avatars/') ||
        lower.startsWith('/cvs/') ||
        lower.startsWith('/videos/') ||
        lower.startsWith('/files/');
  }

  static String _getTargetHost() {
    try {
      if (AppConfig.isInitialized) {
        final apiUri = Uri.tryParse(AppConfig.instance.apiBaseUrl);
        final host = apiUri?.host ?? '';
        if (host.isNotEmpty && host != '0.0.0.0') {
          return host;
        }
      }
    } catch (_) {}

    // Fallback on Android: default to 10.0.2.2 emulator loopback
    if (Platform.isAndroid) {
      return '10.0.2.2';
    }
    return 'localhost';
  }

  static String _getApiBaseUrl() {
    try {
      if (AppConfig.isInitialized) {
        return AppConfig.instance.apiBaseUrl;
      }
    } catch (_) {}
    return '';
  }
}
