import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Không có người dùng đăng nhập.")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tài khoản của bạn'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              _showOptions(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (user.photoURL != null)
              CircleAvatar(
                backgroundImage: NetworkImage(user.photoURL!),
                radius: 50,
              )
            else
              const CircleAvatar(
                child: Icon(Icons.person, size: 50),
                radius: 50,
              ),
            const SizedBox(height: 20),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.email),
                      title: Text(
                        user.email ?? 'Không có email',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(
                        user.displayName ?? 'Chưa cập nhật tên',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.perm_identity),
                      title: Text(
                        user.uid,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.blue),
                  title: const Text('Đăng xuất'),
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.of(context).pop(); // đóng bottom sheet
                    context.go('/home'); // chuyển về trang home
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: Colors.red),
                  title: const Text(
                    'Xoá tài khoản',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () async {
                    try {
                      await FirebaseAuth.instance.currentUser?.delete();
                      Navigator.of(context).pop(); // đóng bottom sheet
                      context.go('/home'); // chuyển về trang home
                    } on FirebaseAuthException catch (e) {
                      Navigator.of(context).pop();
                      _showErrorDialog(
                        context,
                        e.message ?? 'Xoá tài khoản thất bại.',
                      );
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.cancel),
                  title: const Text('Hủy'),
                  onTap: () {
                    Navigator.pop(context); // đóng bottom sheet
                    context.go('/home'); // chuyển về trang home
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Lỗi'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Đóng'),
              ),
            ],
          ),
    );
  }
}
