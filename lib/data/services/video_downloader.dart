import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

/// Supported platforms
enum VideoPlatform { instagram, tiktok }

/// Result model containing direct media url and some meta.
class ParsedVideo {
  final Uri mediaUrl;
  final String filename;
  final Map<String, dynamic> extra;

  ParsedVideo({required this.mediaUrl, required this.filename, this.extra = const {}});
}

typedef ProgressCallback = void Function(int received, int total);

class VideoDownloaderService {
  final http.Client httpClient;
  VideoDownloaderService({http.Client? httpClient}) : httpClient = httpClient ?? http.Client();

  // Detect platform
  VideoPlatform? detectPlatform(String url) {
    final u = url.toLowerCase();
    if (u.contains('tiktok.com')) return VideoPlatform.tiktok;
    if (u.contains('instagram.com')) return VideoPlatform.instagram;
    return null;
  }

  Future<ParsedVideo> parse(String url, {bool tiktokNoWatermark = true}) async {
    final platform = detectPlatform(url);
    if (platform == null) {
      throw const FormatException('Unsupported URL');
    }
    switch (platform) {
      case VideoPlatform.tiktok:
        return _parseTikTok(url, noWatermark: tiktokNoWatermark);
      case VideoPlatform.instagram:
        return _parseInstagram(url);
    }
  }

  // TikTok parsing strategy:
  // 1) Resolve final HTML by following redirects for mobile share links
  // 2) Find embedded JSON in <script id="SIGI_STATE"> or "__NEXT_DATA__"
  // 3) Pick playAddr (no watermark) if available; fallback to downloadAddr (watermark)
  Future<ParsedVideo> _parseTikTok(String url, {required bool noWatermark}) async {
    final resolved = await _getResolvedHtml(Uri.parse(url));
    final html = resolved.body;

    // Try __NEXT_DATA__ first
    final nextDataMatch = RegExp(r'<script id="__NEXT_DATA__"[^>]*>([\s\S]*?)</script>').firstMatch(html);
    String? videoUrl;
    if (nextDataMatch != null) {
      final jsonStr = nextDataMatch.group(1)!;
      final map = json.decode(jsonStr) as Map<String, dynamic>;
      videoUrl = _extractTikTokUrlFromNextData(map, preferNoWatermark: noWatermark);
    }
    // Fallback SIGI_STATE
    if (videoUrl == null) {
      final sigiMatch = RegExp(r'<script id="SIGI_STATE"[^>]*>([\s\S]*?)</script>').firstMatch(html);
      if (sigiMatch != null) {
        final jsonStr = sigiMatch.group(1)!;
        final map = json.decode(jsonStr) as Map<String, dynamic>;
        videoUrl = _extractTikTokUrlFromSigi(map, preferNoWatermark: noWatermark);
      }
    }
    if (videoUrl == null) {
      throw StateError('Unable to parse TikTok media');
    }
    final media = Uri.parse(videoUrl);
    final file = 'tiktok_${DateTime.now().millisecondsSinceEpoch}.mp4';
    return ParsedVideo(mediaUrl: media, filename: file);
  }

  String? _extractTikTokUrlFromNextData(Map<String, dynamic> data, {required bool preferNoWatermark}) {
    try {
      final item = (((data['props'] as Map)['pageProps'] as Map)['itemInfo'] as Map)['itemStruct'] as Map;
      final video = item['video'] as Map;
      if (preferNoWatermark && video['playAddr'] != null) {
        return (video['playAddr'] as String).replaceAll('\u0026', '&');
      }
      if (video['downloadAddr'] != null) {
        return (video['downloadAddr'] as String).replaceAll('\u0026', '&');
      }
    } catch (_) {}
    return null;
  }

  String? _extractTikTokUrlFromSigi(Map<String, dynamic> data, {required bool preferNoWatermark}) {
    try {
      final itemModule = (data['ItemModule'] as Map).values.first as Map;
      final video = itemModule['video'] as Map;
      if (preferNoWatermark && video['playAddr'] != null) {
        return (video['playAddr'] as String).replaceAll('\u0026', '&');
      }
      if (video['downloadAddr'] != null) {
        return (video['downloadAddr'] as String).replaceAll('\u0026', '&');
      }
    } catch (_) {}
    return null;
  }

