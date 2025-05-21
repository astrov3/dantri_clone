import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../viewmodels/video_viewmodel.dart';
import 'comment_screen.dart';
class VideoScreen extends StatefulWidget {
  const VideoScreen({super.key});

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class CommentDialog extends StatelessWidget {
  final String videoId;
  final String channelTitle;
  final VideoViewModel viewModel;

  const CommentDialog({
    super.key,
    required this.videoId,
    required this.channelTitle,
    required this.viewModel,
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
            ...comments.map((c) => ListTile(title: Text(c))),
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

class _VideoScreenState extends State<VideoScreen> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

/// Show comment screen class
 void _showCommentScreen(
  BuildContext context,
  String videoId,
  String channelTitle,
  String videoTitle, // Thêm tham số videoTitle
  VideoViewModel viewModel,
) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => CommentScreen(
        videoId: videoId,
        videoTitle: videoTitle, // Truyền videoTitle
        channelTitle: channelTitle,
        viewModel: viewModel,
      ),
    ),
  );
}
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => VideoViewModel()..fetchVideos(),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Consumer<VideoViewModel>(
          builder: (context, viewModel, _) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return SafeArea(
              child: PageView.builder(
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
                  List<String> comments = viewModel.getComments(videoId);

                  return Stack(
                    children: [
                      // Background blur
                      Positioned.fill(
                        child: ImageFiltered(
                          imageFilter: ImageFilter.blur(
                            sigmaX: 15,
                            sigmaY: 15,
                          ),
                          child: Image.network(
                            video['snippet']['thumbnails']['high']['url'],
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Center(
                              child: Icon(Icons.broken_image,
                                  size: 50, color: Colors.grey),
                            ),
                          ),
                        ),
                      ),

                      // Video player
                      YoutubePlayerBuilder(
                        player: YoutubePlayer(
                          controller: YoutubePlayerController(
                            initialVideoId: videoId,
                            flags: const YoutubePlayerFlags(
                              autoPlay: true,
                              mute: false,
                              loop: true,
                              useHybridComposition: true,
                            ),
                          ),
                          showVideoProgressIndicator: true,
                        ),
                        builder: (_, player) => Center(
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: player,
                          ),
                        ),
                      ),

                      // Right buttons
                      Positioned(
                        right: 16,
                        bottom: 100,
                        child: Column(
                          children: [
                            IconButton(
                              icon: Icon(
                                viewModel.isVideoLiked(videoId)
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: viewModel.isVideoLiked(videoId) ? Colors.red : Colors.white,
                                size: 32,
                              ),
                              onPressed: () {
                                viewModel.toggleLike(videoId);
                              },
                            ),
                            const SizedBox(height: 16),
                            IconButton(
                              icon: Badge(
                                label: comments.isEmpty
                                    ? null
                                    : Text(comments.length.toString()),
                                child: const Icon(Icons.comment,
                                    color: Colors.white, size: 32),
                              ),
                           onPressed: () => _showCommentScreen(
                              context, 
                              videoId, 
                              channelTitle, 
                              title, // Truyền title vào đây
                              viewModel
                            ),
                            ),
                            const SizedBox(height: 16),
                            const Icon(Icons.share,
                                color: Colors.white, size: 32),
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
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              title,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
