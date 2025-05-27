import 'package:flutter/material.dart';

class CategoryDrawer extends StatelessWidget {
  final void Function(String category, String rssUrl) onCategorySelected;

  const CategoryDrawer({super.key, required this.onCategorySelected});

  final Map<String, String> categoryUrls = const {
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
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.green.withOpacity(0.1)),
              child: Row(
                children: [
                  const Icon(Icons.category, color: Colors.green, size: 24),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Chuyên mục',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  final isHighlight = cat == 'Điểm tin nổi bật';
                  final isLatest = cat == 'Tin mới nhất';

                  IconData? iconData;
                  Color? iconColor;

                  if (isLatest) {
                    iconData = Icons.fiber_new;
                    iconColor = Colors.blue;
                  } else if (isHighlight) {
                    iconData = Icons.local_fire_department;
                    iconColor = Colors.red;
                  } else {
                    // Gán icon cho từng category
                    switch (cat) {
                      case 'Kinh doanh':
                        iconData = Icons.business;
                        iconColor = Colors.green;
                        break;
                      case 'Xã hội':
                        iconData = Icons.people;
                        iconColor = Colors.orange;
                        break;
                      case 'Thế giới':
                        iconData = Icons.public;
                        iconColor = Colors.purple;
                        break;
                      case 'Giải trí':
                        iconData = Icons.movie;
                        iconColor = Colors.pink;
                        break;
                      case 'Bất động sản':
                        iconData = Icons.home;
                        iconColor = Colors.brown;
                        break;
                      case 'Thể thao':
                        iconData = Icons.sports_soccer;
                        iconColor = Colors.red;
                        break;
                      case 'Sức khỏe':
                        iconData = Icons.health_and_safety;
                        iconColor = Colors.green;
                        break;
                      case 'Xe ++':
                        iconData = Icons.directions_car;
                        iconColor = Colors.blue;
                        break;
                      case 'Công nghệ':
                        iconData = Icons.computer;
                        iconColor = Colors.indigo;
                        break;
                      case 'Giáo dục':
                        iconData = Icons.school;
                        iconColor = Colors.teal;
                        break;
                      case 'Việc làm':
                        iconData = Icons.work;
                        iconColor = Colors.amber;
                        break;
                      default:
                        iconData = Icons.article;
                        iconColor = Colors.grey;
                    }
                  }

                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      leading: Icon(iconData, color: iconColor, size: 20),
                      title: Text(
                        cat,
                        style: TextStyle(
                          color: isHighlight ? Colors.red : Colors.black87,
                          fontWeight:
                              isHighlight || isLatest
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                      onTap: () {
                        final url = categoryUrls[cat]!;
                        onCategorySelected(cat, url);
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      hoverColor: Colors.grey.withOpacity(0.1),
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Chọn chuyên mục để xem tin tức',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
