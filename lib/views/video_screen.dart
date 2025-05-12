import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../viewmodels/video_viewmodel.dart';

class VideoScreen extends StatefulWidget {
  const VideoScreen({super.key});

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => VideoViewModel()..fetchVideos(),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Consumer<VideoViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return Scaffold(
              backgroundColor: Colors.white,
              body: SafeArea(
                child: PageView.builder(
                  controller: _pageController,
                  pageSnapping: true,
                  physics: const PageScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  onPageChanged: (index) {
                    // Tự động load thêm nếu còn dữ liệu và đang gần cuối danh sách
                    if (!viewModel.isLoading &&
                        index >= viewModel.videos.length - 2) {
                      viewModel.fetchMoreVideos();
                    }
                  },
                  itemCount: viewModel.videos.length,
                  itemBuilder: (context, index) {
                    var video = viewModel.videos[index];
                    String videoId = video['id']['videoId'];
                    String title = video['snippet']['title'];
                    // String description = video['snippet']['description'];
                    String channelTitle = video['snippet']['channelTitle'];

                    return Stack(
                      children: [
                        // Blurred background
                        Positioned.fill(
                          child: ImageFiltered(
                            imageFilter: ImageFilter.blur(
                              sigmaX: 15,
                              sigmaY: 15,
                              tileMode: TileMode.mirror,
                            ),

                            child: Image.network(
                              video['snippet']['thumbnails']['high']['url'],
                              fit: BoxFit.fill,
                              loadingBuilder: (
                                context,
                                child,
                                loadingProgress,
                              ) {
                                if (loadingProgress == null) return child;
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              },
                              errorBuilder:
                                  (context, error, stackTrace) => const Center(
                                    child: Icon(
                                      Icons.broken_image,
                                      size: 50,
                                      color: Colors.grey,
                                    ),
                                  ),
                            ),
                          ),
                        ),
                        // Video Player Fullscreen
                        YoutubePlayerBuilder(
                          player: YoutubePlayer(
                            controller: YoutubePlayerController(
                              initialVideoId: videoId,
                              flags: const YoutubePlayerFlags(
                                autoPlay: true,
                                mute: false,
                                enableCaption: false,
                                loop: true,
                                forceHD: true,
                                useHybridComposition: true,
                              ),
                            ),
                            showVideoProgressIndicator: true,
                            thumbnail: Positioned.fill(
                              child: Image.network(
                                video['snippet']['thumbnails']['high']['url'],
                                fit: BoxFit.cover,
                                loadingBuilder: (
                                  context,
                                  child,
                                  loadingProgress,
                                ) {
                                  if (loadingProgress == null) return child;
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                },
                                errorBuilder:
                                    (context, error, stackTrace) =>
                                        const Center(
                                          child: Icon(
                                            Icons.broken_image,
                                            size: 50,
                                            color: Colors.grey,
                                          ),
                                        ),
                              ),
                            ),
                          ),
                          builder: (context, player) {
                            return Center(
                              child: AspectRatio(
                                aspectRatio: 16 / 9,
                                child: player,
                              ),
                            );
                          },
                        ),

                        // Action buttons
                        Positioned(
                          right: 16,
                          bottom: 100,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.favorite_border,
                                color: Colors.white,
                                size: 32,
                              ),
                              const SizedBox(height: 16),
                              const Icon(
                                Icons.comment,
                                color: Colors.white,
                                size: 32,
                              ),
                              const SizedBox(height: 16),
                              const Icon(
                                Icons.share,
                                color: Colors.white,
                                size: 32,
                              ),
                              const SizedBox(height: 16),
                              IconButton(
                                icon: Icon(
                                  viewModel.showCaptions
                                      ? Icons.closed_caption
                                      : Icons.closed_caption_disabled,
                                  color: Colors.white,
                                  size: 32,
                                ),
                                onPressed: viewModel.toggleCaptions,
                              ),
                            ],
                          ),
                        ),

                        // Video title and channel info
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
                                  fontStyle: FontStyle.italic,
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
                              const SizedBox(height: 4),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
