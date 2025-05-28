import 'dart:convert';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart' as http;

// Lớp quản lý tương tác với YouTube Data API v3 để tìm kiếm video, lấy/đăng bình luận và kiểm tra trạng thái bình luận
class VideoService {
  // Khóa API YouTube
  final String apiKey = 'AIzaSyD3_h5wCcaPVkbhIcIH6HDTW2ybsOMzX2Y';
  // URL cơ bản để tìm kiếm video
  final String baseUrl = 'https://www.googleapis.com/youtube/v3/search';
  // URL để quản lý bình luận
  final String commentsUrl =
      'https://www.googleapis.com/youtube/v3/commentThreads';

  // Quản lý bộ nhớ đệm
  late final CacheManager cacheManager;
  // Token cho phân trang kết quả
  String? nextPageToken;

  // Constructor: Khởi tạo cacheManager với cấu hình bộ nhớ đệm
  VideoService() {
    cacheManager = CacheManager(
      Config(
        'videoCache',
        maxNrOfCacheObjects: 10, // Giới hạn 10 đối tượng
        stalePeriod: const Duration(hours: 1), // Lưu trữ 1 giờ
      ),
    );
  }

  // Lấy 10 video tin tức Việt Nam mới nhất, hỗ trợ tải thêm với nextPageToken
  Future<List<Map<String, dynamic>>> getNewsVideos({
    bool loadMore = false,
  }) async {
    // Gửi GET request với query tìm kiếm tin tức
    final response = await http.get(
      Uri.parse(
        '$baseUrl?part=snippet&q=tin+tức+việt+nam+mới+nhất+hôm+nay&type=video&maxResults=10'
        '&order=date&key=$apiKey'
        '${nextPageToken != null ? '&pageToken=$nextPageToken' : ''}',
      ),
    );
    // Xử lý phản hồi
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      nextPageToken = data['nextPageToken']; // Lưu token cho trang tiếp theo
      final items = data['items'] as List<dynamic>;
      return List<Map<String, dynamic>>.from(items); // Trả về danh sách video
    } else {
      // Ném lỗi nếu yêu cầu thất bại
      throw Exception(
        'Failed to load videos: ${response.statusCode} - ${response.body}',
      );
    }
  }

  // Tìm kiếm video dựa trên từ khóa, hỗ trợ bộ nhớ đệm khi vượt quota
  Future<List<Map<String, dynamic>>> searchVideos(String query) async {
    // Gửi GET request với từ khóa tìm kiếm
    final response = await http.get(
      Uri.parse(
        '$baseUrl?part=snippet&q=$query&type=video&maxResults=10&order=relevance&key=$apiKey'
        '${nextPageToken != null ? '&pageToken=$nextPageToken' : ''}',
      ),
    );

    // Xử lý lỗi quota (429)
    if (response.statusCode == 429) {
      // Thử lấy dữ liệu từ bộ nhớ đệm
      final cachedData = await cacheManager.getSingleFile(baseUrl);
      if (cachedData != null) {
        final data = jsonDecode(cachedData.readAsStringSync());
        nextPageToken = data['nextPageToken']; // Lưu token cho trang tiếp theo
        final items = data['items'] as List<dynamic>;
        return List<Map<String, dynamic>>.from(items); // Trả về danh sách video
      } else {
        // Ném lỗi nếu không có dữ liệu đệm
        throw Exception('Quota exceeded and no cached data available');
      }
    }

    // Xử lý phản hồi thành công
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      nextPageToken = data['nextPageToken']; // Lưu token cho trang tiếp theo
      final items = data['items'] as List<dynamic>;
      return List<Map<String, dynamic>>.from(items); // Trả về danh sách video
    } else {
      // Ném lỗi nếu yêu cầu thất bại
      throw Exception(
        'Failed to load videos: ${response.statusCode} - ${response.body}',
      );
    }
  }

  // Lấy 50 bình luận của video theo videoId
  Future<List<Map<String, dynamic>>> getVideoComments(String videoId) async {
    // Gửi GET request để lấy bình luận
    final response = await http.get(
      Uri.parse(
        '$commentsUrl?part=snippet&videoId=$videoId&maxResults=50&key=$apiKey',
      ),
    );

    // Xử lý phản hồi
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final items = data['items'] as List<dynamic>;
      return List<Map<String, dynamic>>.from(items); // Trả về danh sách bình luận
    } else {
      // Ném lỗi nếu yêu cầu thất bại
      throw Exception(
        'Failed to load comments: ${response.statusCode} - ${response.body}',
      );
    }
  }

  // Đăng bình luận lên video với accessToken xác thực
  Future<Map<String, dynamic>> postComment(
    String videoId,
    String comment,
    String accessToken,
  ) async {
    // Gửi POST request để đăng bình luận
    final response = await http.post(
      Uri.parse('$commentsUrl?part=snippet'),
      headers: {
        'Authorization': 'Bearer $accessToken', // Xác thực OAuth 2.0
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'snippet': {
          'videoId': videoId,
          'topLevelComment': {
            'snippet': {'textOriginal': comment},
          },
        },
      }),
    );

    // Xử lý phản hồi
    if (response.statusCode == 200 || response.statusCode == 201) {
      print('Comment posted successfully: ${response.body}');
      return jsonDecode(response.body); // Trả về dữ liệu bình luận
    } else {
      // In lỗi và ném ngoại lệ nếu thất bại
      print(
        'Error posting comment: Status ${response.statusCode}, Body: ${response.body}',
      );
      throw Exception(
        'Failed to post comment: ${response.statusCode} - ${response.body}',
      );
    }
  }

  // Kiểm tra xem video có cho phép bình luận hay không
  Future<bool> isCommentAllowed(String videoId) async {
    // Gửi GET request để lấy trạng thái video
    final response = await http.get(
      Uri.parse(
        'https://www.googleapis.com/youtube/v3/videos?part=status&id=$videoId&key=$apiKey',
      ),
    );

    // Xử lý phản hồi
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['items'] != null && data['items'].isNotEmpty) {
        final video = data['items'][0];
        final status = video['status'];
        if (status != null && status.containsKey('commentAllowed')) {
          return status['commentAllowed']; // Trả về trạng thái bình luận
        } else {
          return true; // Giả định cho phép bình luận nếu không có thông tin
        }
      }
      return false; // Trả về false nếu không có dữ liệu video
    } else {
      // In lỗi và trả về false nếu yêu cầu thất bại
      print(
        'Error checking comment status: Status ${response.statusCode}, Body: ${response.body}',
      );
      return false;
    }
  }
}