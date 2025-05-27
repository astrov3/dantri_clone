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
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  String? _gender;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _displayNameController.text = user?.displayName ?? '';
    _gender = null;
    if (user != null) {
      _authService.getUserProfileFirestore(user.uid).then((profile) {
        if (profile != null) {
          setState(() {
            _dobController.text = profile['dob'] ?? '';
            _gender = profile['gender'];
            _phoneController.text = profile['phone'] ?? '';
            _locationController.text = profile['location'] ?? '';
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _displayNameController.dispose();
    _dobController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
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
        title: const Text('Thông tin tài khoản'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              _showOptions(context);
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.grey[200],
                          child:
                              user.photoURL != null
                                  ? ClipOval(
                                    child: Image.network(
                                      user.photoURL!,
                                      width: 120,
                                      height: 120,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                  : Text(
                                    (user.displayName != null &&
                                            user.displayName!.isNotEmpty)
                                        ? user.displayName!
                                            .split(' ')
                                            .map((e) => e[0])
                                            .take(2)
                                            .join()
                                            .toUpperCase()
                                        : '',
                                    style: const TextStyle(
                                      fontSize: 40,
                                      color: Colors.black54,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user.displayName ?? 'Chưa cập nhật tên',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      user.email ?? '',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Form Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildFormField(
                      controller: _displayNameController,
                      label: 'Tên hiển thị',
                      icon: Icons.person,
                      isRequired: true,
                    ),
                    const SizedBox(height: 16),
                    _buildFormField(
                      initialValue: user.email,
                      label: 'Email',
                      icon: Icons.email,
                      isRequired: true,
                      enabled: false,
                    ),
                    const SizedBox(height: 16),
                    _buildFormField(
                      controller: _dobController,
                      label: 'Ngày sinh',
                      icon: Icons.calendar_today,
                      onTap: () async {
                        FocusScope.of(context).requestFocus(FocusNode());
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime(2000, 1, 1),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          _dobController.text =
                              "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildDropdownField(
                      value: _gender,
                      label: 'Giới tính',
                      icon: Icons.people,
                      items: const [
                        DropdownMenuItem(value: 'Nam', child: Text('Nam')),
                        DropdownMenuItem(value: 'Nữ', child: Text('Nữ')),
                        DropdownMenuItem(value: 'Khác', child: Text('Khác')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _gender = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildFormField(
                      controller: _phoneController,
                      label: 'Số điện thoại',
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    _buildFormField(
                      controller: _locationController,
                      label: 'Địa phương',
                      icon: Icons.location_on,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      await user.updateDisplayName(
                        _displayNameController.text.trim(),
                      );
                      await user.reload();
                      await _authService.updateUserProfileFirestore(user.uid, {
                        'dob': _dobController.text.trim(),
                        'gender': _gender,
                        'phone': _phoneController.text.trim(),
                        'location': _locationController.text.trim(),
                      });
                      setState(() {});
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Cập nhật thành công!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Cập nhật thất bại: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    'Cập nhật',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Dân trí cam kết bảo mật thông tin của bạn.',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormField({
    TextEditingController? controller,
    String? initialValue,
    required String label,
    required IconData icon,
    bool isRequired = false,
    bool enabled = true,
    TextInputType? keyboardType,
    VoidCallback? onTap,
  }) {
    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      enabled: enabled,
      keyboardType: keyboardType,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label + (isRequired ? ' (*)' : ''),
        prefixIcon: Icon(icon, color: Colors.grey[600]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey[100],
      ),
    );
  }

  Widget _buildDropdownField({
    required String? value,
    required String label,
    required IconData icon,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey[600]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      items: items,
      onChanged: onChanged,
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