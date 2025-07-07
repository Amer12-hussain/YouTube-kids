import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class ShortsVideoPlayer extends StatefulWidget {
  final String videoId;
  final String channelTitle;
  final VoidCallback onBack;
  final bool isActive;
  const ShortsVideoPlayer({
    Key? key,
    required this.videoId,
    required this.channelTitle,
    required this.onBack,
    required this.isActive,
  }) : super(key: key);
  @override
  State<ShortsVideoPlayer> createState() => _ShortsVideoPlayerState();
}

class _ShortsVideoPlayerState extends State<ShortsVideoPlayer>
    with AutomaticKeepAliveClientMixin {
  late YoutubePlayerController _controller;
  bool _isVideoEnded = false;
  bool _isLoading = true;
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
        disableDragSeek: true,
      ),
    )..addListener(_videoListener);
  }

  void _videoListener() {
    final playerState = _controller.value.playerState;
    if (mounted) {
      setState(() {
        _isVideoEnded = playerState == PlayerState.ended;
        _isLoading =
            !_controller.value.isReady ||
            playerState == PlayerState.buffering ||
            playerState == PlayerState.unknown;
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
  void didUpdateWidget(covariant ShortsVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive) {
      _controller.play();
    } else {
      _controller.pause();
    }
  }

  @override
  void deactivate() {
    _controller.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _controller.removeListener(_videoListener);
    _controller.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Stack(
      children: [
        Positioned.fill(
          child: YoutubePlayer(
            controller: _controller,
            showVideoProgressIndicator: false,
            topActions: const [],
          ),
        ),
        // ⏳ Loading Indicator
        if (_isLoading)
          const Center(child: CircularProgressIndicator(color: Colors.white)),
        // 🔁 Replay Button
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
        // 👤 Channel Info
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
      ],
    );
  }
}
