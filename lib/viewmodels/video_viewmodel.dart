import 'package:flutter/material.dart';
import '../services/video_service.dart';

class VideoViewModel extends ChangeNotifier {
  List<Map<String, dynamic>> videos = [];
  final VideoService videoService = VideoService();
  bool isLoading = false;
  bool showCaptions = false;
  bool isFetchingMore = false;

  // Danh sách lưu video yêu thích (lưu videoId)
  Set<String> likedVideos = {};

  // Danh sách bình luận cho mỗi video (key: videoId, value: danh sách bình luận)
  Map<String, List<String>> videoComments = {};

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

  // Thêm hoặc xóa video khỏi danh sách yêu thích
  void toggleLike(String videoId) {
    if (likedVideos.contains(videoId)) {
      likedVideos.remove(videoId);
    } else {
      likedVideos.add(videoId);
    }
    notifyListeners();
  }

  // Kiểm tra xem video có được thích hay không
  bool isVideoLiked(String videoId) {
    return likedVideos.contains(videoId);
  }

  // =================== COMMENT ===================

  // Thêm bình luận cho video
  void addComment(String videoId, String comment) {
    if (!videoComments.containsKey(videoId)) {
      videoComments[videoId] = [];
    }
    videoComments[videoId]!.add(comment);
    notifyListeners();
  }

  // Lấy danh sách bình luận cho video
  List<String> getComments(String videoId) {
    return videoComments[videoId] ?? [];
  }
}