  // Instagram parsing strategy:
  // Use open graph meta og:video or embedded JSON in window._sharedData / __a query.
  Future<ParsedVideo> _parseInstagram(String url) async {
    final res = await _getResolvedHtml(Uri.parse(url));
    final html = res.body;
    // Try og:video
    final ogVideo = RegExp(r'<meta property="og:video" content="([^"]+)"').firstMatch(html)?.group(1);
    if (ogVideo != null) {
      final media = Uri.parse(ogVideo);
      final file = 'instagram_${DateTime.now().millisecondsSinceEpoch}.mp4';
      return ParsedVideo(mediaUrl: media, filename: file);
    }
    // Try JSON inside <script type="application/ld+json">
    final ld = RegExp(r'<script type="application/ld\+json">([\s\S]*?)</script>').firstMatch(html)?.group(1);
    if (ld != null) {
      try {
        final map = json.decode(ld);
        final videoUrl = (map is Map) ? map['contentUrl'] as String? : null;
        if (videoUrl != null) {
          final media = Uri.parse(videoUrl);
          final file = 'instagram_${DateTime.now().millisecondsSinceEpoch}.mp4';
          return ParsedVideo(mediaUrl: media, filename: file);
        }
      } catch (_) {}
    }
    // Try window.__additionalDataLoaded / __NEXT_DATA__ variants
    final nextDataMatch = RegExp(r'<script id="__NEXT_DATA__"[^>]*>([\s\S]*?)</script>').firstMatch(html);
    if (nextDataMatch != null) {
      try {
        final map = json.decode(nextDataMatch.group(1)!);
        final url = _extractInstagramFromNext(map);
        if (url != null) {
          return ParsedVideo(mediaUrl: Uri.parse(url), filename: 'instagram_${DateTime.now().millisecondsSinceEpoch}.mp4');
        }
      } catch (_) {}
    }
    throw StateError('Unable to parse Instagram media');
  }

  String? _extractInstagramFromNext(dynamic data) {
    try {
      // This is intentionally loose; structure changes often.
      final jsonStr = json.encode(data);
      final m = RegExp(r'"video_url":"(https:\\/\\/[^\"]+\.mp4)"').firstMatch(jsonStr);
      if (m != null) {
        return m.group(1)!.replaceAll('\\/', '/');
      }
    } catch (_) {}
    return null;
  }

  // Follow redirects and fetch HTML
  Future<http.Response> _getResolvedHtml(Uri uri) async {
    final res = await httpClient.get(uri, headers: _headers());
    if (res.statusCode >= 300 && res.statusCode < 400) {
      final loc = res.headers['location'];
      if (loc != null) {
        return _getResolvedHtml(Uri.parse(loc));
      }
    }
    if (res.statusCode != 200) {
      throw HttpException('HTTP ${res.statusCode}');
    }
    return res;
  }

  Map<String, String> _headers() => {
        'User-Agent': 'Mozilla/5.0 (Linux; Android 14; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36',
        'Accept-Language': 'en-US,en;q=0.9',
      };

  // Download mp4 with progress; returns saved file path.
  Future<File> downloadToFile(ParsedVideo parsed, Directory targetDir, {ProgressCallback? onProgress}) async {
    if (!targetDir.existsSync()) targetDir.createSync(recursive: true);
    final file = File('${targetDir.path}/${parsed.filename}');
    final request = http.Request('GET', parsed.mediaUrl)..headers.addAll(_headers());
    final streamed = await httpClient.send(request);
    if (streamed.statusCode != 200) {
      throw HttpException('Download failed: HTTP ${streamed.statusCode}');
    }
    final total = streamed.contentLength ?? 0;
    int received = 0;
    final sink = file.openWrite();
    await streamed.stream.map((c) {
      received += c.length;
      if (onProgress != null && total > 0) onProgress(received, total);
      return c;
    }).pipe(sink);
    await sink.close();
    return file;
  }
}


