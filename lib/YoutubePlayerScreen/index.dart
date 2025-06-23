import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YouTubePlayerScreen extends StatefulWidget {
  final String videoId;
  final String channelTitle;
  const YouTubePlayerScreen({
    required this.videoId,
    required this.channelTitle,
    super.key,
  });
  @override
  State<YouTubePlayerScreen> createState() => _YouTubePlayerScreenState();
}

class _YouTubePlayerScreenState extends State<YouTubePlayerScreen> {
  late YoutubePlayerController _controller;
  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        loop: true,
        hideControls: false,
        controlsVisibleAtStart: true,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: YoutubePlayerBuilder(
        player: YoutubePlayer(
          controller: _controller,
          showVideoProgressIndicator: true,
          bottomActions: [
            const SizedBox(width: 14),
            CurrentPosition(),
            const SizedBox(width: 8),
            ProgressBar(isExpanded: true),
            const SizedBox(width: 8),
            RemainingDuration(),
            const PlaybackSpeedButton(),
          ],
        ),
        builder: (context, player) {
          return Stack(
            children: [
              // Full-screen player with 9:16 aspect ratio
              Center(
                child: AspectRatio(aspectRatio: 9 / 16, child: player),
              ),
              // Back button (top-left corner)
              Positioned(
                top: 40,
                left: 16,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                ),
              ),
              // Channel title at the bottom
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
        },
      ),
    );
  }
}
