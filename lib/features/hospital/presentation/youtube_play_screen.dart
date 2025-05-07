import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class YoutubePlayerScreen extends StatefulWidget {
  final String videoId;

  const YoutubePlayerScreen({super.key, required this.videoId});

  @override
  State<YoutubePlayerScreen> createState() => _YoutubePlayerScreenState();
}

class _YoutubePlayerScreenState extends State<YoutubePlayerScreen> {
  late final YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController.fromVideoId(
      videoId: widget.videoId,
      autoPlay: true,
      params: const YoutubePlayerParams(
        showFullscreenButton: true,
        showControls: true,
        enableJavaScript: true,
      ),
    );
  }

  @override
  void dispose() {
    _controller.close(); // 메모리 해제
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerScaffold(
      controller: _controller,
      builder: (context, player) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('유튜브 영상'),
            backgroundColor: Colors.deepPurple,
          ),
          body: Column(
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: player,
              ),
            ],
          ),
        );
      },
    );
  }
}
