import 'package:flutter/foundation.dart'; // để dùng listEquals
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../viewmodels/category_viewmodel.dart';
import '../widgets/category_drawer.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen>
    with TickerProviderStateMixin {
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
    // Tải dữ liệu cho category được chọn
    final viewModel = Provider.of<CategoryViewModel>(context, listen: false);

    // Thêm category vào danh sách nếu chưa có
    if (!categories.contains(category)) {
      categories.add(category);

      // Tạo lại TabController với số lượng tab mới
      _tabController?.dispose();
      _tabController = TabController(length: categories.length, vsync: this);

      // Rebuild widget
      if (mounted) {
        setState(() {});
      }
    }

    // Tải tin tức cho category này
    viewModel.fetchNewsByCategory(category);

    // Chuyển đến tab tương ứng
    final index = categories.indexOf(category);
    if (index != -1 && _tabController != null) {
      _tabController!.animateTo(index);
    }

    // Đóng drawer
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chuyên Mục'),
        bottom:
            (_tabController != null && categories.isNotEmpty)
                ? TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.green,
                  indicatorPadding: EdgeInsets.zero,
                  tabAlignment: TabAlignment.start,
                  labelStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  tabs:
                      categories
                          .map((category) => Tab(text: category))
                          .toList(),
                )
                : null,
      ),
      drawer: CategoryDrawer(onCategorySelected: _onCategorySelected),
      body:
          (_tabController != null && categories.isNotEmpty)
              ? TabBarView(
                controller: _tabController,
                children:
                    categories
                        .map((category) => CategoryNewsList(category: category))
                        .toList(),
              )
              : const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.menu_book, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'Chọn chuyên mục từ menu để xem tin tức',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),
    );
  }
}

class CategoryNewsList extends StatefulWidget {
  final String category;

  const CategoryNewsList({Key? key, required this.category}) : super(key: key);

  @override
  State<CategoryNewsList> createState() => _CategoryNewsListState();
}

class _CategoryNewsListState extends State<CategoryNewsList>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // Giữ state khi chuyển tab

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
    super.build(context); // Cần thiết cho AutomaticKeepAliveClientMixin

    return Consumer<CategoryViewModel>(
      builder: (context, viewModel, child) {
        // Hiển thị loading khi đang tải và chưa có dữ liệu
        if (viewModel.isLoading &&
            !viewModel.news.containsKey(widget.category)) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Đang tải tin tức...'),
              ],
            ),
          );
        }

        final newsList = viewModel.news[widget.category] ?? [];

        if (newsList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.info_outline, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'Không có tin tức cho chuyên mục ${widget.category}',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    viewModel.fetchNewsByCategory(widget.category);
                  },
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            viewModel.fetchNewsByCategory(widget.category);
          },
          color: Colors.white,
          backgroundColor: Colors.green,
          strokeWidth: 3,
          child: ListView.builder(
            padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: newsList.length,
            itemBuilder: (context, index) {
              final item = newsList[index];
              String pubDate =
                  (item["pubDate"]?.split(" ").first) ?? "Thời gian";

              String? imageUrl = _extractImageUrl(item);

              if (imageUrl != null && imageUrl.isNotEmpty) {
                if (!imageUrl.startsWith('http')) {
                  imageUrl = 'https:$imageUrl';
                }
              }

              final bool showImage = imageUrl != null && imageUrl.isNotEmpty;

              return Card(
                color: Colors.white,
                margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  onTap: () {
                    if (mounted) {
                      context.push('/detail', extra: item);
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hiển thị hình ảnh lớn ở đầu (nếu có)
                      if (showImage)
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                          child: Image.network(
                            imageUrl,
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                width: double.infinity,
                                height: 200,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    topRight: Radius.circular(12),
                                  ),
                                ),
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: double.infinity,
                                height: 200,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    topRight: Radius.circular(12),
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.broken_image,
                                      color: Colors.grey[600],
                                      size: 48,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Không thể tải hình ảnh',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),

                      // Nội dung tin tức
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Tag chuyên mục và thời gian
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.green.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  widget.category,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.green,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Icon(
                                Icons.access_time,
                                size: 14,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                pubDate,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),

                          // Tiêu đề tin tức
                          Text(
                            item['title'] ?? 'Không có tiêu đề',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Mô tả tin tức
                          if (item['description'] != null)
                            Text(
                              _stripHtmlTags(item['description']!),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                                height: 1.5,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
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
