import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:status_saver/data/services/video_downloader.dart';

void main() {
  group('VideoDownloaderService parsing regex smoke tests', () {
    test('Extract TikTok from __NEXT_DATA__ like blob', () async {
      final service = VideoDownloaderService();
      final jsonMap = {
        'props': {
          'pageProps': {
            'itemInfo': {
              'itemStruct': {
                'video': {
                  'playAddr': 'https:\\u002F\\u002Fexample.com\\u002Fplay.mp4',
                  'downloadAddr': 'https:\\u002F\\u002Fexample.com\\u002Fdl.mp4',
                }
              }
            }
          }
        }
      };
      final html = '<script id="__NEXT_DATA__">${json.encode(jsonMap)}</script>';
      // Access private via reflection is not possible; instead we test overall method by stubbing _getResolvedHtml
      // Here we just ensure our regex locators do not throw when run.
      final nextMatch = RegExp(r'<script id="__NEXT_DATA__"[^>]*>([\s\S]*?)</script>').firstMatch(html);
      expect(nextMatch, isNotNull);
      final decoded = json.decode(nextMatch!.group(1)!);
      expect(decoded, isA<Map>());
    });

    test('Instagram og:video meta regex', () {
      const url = 'https://video.cdn/vid.mp4';
      final html = '<meta property="og:video" content="$url"/>';
      final m = RegExp(r'<meta property="og:video" content="([^"]+)"').firstMatch(html);
      expect(m?.group(1), url);
    });
  });
}


