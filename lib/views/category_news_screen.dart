import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/news_service.dart';

class CategoryNewsScreen extends StatefulWidget {
  final String category;

  const CategoryNewsScreen({super.key, required this.category});

  @override
  State<CategoryNewsScreen> createState() => _CategoryNewsScreenState();
}

class _CategoryNewsScreenState extends State<CategoryNewsScreen> {
  List<Map<String, String>> newsItems = [];
  bool isLoading = true;
  final NewsService newsService = NewsService();

  @override
  void initState() {
    super.initState();
    fetchNews();
  }

  Future<void> fetchNews() async {
    try {
      final items = await newsService.getNewsByCategory(widget.category);
      setState(() {
        newsItems = items;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      print('Lỗi khi tải tin tức: $e');
    }
  }

  void _openLink(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể mở đường dẫn')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.category)),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : newsItems.isEmpty
              ? const Center(child: Text('Không có tin tức'))
              : ListView.builder(
                  itemCount: newsItems.length,
                  itemBuilder: (context, index) {
                    final item = newsItems[index];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        title: Text(item['title'] ?? ''),
                        subtitle: Text(item['pubDate'] ?? ''),
                        onTap: () => _openLink(item['link'] ?? ''),
                      ),
                    );
                  },
                ),
    );
  }
}
