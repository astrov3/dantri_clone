import 'package:cached_network_image/cached_network_image.dart';
import 'package:dantri_clone/utils/text_formatter.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
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
    String formattedDate = TextFormatter.formatDateTime(item['pubDate'] ?? '');
    String description = _extractDescription(item['description'] ?? '');

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(item['title'] ?? 'Chi Tiết Tin Tức'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              Share.share(
                '${item['title']}\n\n${item['link']}',
                subject: item['title'],
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl != null)
              Hero(
                tag: imageUrl,
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  placeholder:
                      (context, url) => Container(
                        height: 200,
                        color: Colors.grey[200],
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                  errorWidget:
                      (context, url, error) => Container(
                        height: 200,
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(Icons.error_outline, size: 40),
                        ),
                      ),
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title'] ?? 'Không có tiêu đề',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        formattedDate,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  RichText(
                    text: TextSpan(
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(height: 1.6),
                      children: TextFormatter.parseFormattedText(description),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        try {
                          await _launchUrl(item['link'] ?? '');
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Không thể mở link: $e'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.launch),
                      label: const Text('Xem Bài Viết Nguyên Bản'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
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
