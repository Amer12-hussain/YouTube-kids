import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_kids/YoutubePlayerScreen/ShortsFeedScreen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<Map<String, dynamic>> fetchKidsShorts({
  String? ageGroup,
  String? pageToken,
}) async {
  final String apiKey = dotenv.env['YOUTUBE_API_KEY'] ?? '';
  String query = 'kids cartoon shorts';
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
    print("Using API key: $apiKey");
    print("Request URL: $url");
    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}");
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
  String? ageGroup;
  bool _navigated = false;
  @override
  void initState() {
    super.initState();
    _future = _loadAgeAndFetchVideos(); // Initialize _future here!
  }

  Future<Map<String, dynamic>> _loadAgeAndFetchVideos() async {
    final prefs = await SharedPreferences.getInstance();
    ageGroup = prefs.getString('selectedAgeGroup') ?? '3-4';
    final int randomPageSkip = Random().nextInt(5); // 0 to 4
    String? token;
    Map<String, dynamic> result = {};
    for (int i = 0; i <= randomPageSkip; i++) {
      result = await fetchKidsShorts(ageGroup: ageGroup, pageToken: token);
      token = result['nextPageToken'];
      if (token == null) break;
    }
    return result;
  }

  void _autoPlayFirstVideo(
    BuildContext context,
    List<Map<String, dynamic>> videos,
    String? nextPageToken,
  ) {
    if (!_navigated && videos.isNotEmpty && ageGroup != null) {
      _navigated = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ShortsFeedScreen(
              initialVideos: videos,
              initialPageToken: nextPageToken,
              initialIndex: 0,
              ageGroup: ageGroup!,
            ),
          ),
        ).then((_) {
          setState(() {
            _navigated = false;
          });
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink.shade50,
      body: FutureBuilder<Map<String, dynamic>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading videos'));
          }
          final result = snapshot.data!;
          final videos = List<Map<String, dynamic>>.from(result['videos']);
          final nextPageToken = result['nextPageToken'];
          _autoPlayFirstVideo(context, videos, nextPageToken);
          return const Center(
            child: Text('Loading...', style: TextStyle(fontSize: 18)),
          );
        },
      ),
    );
  }
}
