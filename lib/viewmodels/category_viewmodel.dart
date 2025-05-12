import 'package:flutter/material.dart';
import '../services/news_service.dart';

class CategoryViewModel extends ChangeNotifier {
  Map<String, List<Map<String, String>>> news = {}; // Lưu tin tức theo danh mục
  final NewsService newsService = NewsService();
  bool isLoading = false;

  CategoryViewModel() {
    for (var category in getCategories()) {
      fetchNewsByCategory(category);
    }
  }

  void fetchNewsByCategory(String category) async {
    if (news.containsKey(category)) {
      return; // Không tải lại nếu đã có dữ liệu
    }

    isLoading = true;
    notifyListeners();

    try {
      news[category] = await newsService.getNewsByCategory(category);
    } catch (e) {
      print('Error: $e');
      news[category] = []; // Gán danh sách rỗng nếu lỗi
    }

    isLoading = false;
    notifyListeners();
  }

  List<String> getCategories() {
    return newsService.categories.keys.toList();
  }
}
