import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (viewModel.news.isEmpty) {
            return const Scaffold(
              body: Center(child: Text('Không tải được tin tức')),
            );
          }

          return Scaffold(
            appBar: AppBar(
              title: const Text("Tin tức"),
              leading: IconButton(
                icon: const Icon(Icons.person_outline),
                onPressed: () {
                  final user = FirebaseAuth.instance.currentUser;

                  if (user != null) {
                    // Đã đăng nhập => chuyển tới trang Profile qua GoRouter
                    context.go('/profile');
                  } else {
                    // Chưa đăng nhập => chuyển tới trang Login
                    context.go('/login');
                  }
                },
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {
                    context.push('/notifications');
                  },
                ),
              ],
            ),

            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
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
                                            const CircularProgressIndicator(),
                                    errorWidget:
                                        (context, url, error) =>
                                            const Icon(Icons.error),
                                  )
                                  : const Icon(Icons.image),
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
    final RegExp regExp = RegExp(
      'https?://[^\\s<>\'\\"\\[\\]]+\\.(?:jpg|jpeg|png|gif)',
    );

    return regExp.firstMatch(description)?.group(0);
  }
}

class SearchBar extends StatelessWidget {
  const SearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Tìm kiếm tin tức...',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
      onChanged: (value) {
        Provider.of<NewsViewModel>(context, listen: false).searchNews(value);
      },
    );
  }
}
