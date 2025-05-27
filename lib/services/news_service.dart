import 'dart:convert'; // Dùng để xử lý mã hóa

import 'package:http/http.dart' as http;
import 'package:webfeed/webfeed.dart';

class NewsService {
  final String baseRssUrl = 'https://dantri.com.vn/rss/home.rss';

  // Danh sách danh mục và URL RSS
  final Map<String, String> categories = {
    'Tin mới nhất': 'https://dantri.com.vn/rss/home.rss',
    'Thế Giới': 'https://dantri.com.vn/rss/the-gioi.rss',
    'Xã Hội': 'https://dantri.com.vn/rss/xa-hoi.rss',
    'Kinh doanh': 'https://dantri.com.vn/rss/kinh-doanh.rss',
    'Giải Trí': 'https://dantri.com.vn/rss/giai-tri.rss',
  };

  Future<List<RssItem>> getNews() async {
    final response = await http.get(Uri.parse(baseRssUrl));

    if (response.statusCode == 200) {
      String xmlString = utf8.decode(response.bodyBytes).trim();
      if (!xmlString.startsWith('<?xml')) {
        xmlString = xmlString.replaceFirst(RegExp(r'^[^<]+'), '');
      }

      try {
        var feed = RssFeed.parse(xmlString);
        return feed.items?.toList() ?? [];
      } catch (e) {
        throw Exception('Failed to parse RSS feed: $e');
      }
    } else {
      throw Exception('Failed to load news: ${response.statusCode}');
    }
  }

  Future<List<Map<String, String>>> getNewsByCategory(String category) async {
    final rssUrl = categories[category] ?? categories['Tin mới nhất']!;
    final response = await http.get(Uri.parse(rssUrl));

    if (response.statusCode == 200) {
      String xmlString = utf8.decode(response.bodyBytes).trim();
      if (!xmlString.startsWith('<?xml')) {
        xmlString = xmlString.replaceFirst(RegExp(r'^[^<]+'), '');
      }

      try {
        var feed = RssFeed.parse(xmlString);
        return feed.items
                ?.map(
                  (item) => {
                    'title': item.title ?? 'Không có tiêu đề',
                    'link': item.link ?? '',
                    'description': item.description ?? '',
                    'pubDate': item.pubDate?.toString() ?? 'Không có ngày',
                  },
                )
                .toList() ??
            [];
      } catch (e) {
        throw Exception('Failed to parse RSS feed: $e');
      }
    } else {
      throw Exception('Failed to load news: ${response.statusCode}');
    }
  }
}

// import 'package:http/http.dart' as http;
// import 'package:webfeed/webfeed.dart';
// import 'dart:convert';

// class NewsService {
//   final Map<String, String> categories = {
//     'Tin mới nhất': 'https://dantri.com.vn/rss/home.rss',
//     'Thế Giới': 'https://dantri.com.vn/rss/the-gioi.rss',
//     'Xã Hội': 'https://dantri.com.vn/rss/xa-hoi.rss',
//     'Kinh doanh': 'https://dantri.com.vn/rss/kinh-doanh.rss',
//     'Giải Trí': 'https://dantri.com.vn/rss/giai-tri.rss',
//   };

//   Future<List<Map<String, String>>> getNewsByCategory(String category) async {
//     final rssUrl = categories[category] ?? categories['Tin mới nhất']!;
//     final response = await http.get(Uri.parse(rssUrl));

//     if (response.statusCode == 200) {
//       String xmlString = utf8.decode(response.bodyBytes).trim();
//       if (!xmlString.startsWith('<?xml')) {
//         xmlString = xmlString.replaceFirst(RegExp(r'^[^<]+'), '');
//       }

//       try {
//         var feed = RssFeed.parse(xmlString);
//         return feed.items?.map((item) => {
//           'title': item.title ?? 'Không có tiêu đề',
//           'link': item.link ?? '',
//           'description': item.description ?? '',
//           'pubDate': item.pubDate?.toString() ?? 'Không có ngày',
//         }).toList() ?? [];
//       } catch (e) {
//         throw Exception('Failed to parse RSS feed: $e');
//       }
//     } else {
//       throw Exception('Failed to load news: ${response.statusCode}');
//     }
//   }
// }
