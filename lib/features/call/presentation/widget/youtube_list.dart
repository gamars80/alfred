import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../model/youtube_video.dart';

class YouTubeList extends StatelessWidget {
  final List<YouTubeVideo> videos;

  const YouTubeList({Key? key, required this.videos}) : super(key: key);

  // 썸네일 해상도를 최대 우선으로 시도하는 리스트
  static const _thumbRes = [
    'maxresdefault', // 1280×720
    'sddefault',     // 640×480
    'hqdefault',     // 480×360
    'mqdefault',     // 320×180
  ];

  String _bestThumbnail(String id) {
    // 가능한 가장 높은 해상도 썸네일 URL 반환
    return _thumbRes.map((r) => 'https://img.youtube.com/vi/$id/$r.jpg').first;
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: videos.length,
      itemBuilder: (ctx, i) {
        final v = videos[i];
        final thumbUrl = _bestThumbnail(v.videoId!);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          clipBehavior: Clip.hardEdge,
          child: InkWell(
            onTap: () => _openPlayerDialog(ctx, v.videoId!),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1) 썸네일을 폭 전체, 높이 180으로 고정
                CachedNetworkImage(
                  imageUrl: thumbUrl,
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => const SizedBox(
                    width: double.infinity,
                    height: 180,
                    child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
                  errorWidget: (_, __, ___) => const SizedBox(
                    width: double.infinity,
                    height: 180,
                    child: Center(child: Icon(Icons.broken_image)),
                  ),
                ),

                // 2) 제목은 최대 2줄, 아래 패딩
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    v.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openPlayerDialog(BuildContext ctx, String videoId) {
    // 버퍼링 전략: autoPlay, 최소 버퍼링 플래그만 사용
    final controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        disableDragSeek: true,
        startAt: 0,
        enableCaption: false,
        useHybridComposition: true,
      ),
    );

    showDialog(
      context: ctx,
      barrierColor: Colors.black54,
      builder: (_) => Dialog(
        insetPadding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: MediaQuery.of(ctx).size.width * 0.95,
          height: MediaQuery.of(ctx).size.height * 0.75,
          child: Stack(
            children: [
              // 플레이어 크기 최대화
              Positioned.fill(
                child: YoutubePlayer(
                  controller: controller,
                  showVideoProgressIndicator: true,
                  progressIndicatorColor: Colors.deepPurple,
                  onEnded: (_) => Navigator.of(ctx).pop(),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    ).then((_) {
      controller.pause();
      controller.dispose();
    });
  }
}
