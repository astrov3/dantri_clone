import 'package:flutter/material.dart';
import 'package:webfeed/webfeed.dart'; // để dùng RssItem
import '../services/news_service.dart';

class NewsViewModel extends ChangeNotifier {
  List<Map<String, String>> news = [];
  List<Map<String, String>> filteredNews = [];
  final NewsService newsService = NewsService();

  bool isLoading = false;
  String searchQuery = '';

  // Lấy tin tức từ getNews() trả về List<RssItem>
  Future<void> fetchNews() async {
    isLoading = true;
    notifyListeners();

    try {
      List<RssItem> rssItems = await newsService.getNews();
      news = rssItems.map((rssItem) => {
            'title': rssItem.title ?? 'Không có tiêu đề',
            'link': rssItem.link ?? '',
            'description': rssItem.description ?? '',
            'pubDate': rssItem.pubDate?.toString() ?? 'Không có ngày',
          }).toList();

      filteredNews = news; // ban đầu hiển thị tất cả
    } catch (e) {
      print('Error fetching news: $e');
      news = [];
      filteredNews = [];
    }

    isLoading = false;
    notifyListeners();
  }

  void searchNews(String query) {
    searchQuery = query.toLowerCase();
    if (searchQuery.isEmpty) {
      filteredNews = news;
    } else {
      filteredNews = news.where((item) {
        final title = item['title']?.toLowerCase() ?? '';
        final desc = item['description']?.toLowerCase() ?? '';
        return title.contains(searchQuery) || desc.contains(searchQuery);
      }).toList();
    }
    notifyListeners();
  }
}
