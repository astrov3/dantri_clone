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

  // Thêm biến để lưu trữ bình luận từ API
  Map<String, List<Map<String, dynamic>>> apiComments = {};
  Map<String, bool> isLoadingComments = {};

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
  List<Map<String, dynamic>> getComments(String videoId) {
    return apiComments[videoId] ?? [];
  }

  // Phương thức để lấy bình luận từ API
  Future<void> fetchComments(String videoId) async {
    if (isLoadingComments[videoId] == true) return;

    isLoadingComments[videoId] = true;
    notifyListeners();

    try {
      final comments = await videoService.getVideoComments(videoId);
      apiComments[videoId] = comments;
    } catch (e) {
      print('Error fetching comments: $e');
    } finally {
      isLoadingComments[videoId] = false;
      notifyListeners();
    }
  }

  // Phương thức để lấy bình luận
  List<Map<String, dynamic>> getCommentsFromApi(String videoId) {
    return apiComments[videoId] ?? [];
  }

  // Phương thức để thêm bình luận mới
  Future<void> addCommentFromApi(String videoId, String comment) async {
    try {
      final newComment = await videoService.postComment(videoId, comment);

      if (!apiComments.containsKey(videoId)) {
        apiComments[videoId] = [];
      }

      // Add the new comment to the list
      apiComments[videoId]!.insert(0, newComment);
      notifyListeners();
    } catch (e) {
      print('Error posting comment: $e');
      // You might want to show an error message to the user here
    }
  }
}
