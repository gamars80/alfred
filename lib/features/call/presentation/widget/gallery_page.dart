import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

/// 전체 화면 이미지 갤러리 페이지
class GalleryPage extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const GalleryPage({
    Key? key,
    required this.images,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          '${_currentIndex + 1}/${widget.images.length}',
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.images.length,
        onPageChanged: (idx) {
          setState(() => _currentIndex = idx);
        },
        itemBuilder: (context, index) {
          final imageUrl = widget.images[index];
          final isBlurred = widget.images.length > 1 && index > 0;

          final blurredImage = Stack(
            children: [
              Positioned.fill(
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 16, sigmaY: 16), // 블러 강도 ↑↑
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.75), // 블라인드 덮기 더 어둡게
                ),
              ),
            ],
          );

          return InteractiveViewer(
            child: isBlurred
                ? blurredImage
                : CachedNetworkImage(
              imageUrl: imageUrl,
              placeholder: (c, url) =>
              const CircularProgressIndicator(color: Colors.white),
              errorWidget: (c, url, err) =>
              const Icon(Icons.broken_image, color: Colors.white),
            ),
          );
        },
      ),
    );
  }
}
