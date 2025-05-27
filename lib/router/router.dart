import 'package:dantri_clone/viewmodels/news_viewmodel.dart';
import 'package:dantri_clone/views/category_screen.dart';
import 'package:dantri_clone/views/comment_screen.dart';
import 'package:dantri_clone/views/dantri_ai_screen.dart';
import 'package:dantri_clone/views/detail_screen.dart';
import 'package:dantri_clone/views/home_screen.dart';
import 'package:dantri_clone/views/layout.dart';
import 'package:dantri_clone/views/login_screen.dart';
import 'package:dantri_clone/views/notifications_screen.dart';
import 'package:dantri_clone/views/profile_screen.dart';
import 'package:dantri_clone/views/register_screen.dart';
import 'package:dantri_clone/views/utility_screen.dart';
import 'package:dantri_clone/views/video_screen.dart';
import 'package:dantri_clone/widgets/heath_care_chatbot_widget.dart';
import 'package:dantri_clone/widgets/news_24h_widget.dart';
import 'package:dantri_clone/widgets/traffic_law_chatbot_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/healthcare_chat_provider.dart';
import '../providers/traffic_law_chat_provider.dart';
import '../viewmodels/category_viewmodel.dart';
import '../viewmodels/video_viewmodel.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/home',
    debugLogDiagnostics: true,
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // ShellRoute giữ Layout cố định (nav bar)
      ShellRoute(
        builder: (context, state, child) => Layout(child: child),
        routes: [
          GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/category',
            builder:
                (context, state) => ChangeNotifierProvider(
                  create: (_) => CategoryViewModel(),
                  child: const CategoryScreen(),
                ),
          ),
          GoRoute(
            path: '/video',
            builder:
                (context, state) => ChangeNotifierProvider(
                  create: (_) => VideoViewModel()..fetchVideos(),
                  child: const VideoScreen(),
                ),
          ),
          GoRoute(
            path: '/dantri-ai',
            builder: (context, state) => const DantriAIScreen(),
          ),
          GoRoute(
            path: '/utility',
            builder: (context, state) => const UtilityScreen(),
          ),
        ],
      ),
      // Các route không nằm trong ShellRoute
      GoRoute(
        path: '/dantri-ai/news-24h',
        builder:
            (context, state) => ChangeNotifierProvider(
              create: (_) => NewsViewModel()..fetchNews(),
              child: const News24hWidget(),
            ),
      ),
      GoRoute(
        path: '/dantri-ai/traffic-law',
        builder:
            (context, state) => ChangeNotifierProvider(
              create: (_) => TrafficLawChatProvider(),
              child: const TrafficLawChatbotWidget(),
            ),
      ),
      GoRoute(
        path: '/dantri-ai/health-care',
        builder:
            (context, state) => ChangeNotifierProvider(
              create: (_) => HealthCareChatProvider(),
              child: const HeathCareChatbotWidget(),
            ),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/detail',
        builder:
            (context, state) =>
                DetailScreen(item: state.extra as Map<String, String>),
      ),
      GoRoute(
        path: '/comment',
        builder: (context, state) {
          final params = state.extra as Map<String, dynamic>;
          return ChangeNotifierProvider(
            create: (_) => VideoViewModel()..fetchComments(params['videoId']),
            child: CommentScreen(
              videoId: params['videoId'],
              videoTitle: params['videoTitle'],
              channelTitle: params['channelTitle'],
              currentUserName: params['currentUserName'],
              currentUserAvatar: params['currentUserAvatar'],
            ),
          );
        },
      ),
    ],
  );
}
