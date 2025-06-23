import 'package:flutter/material.dart';
import 'package:youtube_kids/YoutubePlayerScreen/ShortsVideoPlayer.dart';

class ShortsFeedScreen extends StatefulWidget {
  final List<Map<String, dynamic>> videos;
  final int initialIndex;
  const ShortsFeedScreen({
    super.key,
    required this.videos,
    this.initialIndex = 0,
  });
  @override
  State<ShortsFeedScreen> createState() => _ShortsFeedScreenState();
}

class _ShortsFeedScreenState extends State<ShortsFeedScreen> {
  late PageController _pageController;
  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: widget.videos.length,
        itemBuilder: (context, index) {
          final video = widget.videos[index];
          return ShortsVideoPlayer(
            videoId: video['videoId'],
            channelTitle: video['title'],
          );
        },
      ),
    );
  }
}
