import 'package:dantri_clone/views/notifications_screen.dart';
import 'package:dantri_clone/views/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:dantri_clone/views/layout.dart';
import 'package:dantri_clone/views/login_screen.dart';
import 'package:dantri_clone/views/home_screen.dart';
import 'package:dantri_clone/views/category_screen.dart';
import 'package:dantri_clone/views/video_screen.dart';
import 'package:dantri_clone/views/chatbot_screen.dart';
import 'package:dantri_clone/views/utility_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/home',
    // redirect: (BuildContext context, GoRouterState state) {
    //   final isAuthenticated = FirebaseAuth.instance.currentUser != null;

    //   if (!isAuthenticated && state.matchedLocation != '/login') {
    //     return '/login';
    //   }

    //   if (isAuthenticated && state.matchedLocation == '/login') {
    //     return '/home';
    //   }

    //   return null;
    // },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      // ShellRoute giữ Layout cố định (nav bar)
      ShellRoute(
        builder: (context, state, child) => Layout(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/category',
            builder: (context, state) => const CategoryScreen(),
          ),
          GoRoute(
            path: '/video',
            builder: (context, state) => const VideoScreen(),
          ),
          GoRoute(
            path: '/chatbot',
            builder: (context, state) => const ChatbotScreen(),
          ),
          GoRoute(
            path: '/utility',
            builder: (context, state) => const UtilityScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
    ],
  );
}
