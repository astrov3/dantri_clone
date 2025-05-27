import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class UtilityScreen extends StatefulWidget {
  const UtilityScreen({super.key});

  @override
  State<UtilityScreen> createState() => _UtilityScreenState();
}

class _UtilityScreenState extends State<UtilityScreen> {
  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Profile Section
                GestureDetector(
                  onTap: () {
                    if (user != null) {
                      context.push('/profile');
                    } else {
                      context.push('/login');
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child:
                        user != null
                            ? Row(
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Colors.white,
                                  child: ClipOval(
                                    child: Image.network(
                                      user.photoURL ??
                                          'https://via.placeholder.com/40',
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        user.displayName ?? 'Người dùng',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        user.email ?? '',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                            : Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const CircleAvatar(
                                    radius: 30,
                                    backgroundColor: Colors.transparent,
                                    child: Icon(Icons.person, size: 40),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Đăng nhập',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Đăng nhập để sử dụng đầy đủ tính năng',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                  ),
                ),

                const SizedBox(height: 24),

                // Quick Actions Section
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconText(icon: Icons.notifications, text: 'Thông báo'),
                      IconText(icon: Icons.bookmark, text: 'Đã lưu'),
                      IconText(icon: Icons.history, text: 'Đã xem'),
                      IconText(icon: Icons.settings, text: 'Tùy chỉnh'),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Pinned Features Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SectionTitle(title: 'Đã ghim'),
                    TextButton.icon(
                      onPressed: () {
                        // TODO: Implement edit functionality
                      },
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Sửa'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 4,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.0,
                  children: const [
                    FeatureIcon(
                      title: 'Lịch vạn niên',
                      icon: Icons.calendar_today,
                      color: Colors.red,
                    ),
                    FeatureIcon(
                      title: 'Thời tiết',
                      icon: Icons.cloud,
                      color: Colors.blue,
                    ),
                    FeatureIcon(
                      title: 'Giá vàng',
                      icon: Icons.monetization_on,
                      color: Colors.amber,
                    ),
                    FeatureIcon(
                      title: 'Giá xăng dầu',
                      icon: Icons.local_gas_station,
                      color: Colors.green,
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // All Utilities Section
                SectionTitle(title: 'Tất cả tiện ích'),
                const SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 4,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.0,
                  children: const [
                    FeatureIcon(
                      title: 'Bóng đá',
                      icon: Icons.sports_soccer,
                      color: Colors.green,
                    ),
                    FeatureIcon(
                      title: 'Lãi suất',
                      icon: Icons.attach_money,
                      color: Colors.orange,
                    ),
                    FeatureIcon(
                      title: 'Xổ số',
                      icon: Icons.confirmation_number,
                      color: Colors.grey,
                    ),
                    FeatureIcon(
                      title: 'Chứng khoán',
                      icon: Icons.show_chart,
                      color: Colors.blue,
                    ),
                    FeatureIcon(
                      title: 'Ngoại tệ',
                      icon: Icons.swap_horiz,
                      color: Colors.orange,
                    ),
                    FeatureIcon(
                      title: 'Nhân ái',
                      icon: Icons.volunteer_activism,
                      color: Colors.green,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class IconText extends StatelessWidget {
  final IconData icon;
  final String text;
  const IconText({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 32, color: Colors.green),
        const SizedBox(height: 8),
        Text(
          text,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

class FeatureIcon extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  const FeatureIcon({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }
}
