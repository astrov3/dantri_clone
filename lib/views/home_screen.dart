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
                // Thời tiết và ngày
                SizedBox(
                  height: 120,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    children: [
                      // Lịch
                      Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        color: Colors.orange[100],
                        child: Container(
                          width: 120,
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.calendar_today, size: 24),
                              const SizedBox(height: 8),
                              Text(
                                'Thứ Tư\n28 Tháng 5\2 Tháng 5 ÂL',
                                style: const TextStyle(fontSize: 12),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Thời tiết
                      Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        color: Colors.blue[100],
                        child: Container(
                          width: 110,
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.cloud, size: 24),
                              const SizedBox(height: 8),
                              const Text(
                                'Hà Nội\n25°C\nĐộ ẩm 75%',
                                style: TextStyle(fontSize: 12),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      //  Giá vàng 
                      Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        color: Colors.yellow[100],
                        child: Container(
                          width: 110,
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.currency_exchange, size: 24),
                              SizedBox(height: 8),
                              Text(
                                'Vàng\nMua: 116.5\nBán: 119.0',
                                style: TextStyle(fontSize: 12),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    

                const SizedBox(height: 8),
                // Giá xăng dầu
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    color: const Color.fromARGB(255, 147, 242, 171),  
                    child: Container(
                      width: 110,
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.local_gas_station, size: 24, color: Color.fromARGB(255, 31, 32, 33)), 
                          SizedBox(height: 8),
                          Text(
                            'Xăng Dầu\nMua: 23.5\nBán: 24.7',
                            style: TextStyle(fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
    
          // Danh sách tin tức 
                Expanded(
                  child: ListView.builder(
                    itemCount: viewModel.filteredNews.length,
                    itemBuilder: (context, index) {
                      var item = viewModel.filteredNews[index];
                      String? imageUrl = _extractImageUrl(
                        item['description'] ?? '',
                      );

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailScreen(item: item),
                            ),
                          );
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 4,
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              imageUrl != null
                                  ? CachedNetworkImage(
                                      imageUrl: imageUrl,
                                      height: 190,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) =>
                                          const SizedBox(height: 180, child: Center(child: CircularProgressIndicator())),
                                      errorWidget: (context, url, error) =>
                                          const SizedBox(height: 180, child: Center(child: Icon(Icons.error))),
                                    )
                                  : const SizedBox(
                                      height: 180,
                                      width: double.infinity,
                                      child: Center(child: Icon(Icons.image)),
                                    ),
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['title'] ?? 'Không có tiêu đề',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                        _extractDescription(item['description'] ?? ''),
                                        style: TextStyle(fontSize: 16),),
                                    const SizedBox(height: 4),
                                    Text(
                                      item['pubDate'] ?? 'Không có ngày',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
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
  // Trích xuất URL hình ảnh từ mô tả
  String? _extractImageUrl(String description) {
    final RegExp regExp = RegExp(
      'https?://[^\\s<>\'\\"\\[\\]]+\\.(?:jpg|jpeg|png|gif)',
    );

    return regExp.firstMatch(description)?.group(0);
  }
}

  // Trích xuất mô tả, loại bỏ HTML và hình ảnh
String _extractDescription(String description) {
    return description
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .split(']]></description>')[0]
        .trim();
  }
String formatPubDate(String pubDate) {
  final match = RegExp(r'\d{2} \w{3} \d{4}').firstMatch(pubDate);
  return match?.group(0) ?? pubDate;
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
