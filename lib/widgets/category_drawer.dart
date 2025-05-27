import 'package:flutter/material.dart';

class CategoryDrawer extends StatelessWidget {
  final void Function(String category, String rssUrl) onCategorySelected;

  CategoryDrawer({
    super.key,
    required this.onCategorySelected,
  });

  final Map<String, String> categoryUrls = {
    'Tin mới nhất': 'https://dantri.com.vn/rss/home.rss',
    'Điểm tin nổi bật': 'https://dantri.com.vn/rss/home.rss',
    'Kinh doanh': 'https://dantri.com.vn/rss/kinh-doanh.rss',
    'Xã hội': 'https://dantri.com.vn/rss/xa-hoi.rss',
    'Thế giới': 'https://dantri.com.vn/rss/the-gioi.rss',
    'Giải trí': 'https://dantri.com.vn/rss/giai-tri.rss',
    'Bất động sản': 'https://dantri.com.vn/rss/bat-dong-san.rss',
    'Thể thao': 'https://dantri.com.vn/rss/the-thao.rss',
    'Sức khỏe': 'https://dantri.com.vn/rss/suc-khoe.rss',
    'Nội vụ': 'https://dantri.com.vn/rss/noi-vu.rss',
    'Nhân ái': 'https://dantri.com.vn/rss/nhan-ai.rss',
    'Xe ++': 'https://dantri.com.vn/rss/xe.rss',
    'Công nghệ': 'https://dantri.com.vn/rss/cong-nghe.rss',
    'Giáo dục': 'https://dantri.com.vn/rss/giao-duc.rss',
    'Việc làm': 'https://dantri.com.vn/rss/viec-lam.rss',
  };

  @override
  Widget build(BuildContext context) {
    final categories = categoryUrls.keys.toList();

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: const Text(
                'Chuyên mục',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  final isHighlight = cat == 'Điểm tin nổi bật';
                  final isLatest = cat == 'Tin mới nhất';

                  return ListTile(
                    leading: isLatest
                        ? const Icon(Icons.update, color: Colors.blue)
                        : isHighlight
                            ? const Icon(Icons.local_fire_department, color: Colors.red)
                            : null,
                    title: Text(
                      cat,
                      style: TextStyle(
                        color: isHighlight ? Colors.red : null,
                        fontWeight: isHighlight ? FontWeight.bold : null,
                      ),
                    ),
                    onTap: () {
                      final url = categoryUrls[cat]!;
                      onCategorySelected(cat, url); // Gọi callback xử lý hiển thị tin
                      Navigator.pop(context); // Đóng Drawer
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
