import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class Layout extends StatefulWidget {
  final Widget child;
  const Layout({super.key, required this.child});

  @override
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  int _selectedIndex = 0;
  DateTime? _lastBackPressed;

  final List<String> _routes = [
    '/home',
    '/category',
    '/video',
    '/dantri-ai',
    '/utility',
  ];

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      context.go(_routes[index]);
      setState(() {
        _selectedIndex = index;
      });
    }
    if (_selectedIndex != index) {
      context.go(_routes[index]);
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final location = GoRouterState.of(context).matchedLocation;
    _selectedIndex = _routes.indexWhere((r) => location.startsWith(r));
    if (_selectedIndex == -1) _selectedIndex = 0;
  }

  Future<bool> _onWillPop() async {
    if (_lastBackPressed == null ||
        DateTime.now().difference(_lastBackPressed!) >
            const Duration(seconds: 2)) {
      _lastBackPressed = DateTime.now();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Nhấn back lần nữa để thoát',
            style: TextStyle(color: Colors.white),
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(10),
        ),
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final isVideoRoute = _selectedIndex == 2;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    // Set system UI overlay style based on route
    SystemChrome.setSystemUIOverlayStyle(
      isVideoRoute
          ? const SystemUiOverlayStyle(
            statusBarColor: Colors.black,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
            systemNavigationBarColor: Colors.black,
            systemNavigationBarDividerColor: Colors.transparent,
            systemNavigationBarIconBrightness: Brightness.light,
            systemNavigationBarContrastEnforced: false,
          )
          : const SystemUiOverlayStyle(
            statusBarColor: Colors.white,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
            systemNavigationBarColor: Colors.white,
            systemNavigationBarDividerColor: Colors.transparent,
            systemNavigationBarIconBrightness: Brightness.dark,
            systemNavigationBarContrastEnforced: false,
          ),
    );

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: widget.child,
        bottomNavigationBar:
            isLandscape
                ? null
                : BottomNavigationBar(
                  backgroundColor: isVideoRoute ? Colors.black : Colors.white,
                  items: [
                    BottomNavigationBarItem(
                      icon: Icon(
                        _selectedIndex == 0 ? Icons.home : Icons.home_outlined,
                      ),
                      label: 'Trang Chủ',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(
                        _selectedIndex == 1
                            ? Icons.vibration
                            : Icons.vibration_outlined,
                      ),
                      label: 'Chuyên mục',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(
                        _selectedIndex == 2
                            ? Icons.video_collection
                            : Icons.video_collection_outlined,
                      ),
                      label: 'Video',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(
                        _selectedIndex == 3
                            ? Icons.smart_toy
                            : Icons.smart_toy_outlined,
                      ),
                      label: 'Chatbot',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(
                        _selectedIndex == 4
                            ? Icons.dashboard_customize
                            : Icons.dashboard_customize_outlined,
                      ),
                      label: 'Tiện ích',
                    ),
                  ],
                  currentIndex: _selectedIndex,
                  selectedItemColor: isVideoRoute ? Colors.white : Colors.green,
                  unselectedItemColor: isVideoRoute ? Colors.grey : Colors.grey,
                  onTap: _onItemTapped,
                  type: BottomNavigationBarType.fixed,
                ),
      ),
    );
  }
}
