import 'dart:convert';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart' as http;

class VideoService {
  final String apiKey = 'AIzaSyAttQv0Vi0brtwO-czgCBpZ0HEXeLZTqJk';
  final String baseUrl = 'https://www.googleapis.com/youtube/v3/search';

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
      throw Exception('Failed to load videos');
    }
  }
}
