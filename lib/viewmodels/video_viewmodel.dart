import 'package:flutter/material.dart';
import '../services/video_service.dart';

class VideoViewModel extends ChangeNotifier {
  List<Map<String, dynamic>> videos = [];
  final VideoService videoService = VideoService();
  bool isLoading = false;
  bool showCaptions = false;
  bool isFetchingMore = false;

  void fetchVideos() async {
    isLoading = true;
    notifyListeners();

    try {
      videos = await videoService.getNewsVideos();
    } catch (e) {
      print('Error: $e');
    }

    isLoading = false;
    notifyListeners();
  }

  void fetchMoreVideos() async {
    if (isFetchingMore) return;

    isFetchingMore = true;
    try {
      final moreVideos = await videoService.getNewsVideos(loadMore: true);
      videos.addAll(moreVideos);
      notifyListeners();
    } catch (e) {
      print('Load more error: $e');
    } finally {
      isFetchingMore = false;
    }
  }

  void toggleCaptions() {
    showCaptions = !showCaptions;
    notifyListeners();
  }
}
