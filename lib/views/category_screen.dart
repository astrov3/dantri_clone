import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // để dùng listEquals
import 'package:provider/provider.dart';

import '../viewmodels/category_viewmodel.dart';
import '../widgets/category_drawer.dart';
import 'detail_screen.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({Key? key}) : super(key: key);

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> with TickerProviderStateMixin {
  TabController? _tabController;
  List<String> categories = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final viewModel = Provider.of<CategoryViewModel>(context);
    final newCategories = viewModel.getCategories();

    if (!listEquals(newCategories, categories)) {
      categories = newCategories;

      _tabController?.dispose();

      if (categories.isNotEmpty) {
        _tabController = TabController(length: categories.length, vsync: this);
      } else {
        _tabController = null;
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void _onCategorySelected(String category, String rssUrl) {
    final index = categories.indexOf(category);
    if (index != -1 && _tabController != null) {
      _tabController!.animateTo(index);
    }
    if (mounted) {
      Future.microtask(() => Navigator.pop(context));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chuyên Mục'),
        bottom: (_tabController != null)
            ? TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.green,
                tabs: categories.map((category) => Tab(text: category)).toList(),
              )
            : null,
      ),
      drawer: CategoryDrawer(onCategorySelected: _onCategorySelected),
      body: (_tabController != null)
          ? TabBarView(
              controller: _tabController,
              children: categories
                  .map((category) => CategoryNewsList(category: category))
                  .toList(),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}

class CategoryNewsList extends StatefulWidget {
  final String category;

  const CategoryNewsList({Key? key, required this.category}) : super(key: key);

  @override
  State<CategoryNewsList> createState() => _CategoryNewsListState();
}

class _CategoryNewsListState extends State<CategoryNewsList> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<CategoryViewModel>(context, listen: false);
      if (!viewModel.news.containsKey(widget.category)) {
        viewModel.fetchNewsByCategory(widget.category);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading && !viewModel.news.containsKey(widget.category)) {
          return const Center(child: CircularProgressIndicator());
        }

        final newsList = viewModel.news[widget.category] ?? [];

        if (newsList.isEmpty) {
          return const Center(child: Text('Không tải được tin tức'));
        }

        return ListView.builder(
          itemCount: newsList.length,
          itemBuilder: (context, index) {
            final item = newsList[index];
            String pubDate = (item["pubDate"]?.split(" ").first) ?? "Thời gian";

            String? imageUrl = _extractImageUrl(item);

            if (imageUrl != null && imageUrl.isNotEmpty) {
              if (!imageUrl.startsWith('http')) {
                imageUrl = 'https:$imageUrl';
              }
            }

            final bool showImage = imageUrl != null && imageUrl.isNotEmpty;

            return InkWell(
              onTap: () {
                if (mounted) {
                  Future.microtask(() {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailScreen(item: item),
                      ),
                    );
                  });
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.fiber_manual_record,
                                size: 10,
                                color: Colors.green,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '$pubDate · ${widget.category}',
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item['title'] ?? 'Không có tiêu đề',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (item['description'] != null)
                            Text(
                              _stripHtmlTags(item['description']!),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                            ),
                        ],
                      ),
                    ),
                    if (showImage)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            imageUrl!,
                            width: 100,
                            height: 80,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                width: 100,
                                height: 80,
                                alignment: Alignment.center,
                                child: const CircularProgressIndicator(strokeWidth: 2),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 100,
                                height: 80,
                                color: Colors.grey[300],
                                child: const Icon(
                                  Icons.broken_image,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String? _extractImageUrl(Map item) {
    if (item['enclosure'] != null && item['enclosure'] is Map) {
      final url = (item['enclosure'] as Map)['url'];
      if (url != null && url.toString().isNotEmpty) return url.toString();
    }

    final description = item['description'] ?? '';
    final regex = RegExp(r'<img[^>]+src="([^"]+)"[^>]*>');
    final match = regex.firstMatch(description);
    if (match != null) return match.group(1);

    return null;
  }

  String _stripHtmlTags(String htmlText) {
    final document = RegExp(r'<[^>]*>', multiLine: true, caseSensitive: true);
    return htmlText.replaceAll(document, '');
  }
}
