import 'package:flutter/material.dart';
import 'package:youtube_kids/Youtube/index.dart';
import 'package:youtube_kids/YoutubePlayerScreen/ShortsVideoPlayer.dart';

class ShortsFeedScreen extends StatefulWidget {
  final List<Map<String, dynamic>> initialVideos;
  final String? initialPageToken;
  final int initialIndex;
  const ShortsFeedScreen({
    super.key,
    required this.initialVideos,
    required this.initialPageToken,
    this.initialIndex = 0,
  });
  @override
  State<ShortsFeedScreen> createState() => _ShortsFeedScreenState();
}

class _ShortsFeedScreenState extends State<ShortsFeedScreen> {
  late PageController _pageController;
  late List<Map<String, dynamic>> _videos;
  String? _nextPageToken;
  bool _isLoadingMore = false;
  @override
  void initState() {
    super.initState();
    _videos = List.from(widget.initialVideos);
    _nextPageToken = widget.initialPageToken;
    _pageController = PageController(initialPage: widget.initialIndex);
    _pageController.addListener(() {
      final currentPage = _pageController.page ?? 0;
      if (!_isLoadingMore &&
          _nextPageToken != null &&
          currentPage >= _videos.length * 0.7) {
        _loadMoreVideos();
      }
    });
  }

  Future<void> _loadMoreVideos() async {
    setState(() => _isLoadingMore = true);
    try {
      final result = await fetchKidsShorts(pageToken: _nextPageToken);
      final newVideos = List<Map<String, dynamic>>.from(result['videos']);
      setState(() {
        _videos.addAll(newVideos);
        _nextPageToken = result['nextPageToken'];
      });
    } catch (e) {
      print('❌ Failed to load more shorts: $e');
    } finally {
      setState(() => _isLoadingMore = false);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: _videos.length,
        itemBuilder: (context, index) {
          final video = _videos[index];
          return ShortsVideoPlayer(
            videoId: video['videoId'],
            channelTitle: video['title'],
          );
        },
      ),
    );
  }
}
