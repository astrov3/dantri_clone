import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailScreen extends StatelessWidget {
  final Map<String, String> item;

  const DetailScreen({super.key, required this.item});
  // Hàm mở URL
  Future<void> _launchUrl(String url) async {
    if (url.isEmpty) return; // Tránh lỗi nếu URL rỗng

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Không thể mở $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    String? imageUrl = _extractImageUrl(item['description'] ?? '');

    return Scaffold(
      appBar: AppBar(title: Text(item['title'] ?? 'Chi Tiết Tin Tức')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl != null)
              CachedNetworkImage(
                imageUrl: imageUrl,
                placeholder: (context, url) => CircularProgressIndicator(),
                errorWidget: (context, url, error) => Icon(Icons.error),
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            SizedBox(height: 16),
            Text(
              item['title'] ?? 'Không có tiêu đề',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              item['pubDate'] ?? 'Không có ngày',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            SizedBox(height: 16),
            Text(
              _extractDescription(item['description'] ?? ''),
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                try {
                  await _launchUrl(item['link'] ?? '');
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Không thể mở link: $e')),
                  );
                }
              },
              child: Text('Xem Bài Viết Nguyên Bản'),
            ),
          ],
        ),
      ),
    );
  }

  // Trích xuất mô tả, loại bỏ HTML và hình ảnh
  String _extractDescription(String description) {
    return description
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .split(']]></description>')[0]
        .trim();
  }

  // Trích xuất URL hình ảnh từ mô tả
  String? _extractImageUrl(String description) {
    RegExp regExp = RegExp(
      'https?://[^\\s<>\'\\"\\[\\]]+\\.(?:jpg|jpeg|png|gif)',
    );

    return regExp.firstMatch(description)?.group(0);
  }
}
