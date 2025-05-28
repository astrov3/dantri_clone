import 'package:flutter/material.dart';
import '../services/video_service.dart';
import 'package:google_sign_in/google_sign_in.dart';

class VideoViewModel extends ChangeNotifier {
  List<Map<String, dynamic>> videos = [];
  final VideoService videoService = VideoService();
  bool isLoading = false;
  bool showCaptions = false;
  bool isFetchingMore = false;
  Set<String> likedVideos = {};
  Map<String, List<String>> videoComments = {};
  Map<String, List<Map<String, dynamic>>> apiComments = {};
  Map<String, bool> isLoadingComments = {};

  Future<String?> signInWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn(
      scopes: ['https://www.googleapis.com/auth/youtube.force-ssl'],
    );
    try {
      final account = await googleSignIn.signIn();
      final auth = await account?.authentication;
      print('Access Token: ${auth?.accessToken}');
      print('Requested Scopes: ${googleSignIn.scopes}');
      return auth?.accessToken;
    } catch (e) {
      print('Error signing in: $e');
      return null;
    }
  }
//  Lấy danh sách video 
  void fetchVideos() async {
    isLoading = true;
    notifyListeners();

    try {
      videos = await videoService.getNewsVideos();
    } catch (e) {
      print('Error fetching videos: $e');
    }

    isLoading = false;
    notifyListeners();
  }
  // Lấy thêm video khi người dùng cuộn xuống

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

  void toggleLike(String videoId) {
    if (likedVideos.contains(videoId)) {
      likedVideos.remove(videoId);
    } else {
      likedVideos.add(videoId);
    }
    notifyListeners();
  }

  bool isVideoLiked(String videoId) {
    return likedVideos.contains(videoId);
  }
  // Thêm bình luận vào danh sách cục bộ

  void addComment(String videoId, String comment) {
    if (!videoComments.containsKey(videoId)) {
      videoComments[videoId] = [];
    }
    videoComments[videoId]!.add(comment);
    notifyListeners();
  }

  // Lấy bình luận từ danh sách cục bộ
  List<Map<String, dynamic>> getComments(String videoId) {
    return apiComments[videoId] ?? [];
  }

  // Gọi API để lấy comment video
  Future<void> fetchComments(String videoId, {bool forceRefresh = false}) async {
    // If already loading and not forcing refresh, return
    if (isLoadingComments[videoId] == true && !forceRefresh) return;

    isLoadingComments[videoId] = true;
    notifyListeners();

    try {
      print('Fetching comments for video: $videoId');
      final comments = await videoService.getVideoComments(videoId);
      print('Received ${comments.length} comments for video: $videoId');
      
      apiComments[videoId] = comments;
      
      // Force notify listeners after updating comments
      isLoadingComments[videoId] = false;
      notifyListeners();
      
    } catch (e) {
      print('Error fetching comments: $e');
      isLoadingComments[videoId] = false;
      notifyListeners();
    }
  }

  // Clear comments cache for a specific video
  void clearCommentsCache(String videoId) {
    apiComments.remove(videoId);
    isLoadingComments.remove(videoId);
    print('Cleared comments cache for video: $videoId');
    notifyListeners();
  }

  // Improved addCommentFromApi with better error handling and refresh
  Future<void> addCommentFromApi(String videoId, String comment) async {
    try {
      final accessToken = await signInWithGoogle();
      if (accessToken == null) {
        throw Exception('Vui lòng đăng nhập để gửi bình luận');
      }

      print('Posting comment to video: $videoId');
      // Gửi bình luận lên API
      await videoService.postComment(videoId, comment, accessToken);
      print('Comment posted successfully');

      // Clear cache trước khi fetch lại
      clearCommentsCache(videoId);
      
      // Đợi một chút để YouTube xử lý
      await Future.delayed(const Duration(milliseconds: 1000));
      
      // Force refresh comments
      await fetchComments(videoId, forceRefresh: true);
      
      print('Comments refreshed after posting');
      
    } catch (e, stack) {
      print('Error sending comment: $e\n$stack');
      rethrow;
    }
  }

  // Method để refresh comments manually
  Future<void> refreshComments(String videoId) async {
    clearCommentsCache(videoId);  
    await fetchComments(videoId, forceRefresh: true);
  }

  // Get comment count for display
  int getCommentCount(String videoId) {
    return apiComments[videoId]?.length ?? 0;
  }

  // Check if comments are loading
  bool isCommentsLoading(String videoId) {
    return isLoadingComments[videoId] ?? false;
  }

  void addLocalComment(String videoId, Map<String, dynamic> comment) {
    if (apiComments[videoId] == null) {
      apiComments[videoId] = [];
    }
    apiComments[videoId]!.insert(0, comment);
    notifyListeners();
  }
}