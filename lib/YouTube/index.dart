import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_kids/YoutubePlayerScreen/index.dart';

Future<List<Map<String, dynamic>>> fetchKidsShorts() async {
  const String apiKey = 'AIzaSyCk842MyJQwbD26IsSmCIZQ_C2t0b3QPkc';
  const String query = 'kids cartoon shorts';
  final url = Uri.parse(
    'https://www.googleapis.com/youtube/v3/search?part=snippet&q=$query&type=video&videoDuration=short&maxResults=10&key=$apiKey',
  );
  final response = await http.get(url);
  print('YouTube API Response: ${response.body}');
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final List items = data['items'];
    return items.map((item) {
      return {
        'videoId': item['id']['videoId'],
        'title': item['snippet']['title'],
        'thumbnail': item['snippet']['thumbnails']['high']['url'],
      };
    }).toList();
  } else {
    throw Exception('Failed to load YouTube Shorts');
  }
}

class ShortsList extends StatelessWidget {
  const ShortsList({super.key});
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetchKidsShorts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading videos'));
        }
        final videos = snapshot.data!;
        return ListView.builder(
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
                    builder: (_) => YouTubePlayerScreen(
                      videoId: video['videoId'],
                      channelTitle:
                          video['title'], // You can use video['channelTitle'] if available
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
