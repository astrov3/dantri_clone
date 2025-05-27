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

  // Thêm map cho hình ảnh của các chuyên mục
  final Map<String, String> categoryImages = const {
    'Thế giới':
        'https://images.unsplash.com/photo-1569982175971-d92b01cf8694?w=100&h=60&fit=crop',
    'Xã hội':
        'https://images.unsplash.com/photo-1559027615-cd4628902d4a?w=100&h=60&fit=crop',
    'Kinh doanh':
        'https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=100&h=60&fit=crop',
    'Giải trí':
        'https://images.unsplash.com/photo-1489599142675-e8935114b25d?w=100&h=60&fit=crop',
    'Bất động sản':
        'https://images.unsplash.com/photo-1560518883-ce09059eeffa?w=100&h=60&fit=crop',
    'Thể thao':
        'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=100&h=60&fit=crop',
    'Sức khỏe':
        'https://images.unsplash.com/photo-1505751172876-fa1923c5c528?w=100&h=60&fit=crop',
    'Nội vụ':
        'https://images.unsplash.com/photo-1529107386315-e1a2ed48a620?w=100&h=60&fit=crop',
    'Nhân ái':
        'https://images.unsplash.com/photo-1559027615-cd4628902d4a?w=100&h=60&fit=crop',
    'Xe ++':
        'https://images.unsplash.com/photo-1449824913935-59a10b8d2000?w=100&h=60&fit=crop',
    'Công nghệ':
        'https://images.unsplash.com/photo-1518709268805-4e9042af2176?w=100&h=60&fit=crop',
    'Giáo dục':
        'https://images.unsplash.com/photo-1497486751825-1233686d5d80?w=100&h=60&fit=crop',
    'Việc làm':
        'https://images.unsplash.com/photo-1521737604893-d14cc237f11d?w=100&h=60&fit=crop',
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
                  final hasImage = categoryImages.containsKey(cat);

                  IconData? iconData;
                  Color? iconColor;

                  if (isLatest) {
                    iconData = Icons.fiber_new;
                    iconColor = Colors.blue;
                  } else if (isHighlight) {
                    iconData = Icons.local_fire_department;
                    iconColor = Colors.red;
                  } else if (!hasImage) {
                    // Chỉ hiển thị icon cho những mục không có hình ảnh
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
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      leading:
                          hasImage
                              ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  categoryImages[cat]!,
                                  width: 50,
                                  height: 40,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (
                                    context,
                                    child,
                                    loadingProgress,
                                  ) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      width: 50,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Center(
                                        child: SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 50,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.image_not_supported,
                                        color: Colors.grey[600],
                                        size: 20,
                                      ),
                                    );
                                  },
                                ),
                              )
                              : Icon(iconData, color: iconColor, size: 22),
                      title: Text(
                        cat,
                        style: TextStyle(
                          color: isHighlight ? Colors.red : Colors.black87,
                          fontWeight:
                              isHighlight || isLatest
                                  ? FontWeight.bold
                                  : FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: Colors.grey,
                      ),
                      onTap: () {
                        final url = categoryUrls[cat]!;
                        onCategorySelected(cat, url);
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      hoverColor: Colors.grey.withOpacity(0.05),
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
