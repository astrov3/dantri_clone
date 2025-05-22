import 'package:dantri_clone/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

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
                backgroundColor: Colors.transparent,
                foregroundImage: NetworkImage(user.photoURL!),
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
                    await _authService.signOut();
                    Navigator.of(context).pop();
                    context.go('/home');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: Colors.red),
                  title: const Text(
                    'Xoá tài khoản',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _showDeleteAccountConfirmation(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.cancel),
                  title: const Text('Hủy'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeleteAccountConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text(
              'Xác nhận xóa tài khoản',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bạn có chắc chắn muốn xóa tài khoản không?',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Hành động này sẽ:',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                const Text('• Xóa vĩnh viễn tài khoản của bạn'),
                const Text('• Xóa tất cả dữ liệu cá nhân'),
                const Text('• Không thể khôi phục sau khi xóa'),
                const SizedBox(height: 16),
                const Text(
                  'Bạn có muốn tiếp tục không?',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _handleDeleteAccount();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Xóa tài khoản'),
              ),
            ],
          ),
    );
  }

  void _handleDeleteAccount() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Hiển thị loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final bool success = await _authService.deleteAccount();

      // Đóng loading dialog
      Navigator.of(context).pop();

      if (success) {
        _showSuccessDialog('Tài khoản đã được xóa thành công.');
      } else {
        _showErrorDialog('Không thể xóa tài khoản. Vui lòng thử lại.');
      }
    } on FirebaseAuthException catch (e) {
      // Đóng loading dialog
      Navigator.of(context).pop();

      if (e.code == 'requires-recent-login') {
        _showReauthenticationDialog();
      } else {
        _showErrorDialog(e.message ?? 'Xóa tài khoản thất bại.');
      }
    } catch (e) {
      // Đóng loading dialog
      Navigator.of(context).pop();
      _showErrorDialog('Có lỗi xảy ra. Vui lòng thử lại.');
    }
  }

  void _showReauthenticationDialog() {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Kiểm tra xem user đăng nhập bằng Google hay email/password
    bool isGoogleUser = user.providerData.any(
      (info) => info.providerId == 'google.com',
    );

    if (isGoogleUser) {
      _showGoogleReauthDialog();
    } else {
      _showPasswordReauthDialog();
    }
  }

  void _showGoogleReauthDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Xác thực lại'),
            content: const Text(
              'Để xóa tài khoản, bạn cần đăng nhập lại với Google để xác nhận.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).pop();

                  final bool success =
                      await _authService.reauthenticateWithGoogle();
                  if (success) {
                    _handleDeleteAccount();
                  } else {
                    _showErrorDialog('Xác thực thất bại. Vui lòng thử lại.');
                  }
                },
                child: const Text('Đăng nhập lại'),
              ),
            ],
          ),
    );
  }

  void _showPasswordReauthDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Xác thực lại'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Vui lòng nhập mật khẩu để xác nhận xóa tài khoản:'),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Mật khẩu',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  _passwordController.clear();
                  Navigator.of(context).pop();
                },
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_passwordController.text.isEmpty) {
                    _showErrorDialog('Vui lòng nhập mật khẩu.');
                    return;
                  }

                  Navigator.of(context).pop();

                  final bool success = await _authService.reauthenticateUser(
                    _passwordController.text,
                  );
                  _passwordController.clear();

                  if (success) {
                    _handleDeleteAccount();
                  } else {
                    _showErrorDialog('Mật khẩu không đúng. Vui lòng thử lại.');
                  }
                },
                child: const Text('Xác nhận'),
              ),
            ],
          ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
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

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Text('Thành công'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.go('/home');
                },
                child: const Text('Đóng'),
              ),
            ],
          ),
    );
  }
}
// Note: Ensure that the AuthService class has the method reauthenticateWithGoogle
// implemented to handle Google re-authentication.