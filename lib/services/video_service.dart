import 'dart:convert';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart' as http;

class VideoService {
  final String apiKey = 'AIzaSyAttQv0Vi0brtwO-czgCBpZ0HEXeLZTqJk';
  final String baseUrl = 'https://www.googleapis.com/youtube/v3/search';
  final String commentsUrl = 'https://www.googleapis.com/youtube/v3/commentThreads';

  late final CacheManager cacheManager;
  String? nextPageToken;

  VideoService() {
    cacheManager = CacheManager(
      Config(
        'videoCache',
        maxNrOfCacheObjects: 10,
        stalePeriod: const Duration(hours: 1),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> getNewsVideos({
    bool loadMore = false,
  }) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl?part=snippet&q=tin+tức+việt+nam&type=video&maxResults=10'
        '&order=date&videoLicense=creativeCommon&key=$apiKey'
        '${nextPageToken != null ? '&pageToken=$nextPageToken' : ''}',
      ),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      nextPageToken = data['nextPageToken'];
      final items = data['items'] as List<dynamic>;
      return List<Map<String, dynamic>>.from(items);
    } else {
      throw Exception('Failed to load videos: ${response.statusCode} - ${response.body}');
    }
  }

  Future<List<Map<String, dynamic>>> getVideoComments(String videoId) async {
    final response = await http.get(
      Uri.parse(
        '$commentsUrl?part=snippet&videoId=$videoId&maxResults=50&key=$apiKey',
      ),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final items = data['items'] as List<dynamic>;
      return List<Map<String, dynamic>>.from(items);
    } else {
      throw Exception('Failed to load comments: ${response.statusCode} - ${response.body}');
    }
  }

  Future<Map<String, dynamic>> postComment(
  String videoId,
  String comment,
  String accessToken,
) async {
  final response = await http.post(
    Uri.parse('$commentsUrl?part=snippet'),
    headers: {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
    body: jsonEncode({
      'snippet': {
        'videoId': videoId,
        'topLevelComment': {
          'snippet': {
            'textOriginal': comment,
          },
        },
      },
    }),
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    print('Comment posted successfully: ${response.body}');
    return jsonDecode(response.body);
  } else {
    print('Error posting comment: Status ${response.statusCode}, Body: ${response.body}');
    throw Exception('Failed to post comment: ${response.statusCode} - ${response.body}');
  }
}
Future<bool> isCommentAllowed(String videoId) async {
  final response = await http.get(
    Uri.parse('https://www.googleapis.com/youtube/v3/videos?part=status&id=$videoId&key=$apiKey'),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    if (data['items'] != null && data['items'].isNotEmpty) {
      final video = data['items'][0];
      final status = video['status'];
      if (status != null && status.containsKey('commentAllowed')) {
        return status['commentAllowed'];
      } else {
        return true; // Giả định bình luận được bật nếu không có field
      }
    }
    return false;
  } else {
    print('Error checking comment status: Status ${response.statusCode}, Body: ${response.body}');
    return false;
  }
}
}