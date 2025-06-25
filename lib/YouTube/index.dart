import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_kids/YoutubePlayerScreen/ShortsFeedScreen.dart';

Future<Map<String, dynamic>> fetchKidsShorts({
  String? ageGroup,
  String? pageToken,
}) async {
  const String apiKey = 'AIzaSyD4QG7mkX0OohnfFTsr70CMUzMNzU0vF30';
  String query = 'kids cartoon shorts'; // default query
  // ✅ Query logic based on selected age group
  switch (ageGroup) {
    case '1-2':
      query = 'colorful nursery rhymes and baby cartoons for toddlers';
      break;
    case '3-4':
      query = 'fun learning videos and cartoons for preschool kids';
      break;
    case '5-6':
      query = 'kids science experiments and funny cartoons for 5 year olds';
      break;
    case '7-8':
      query = 'educational and adventure shorts for 7 to 8 year old children';
      break;
    case '9-10':
      query =
          'fun science facts and animated stories for 9 to 10 year old kids';
      break;
  }
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
  String? ageGroup;
  @override
  void initState() {
    super.initState();
    _loadAgeAndFetchVideos();
  }

  Future<void> _loadAgeAndFetchVideos() async {
    final prefs = await SharedPreferences.getInstance();
    ageGroup = prefs.getString('selectedAgeGroup') ?? '3-4'; // fallback age
    _future = fetchKidsShorts(ageGroup: ageGroup);
    setState(() {});
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Shorts for Age: ${ageGroup ?? "-"}')),
      body: FutureBuilder(
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
                        ageGroup: ageGroup!,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
