import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class ShortsVideoPlayer extends StatefulWidget {
  final String videoId;
  final String channelTitle;
  final VoidCallback onBack;
  const ShortsVideoPlayer({
    super.key,
    required this.videoId,
    required this.channelTitle,
    required this.onBack,
  });
  @override
  State<ShortsVideoPlayer> createState() => _ShortsVideoPlayerState();
}

class _ShortsVideoPlayerState extends State<ShortsVideoPlayer> {
  late YoutubePlayerController _controller;
  bool _isVideoEnded = false;
  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        loop: false,
        hideControls: true,
        controlsVisibleAtStart: false,
      ),
    )..addListener(_checkVideoStatus);
  }

  void _checkVideoStatus() {
    final state = _controller.value.playerState;
    if (state == PlayerState.ended && !_isVideoEnded) {
      setState(() {
        _isVideoEnded = true;
      });
    }
  }

  void _replayVideo() {
    _controller.seekTo(Duration.zero);
    _controller.play();
    setState(() {
      _isVideoEnded = false;
    });
  }

  @override
  void deactivate() {
    _controller.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _controller.removeListener(_checkVideoStatus);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Fullscreen video
        SizedBox.expand(
          child: YoutubePlayer(
            controller: _controller,
            showVideoProgressIndicator: false,
          ),
        ),
        // Channel title
        Positioned(
          bottom: 40,
          left: 16,
          right: 16,
          child: Row(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.white,
                radius: 18,
                child: Icon(Icons.account_circle, color: Colors.black),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.channelTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        // Replay icon when video ends
        if (_isVideoEnded)
          Positioned.fill(
            child: Center(
              child: GestureDetector(
                onTap: _replayVideo,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: const Icon(
                    Icons.replay,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
