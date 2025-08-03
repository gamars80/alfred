import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../call/model/hostpital.dart';
import '../../model/popular_beauty_hospital.dart';

class PopularBeautyHospitalCardTheme {
  // 뷰티다운 우아한 색상 팔레트
  static const Color primaryColor = Color(0xFFE91E63); // 핑크
  static const Color secondaryColor = Color(0xFFF06292); // 연한 핑크
  static const Color accentColor = Color(0xFFFFC0CB); // 라이트 핑크
  static const Color elegantBackground = Color(0xFFFFF5F7); // 우아한 크림색
  static const Color textColor = Color(0xFF2D3748);
  static const Color subtitleColor = Color(0xFF718096);
  static const Color ratingColor = Color(0xFFFFB74D); // 오렌지
  
  // 카드 스타일
  static const double cardRadius = 16.0;
  static const double imageRadius = 12.0;
  static const double badgeRadius = 20.0;
  
  // 그림자 효과
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 12,
      offset: Offset(0, 6),
    ),
    BoxShadow(
      color: Color(0x0AE91E63),
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
  ];
  
  // 랭킹 배지 그라데이션
  static const LinearGradient rankGradient = LinearGradient(
    colors: [Color(0xFFE91E63), Color(0xFFF06292)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class PopularBeautyHospitalCard extends StatefulWidget {
  final PopularBeautyHospital hospital;
  final int rank;

  const PopularBeautyHospitalCard({
    Key? key,
    required this.hospital,
    required this.rank,
  }) : super(key: key);

  @override
  State<PopularBeautyHospitalCard> createState() => _PopularBeautyHospitalCardState();
}

class _PopularBeautyHospitalCardState extends State<PopularBeautyHospitalCard> with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  Widget _buildRankBadge() {
    return Positioned(
      top: 12,
      left: 12,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          gradient: PopularBeautyHospitalCardTheme.rankGradient,
          borderRadius: BorderRadius.circular(PopularBeautyHospitalCardTheme.badgeRadius),
          boxShadow: [
            BoxShadow(
              color: PopularBeautyHospitalCardTheme.primaryColor.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          'TOP ${widget.rank}',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildSourceBadge() {
    return Positioned(
      top: 12,
      right: 12,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Text(
          widget.hospital.source,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildRatingSection() {
    return Row(
      children: [
        Icon(
          Icons.star_rounded,
          size: 16,
          color: PopularBeautyHospitalCardTheme.ratingColor,
        ),
        const SizedBox(width: 4),
        Text(
          '${widget.hospital.rating}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: PopularBeautyHospitalCardTheme.ratingColor,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '(${widget.hospital.ratingCount})',
          style: TextStyle(
            fontSize: 12,
            color: PopularBeautyHospitalCardTheme.subtitleColor,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: (_) {
              setState(() => _isHovered = true);
              _scaleController.forward();
            },
            onTapUp: (_) {
              setState(() => _isHovered = false);
              _scaleController.reverse();
            },
            onTapCancel: () {
              setState(() => _isHovered = false);
              _scaleController.reverse();
            },
            onTap: () {
              // LikedBeautyHospital을 Hospital 모델로 매핑하여 상세 라우트로 전달
              final hospitalModel = Hospital(
                id: widget.hospital.hospitalId,
                source: widget.hospital.source,
                thumbnailUrl: widget.hospital.thumbnailUrl,
                location: widget.hospital.location,
                hospitalName: widget.hospital.hospitalName,
                rating: widget.hospital.rating,
                ratingCount: widget.hospital.ratingCount,
                description: widget.hospital.description,
                counselCount: widget.hospital.counselCount,
                doctorCount: widget.hospital.doctorCount,
                title: widget.hospital.title,
                liked: false,
              );
              context.push('/hospital-detail/${widget.hospital.hospitalId}/${widget.hospital.historyAddedAt}', extra: hospitalModel);
            },
            child: Container(
              width: 260,
              height: 320,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: PopularBeautyHospitalCardTheme.elegantBackground,
                borderRadius: BorderRadius.circular(PopularBeautyHospitalCardTheme.cardRadius),
                boxShadow: PopularBeautyHospitalCardTheme.cardShadow,
                border: Border.all(
                  color: PopularBeautyHospitalCardTheme.primaryColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(PopularBeautyHospitalCardTheme.cardRadius),
                    ),
                    child: Stack(
                      children: [
                        CachedNetworkImage(
                          imageUrl: widget.hospital.thumbnailUrl,
                          height: 140,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            height: 140,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.grey[200]!,
                                  Colors.grey[300]!,
                                ],
                              ),
                            ),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            height: 140,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.grey[200]!,
                                  Colors.grey[300]!,
                                ],
                              ),
                            ),
                            child: const Icon(
                              Icons.broken_image_rounded,
                              color: Colors.grey,
                              size: 32,
                            ),
                          ),
                        ),
                        _buildRankBadge(),
                        _buildSourceBadge(),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(PopularBeautyHospitalCardTheme.badgeRadius),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.hospital.hospitalName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: PopularBeautyHospitalCardTheme.textColor,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_rounded,
                              size: 14,
                              color: PopularBeautyHospitalCardTheme.subtitleColor,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                widget.hospital.location,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: PopularBeautyHospitalCardTheme.subtitleColor,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildRatingSection(),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: PopularBeautyHospitalCardTheme.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.people_rounded,
                                    size: 14,
                                    color: PopularBeautyHospitalCardTheme.primaryColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '의사 ${widget.hospital.doctorCount}명',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: PopularBeautyHospitalCardTheme.primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: PopularBeautyHospitalCardTheme.secondaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.chat_bubble_rounded,
                                    size: 14,
                                    color: PopularBeautyHospitalCardTheme.secondaryColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '상담 ${widget.hospital.counselCount}건',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: PopularBeautyHospitalCardTheme.secondaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
