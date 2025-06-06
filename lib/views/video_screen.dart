import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../viewmodels/video_viewmodel.dart';

class VideoScreen extends StatefulWidget {
  const VideoScreen({super.key});

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class CommentDialog extends StatelessWidget {
  final String videoId;
  final String channelTitle;
  final VideoViewModel viewModel;
  final String currentUserName;

  const CommentDialog({
    super.key,
    required this.videoId,
    required this.channelTitle,
    required this.viewModel,
    required this.currentUserName,
  });

  @override
  Widget build(BuildContext context) {
    final comments = viewModel.getComments(videoId);
    final TextEditingController controller = TextEditingController();

    return AlertDialog(
      title: Text('Comments for @$channelTitle'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...comments.map(
              (c) => ListTile(title: Text(c['snippet']['textDisplay'])),
            ),
            TextField(
              controller: controller,
              decoration: const InputDecoration(hintText: 'Add a comment'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            final text = controller.text.trim();
            if (text.isNotEmpty) {
              viewModel.addComment(videoId, text);
            }
            Navigator.pop(context);
          },
          child: const Text("Submit"),
        ),
      ],
    );
  }
}

class _VideoScreenState extends State<VideoScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  late AnimationController _animationController;
  bool _isControlsVisible = true;
  YoutubePlayerController? _youtubeController;

  String currentUserName = "";
  String currentUserAvatar = "";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Lấy tên tài khoản từ Firebase Auth
    final user = FirebaseAuth.instance.currentUser;
    currentUserName = user?.displayName ?? user?.displayName ?? "Người dùng";
    currentUserAvatar =
        user?.photoURL ??
        "https://via.placeholder.com/40"; // Avatar mặc định nếu không có
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    _youtubeController?.dispose();
    super.dispose();
  }

  void _toggleControls() {
    setState(() {
      _isControlsVisible = !_isControlsVisible;
      if (_isControlsVisible) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  /// Show comment screen class
  void _showCommentScreen(
    BuildContext context,
    String videoId,
    String channelTitle,
    String videoTitle,
    VideoViewModel viewModel,
  ) {
    context.push(
      '/comment',
      extra: {
        'videoId': videoId,
        'channelTitle': channelTitle,
        'videoTitle': videoTitle,
        'viewModel': viewModel,
        'currentUserName': currentUserName,
        'currentUserAvatar': currentUserAvatar,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.black,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarContrastEnforced: false,
      ),
    );

    return ChangeNotifierProvider(
      create: (_) => VideoViewModel()..fetchVideos(),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Consumer<VideoViewModel>(
            builder: (context, viewModel, _) {
              if (viewModel.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.green),
                );
              }

              return PageView.builder(
                controller: _pageController,
                scrollDirection: Axis.vertical,
                itemCount: viewModel.videos.length,
                onPageChanged: (index) {
                  if (!viewModel.isLoading &&
                      index >= viewModel.videos.length - 2) {
                    viewModel.fetchMoreVideos();
                  }
                },
                itemBuilder: (context, index) {
                  var video = viewModel.videos[index];
                  String videoId = video['id']['videoId'];
                  String title = video['snippet']['title'];
                  String channelTitle = video['snippet']['channelTitle'];

                  return GestureDetector(
                    onTap: _toggleControls,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.black.withOpacity(0.3),
                                      Colors.black.withOpacity(0.7),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Video player
                        Center(
                          child: AspectRatio(
                            aspectRatio:
                                16 / 9, // Tỷ lệ mặc định cho video ngang
                            child: YoutubePlayerBuilder(
                              player: YoutubePlayer(
                                controller:
                                    _youtubeController ??
                                    YoutubePlayerController(
                                      initialVideoId: videoId,
                                      flags: const YoutubePlayerFlags(
                                        autoPlay: true,
                                        mute: false,
                                        loop: true,
                                        useHybridComposition: true,
                                        showLiveFullscreenButton: false,
                                        forceHD:
                                            true, // Thêm flag này để ưu tiên chất lượng HD
                                      ),
                                    ),
                                showVideoProgressIndicator: true,
                                progressColors: const ProgressBarColors(
                                  playedColor: Colors.green,
                                  handleColor: Colors.green,
                                ),
                                onEnded: (data) {
                                  // Handle video end
                                },
                                onReady: () {
                                  // Handle video ready
                                },
                              ),
                              builder:
                                  (_, player) => Container(
                                    color: Colors.black,
                                    child: Center(child: player),
                                  ),
                            ),
                          ),
                        ),

                        // Controls overlay
                        AnimatedOpacity(
                          opacity: _isControlsVisible ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 300),
                          child: Stack(
                            children: [
                              // Right buttons
                              Positioned(
                                right: 16,
                                bottom: 100,
                                child: Column(
                                  children: [
                                    _buildActionButton(
                                      icon:
                                          viewModel.isVideoLiked(videoId)
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                      color:
                                          viewModel.isVideoLiked(videoId)
                                              ? Colors.red
                                              : Colors.white,
                                      onTap:
                                          () => viewModel.toggleLike(videoId),
                                    ),
                                    const SizedBox(height: 16),
                                    _buildActionButton(
                                      icon: Icons.comment,
                                      onTap:
                                          () => _showCommentScreen(
                                            context,
                                            videoId,
                                            channelTitle,
                                            title,
                                            viewModel,
                                          ),
                                    ),
                                    const SizedBox(height: 16),
                                    _buildActionButton(
                                      icon: Icons.share,
                                      onTap: () {},
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                ),
                              ),

                              // Title + Channel
                              Positioned(
                                left: 16,
                                bottom: 30,
                                right: 80,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '@$channelTitle',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        shadows: [
                                          Shadow(
                                            offset: Offset(1, 1),
                                            blurRadius: 3,
                                            color: Colors.black45,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      title,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        shadows: [
                                          Shadow(
                                            offset: Offset(1, 1),
                                            blurRadius: 3,
                                            color: Colors.black45,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    Color color = Colors.white,
    String? badge,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black26,
          borderRadius: BorderRadius.circular(20),
        ),
        child:
            badge != null
                ? Badge(
                  label: Text(
                    badge,
                    style: const TextStyle(color: Colors.white),
                  ),
                  child: Icon(icon, color: color, size: 32),
                )
                : Icon(icon, color: color, size: 32),
      ),
    );
  }
}
