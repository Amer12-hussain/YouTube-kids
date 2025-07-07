import 'package:flutter/material.dart';
import 'package:youtube_kids/YouTube/AgeSelectionScreen.dart';
import 'package:youtube_kids/YouTube/index.dart';
import 'package:youtube_kids/YouTubePlayerScreen/ShortsVideoPlayer.dart';
class ShortsFeedScreen extends StatefulWidget {
  final List<Map<String, dynamic>> initialVideos;
  final String? initialPageToken;
  final int initialIndex;
  final String ageGroup;
  const ShortsFeedScreen({
    super.key,
    required this.initialVideos,
    required this.initialPageToken,
    this.initialIndex = 0,
    required this.ageGroup,
  });
  @override
  State<ShortsFeedScreen> createState() => _ShortsFeedScreenState();
}
class _ShortsFeedScreenState extends State<ShortsFeedScreen> {
  late PageController _pageController;
  late List<Map<String, dynamic>> _videos;
  String? _nextPageToken;
  bool _isLoadingMore = false;
  int _currentIndex = 0;
  @override
  void _skipNextPages() async {
    if (_nextPageToken == null) return;
    setState(() => _isLoadingMore = true);
    try {
      String? token = _nextPageToken;
      List<Map<String, dynamic>> skippedVideos = [];
      for (int i = 0; i < 4; i++) {
        if (token == null) break;
        final result = await fetchKidsShorts(
          ageGroup: widget.ageGroup,
          pageToken: token,
        );
        final newVideos = List<Map<String, dynamic>>.from(result['videos']);
        skippedVideos.addAll(newVideos);
        token = result['nextPageToken'];
      }
      if (skippedVideos.isNotEmpty) {
        setState(() {
          _videos.addAll(skippedVideos);
          _nextPageToken = token;
          _currentIndex = _videos.length - skippedVideos.length;
          _pageController.jumpToPage(_currentIndex);
        });
      }
    } catch (e) {
      print('❌ Error skipping pages: $e');
    } finally {
      setState(() => _isLoadingMore = false);
    }
  }
  void initState() {
    super.initState();
    _videos = List.from(widget.initialVideos);
    _nextPageToken = widget.initialPageToken;
    _pageController = PageController(initialPage: widget.initialIndex);
    _currentIndex = widget.initialIndex;
    _pageController.addListener(() {
      final page = _pageController.page;
      if (page != null) {
        final newIndex = page.round();
        if (newIndex != _currentIndex) {
          setState(() {
            _currentIndex = newIndex;
          });
        }
        if (!_isLoadingMore &&
            _nextPageToken != null &&
            newIndex >= _videos.length - 2) {
          _loadMoreVideos();
        }
      }
    });
  }
  Future<void> _loadMoreVideos() async {
    setState(() => _isLoadingMore = true);
    try {
      final result = await fetchKidsShorts(
        ageGroup: widget.ageGroup,
        pageToken: _nextPageToken,
      );
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
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: _videos.length,
            itemBuilder: (context, index) {
              final video = _videos[index];
              return ShortsVideoPlayer(
                videoId: video['videoId'],
                channelTitle: video['title'],
                isActive: index == _currentIndex,
                onBack: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => AgeSelectionScreen()),
                    (route) => false,
                  );
                },
              );
            },
          ),
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              onPressed: _skipNextPages,
              icon: const Icon(Icons.refresh, color: Colors.white, size: 30),
              tooltip: 'Skip 4 Pages',
              splashRadius: 24,
            ),
          ),
        ],
      ),
    );
  }
}
