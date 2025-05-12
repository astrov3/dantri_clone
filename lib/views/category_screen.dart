import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/category_viewmodel.dart';
import 'detail_screen.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CategoryViewModel(),
      child: DefaultTabController(
        length: CategoryViewModel().getCategories().length, // Số lượng tab
        child: Scaffold(
          appBar: AppBar(
            title: Text('Chuyên Mục'),
            bottom: TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.green,
              tabs:
                  CategoryViewModel()
                      .getCategories()
                      .map((category) => Tab(text: category))
                      .toList(),
            ),
          ),
          body: TabBarView(
            children:
                CategoryViewModel().getCategories().map((category) {
                  return CategoryNewsList(category: category);
                }).toList(),
          ),
        ),
      ),
    );
  }
}

// Widget để hiển thị danh sách tin tức cho mỗi danh mục
class CategoryNewsList extends StatelessWidget {
  final String category;

  const CategoryNewsList({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<CategoryViewModel>(context, listen: false);

    // Đảm bảo chỉ gọi sau khi build hoàn tất
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!viewModel.news.containsKey(category)) {
        viewModel.fetchNewsByCategory(category);
      }
    });

    return Consumer<CategoryViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading && !viewModel.news.containsKey(category)) {
          return Center(child: CircularProgressIndicator());
        }

        final newsList = viewModel.news[category] ?? [];
        if (newsList.isEmpty) {
          return Center(child: Text('Không tải được tin tức'));
        }

        return ListView.builder(
          itemCount: newsList.length,
          itemBuilder: (context, index) {
            var item = newsList[index];
            String? imageUrl = _extractImageUrl(item['description'] ?? '');

            return Card(
              child: ListTile(
                leading:
                    imageUrl != null
                        ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          width: 50,
                          height: 50,
                          placeholder:
                              (context, url) => CircularProgressIndicator(),
                          errorWidget:
                              (context, url, error) => Icon(Icons.error),
                        )
                        : Icon(Icons.image),
                title: Text(item['title'] ?? 'Không có tiêu đề'),
                subtitle: Text(item['pubDate'] ?? 'Không có ngày'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailScreen(item: item),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  String? _extractImageUrl(String description) {
    RegExp regExp = RegExp(
      'https?://[^\\s<>\'\\"\\[\\]]+\\.(?:jpg|jpeg|png|gif)',
    );
    return regExp.firstMatch(description)?.group(0);
  }
}
