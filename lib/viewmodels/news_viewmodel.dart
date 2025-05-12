import 'package:flutter/material.dart';
import 'package:webfeed/webfeed.dart'; // Đảm bảo import webfeed
import '../services/news_service.dart';

class NewsViewModel extends ChangeNotifier {
  List<Map<String, String>> news = [];
  List<Map<String, String>> filteredNews = [];
  final NewsService newsService = NewsService();
  bool isLoading = false;
  String searchQuery = '';

  void fetchNews() async {
    isLoading = true;
    notifyListeners();

    try {
      List<RssItem> rssItems = await newsService.getNews();
      news =
          rssItems
              .map(
                (rssItem) => {
                  'title': rssItem.title ?? 'Không có tiêu đề',
                  'link': rssItem.link ?? '',
                  'description': rssItem.description ?? '',
                  'pubDate': rssItem.pubDate?.toString() ?? 'Không có ngày',
                },
              )
              .toList();
      filteredNews = news; // Ban đầu hiển thị tất cả tin tức
    } catch (e) {
      print('Error: $e');
    }

    isLoading = false;
    notifyListeners();
  }

  void searchNews(String query) {
    searchQuery = query.toLowerCase();
    if (searchQuery.isEmpty) {
      filteredNews = news; // Hiển thị tất cả nếu không có từ khóa
    } else {
      filteredNews =
          news.where((item) {
            return (item['title']?.toLowerCase().contains(searchQuery) ??
                    false) ||
                (item['description']?.toLowerCase().contains(searchQuery) ??
                    false);
          }).toList();
    }
    notifyListeners();
  }
}
