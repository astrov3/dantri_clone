import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../viewmodels/news_viewmodel.dart';
import 'detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NewsViewModel()..fetchNews(),
      child: Consumer<NewsViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (viewModel.news.isEmpty) {
            return Center(child: Text('Không tải được tin tức'));
          }

          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: Icon(Icons.person_outline),
                onPressed: () {
                  context.push('/profile');
                },
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.notifications_outlined),
                  onPressed: () {
                    context.push('/notifications');
                  },
                ),
              ],
            ),

            body: Column(
              children: [
                // Thêm thanh tìm kiếm (sẽ cập nhật bên dưới)
                Container(
                  padding: EdgeInsets.all(8.0),
                  child: SafeArea(child: SearchBar()),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: viewModel.filteredNews.length,
                    itemBuilder: (context, index) {
                      var item = viewModel.filteredNews[index];
                      String? imageUrl = _extractImageUrl(
                        item['description'] ?? '',
                      );

                      return Card(
                        child: ListTile(
                          leading:
                              imageUrl != null
                                  ? CachedNetworkImage(
                                    imageUrl: imageUrl,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    placeholder:
                                        (context, url) =>
                                            CircularProgressIndicator(),
                                    errorWidget:
                                        (context, url, error) =>
                                            Icon(Icons.error),
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
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String? _extractImageUrl(String description) {
    RegExp regExp = RegExp(
      'https?://[^\\s<>\'\\"\\[\\]]+\\.(?:jpg|jpeg|png|gif)',
    );

    return regExp.firstMatch(description)?.group(0);
  }
}

// Thêm lớp SearchBar (sẽ định nghĩa sau)
class SearchBar extends StatelessWidget {
  const SearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Tìm kiếm tin tức...',
        prefixIcon: Icon(Icons.search),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
      onChanged: (value) {
        Provider.of<NewsViewModel>(context, listen: false).searchNews(value);
      },
    );
  }
}
