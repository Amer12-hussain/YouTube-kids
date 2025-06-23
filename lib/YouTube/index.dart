import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:youtube_kids/YoutubePlayerScreen/ShortsFeedScreen.dart';

Future<Map<String, dynamic>> fetchKidsShortsByPage(int pageNumber) async {
  String? pageToken;
  Map<String, dynamic>? lastResult;
  for (int i = 0; i < pageNumber; i++) {
    lastResult = await fetchKidsShorts(pageToken: pageToken);
    pageToken = lastResult['nextPageToken'];
    if (pageToken == null) break; // Reached end of pages
  }
  return lastResult!;
}

Future<Map<String, dynamic>> fetchKidsShorts({String? pageToken}) async {
  const String apiKey = 'AIzaSyD4QG7mkX0OohnfFTsr70CMUzMNzU0vF30';
  const String query = 'kids cartoon shorts';
  final url = Uri.parse(
    'https://www.googleapis.com/youtube/v3/search?part=snippet&q=$query&type=video&videoDuration=short&maxResults=10${pageToken != null ? '&pageToken=$pageToken' : ''}&key=$apiKey',
  );
  final response = await http.get(url);
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final List items = data['items'];
    final videos = items.map((item) {
      return {
        'videoId': item['id']['videoId'],
        'title': item['snippet']['title'],
        'thumbnail': item['snippet']['thumbnails']['high']['url'],
      };
    }).toList();
    return {'videos': videos, 'nextPageToken': data['nextPageToken']};
  } else {
    throw Exception('Failed to load YouTube Shorts');
  }
}

class ShortsList extends StatefulWidget {
  const ShortsList({super.key});
  @override
  State<ShortsList> createState() => _ShortsListState();
}

class _ShortsListState extends State<ShortsList> {
  late Future<Map<String, dynamic>> _future;
  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    _future = fetchKidsShorts();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading videos'));
        }
        final result = snapshot.data as Map<String, dynamic>;
        final videos = List<Map<String, dynamic>>.from(result['videos']);
        return ListView.builder(
          controller: _scrollController,
          itemCount: videos.length,
          itemBuilder: (context, index) {
            final video = videos[index];
            return ListTile(
              leading: Image.network(video['thumbnail'], width: 100),
              title: Text(video['title']),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ShortsFeedScreen(
                      initialVideos: videos,
                      initialPageToken: result['nextPageToken'],
                      initialIndex: index,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
