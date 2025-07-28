import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../like/data/like_repository.dart';
import '../../model/hostpital.dart';

// 🎨 Modern Hospital Card Theme
class HospitalCardTheme {
  static const Color primaryGradientStart = Color(0xFF667eea);
  static const Color primaryGradientEnd = Color(0xFF764ba2);
  static const Color secondaryGradientStart = Color(0xFFf093fb);
  static const Color secondaryGradientEnd = Color(0xFFf5576c);
  static const Color cardBackground = Color(0xFFffffff);
  static const Color textPrimary = Color(0xFF2d3748);
  static const Color textSecondary = Color(0xFF718096);
  static const Color accentColor = Color(0xFFed8936);
  static const Color successColor = Color(0xFF48bb78);
  static const Color warningColor = Color(0xFFed8936);
  static const Color errorColor = Color(0xFFf56565);
  static const double borderRadius = 20.0;
  static const double cardElevation = 12.0;
  static const Duration animationDuration = Duration(milliseconds: 300);
}

class HospitalCard extends StatefulWidget {
  final Hospital hospital;
  final int historyCreatedAt;
  final void Function(Hospital updated)? onLikedChanged;

  const HospitalCard({
    Key? key,
    required this.hospital,
    required this.historyCreatedAt,
    this.onLikedChanged,
  }) : super(key: key);

  @override
  State<HospitalCard> createState() => _HospitalCardState();
}

class _HospitalCardState extends State<HospitalCard>
    with SingleTickerProviderStateMixin {
  late Hospital _hospital;
  final LikeRepository _likeRepo = LikeRepository();
  
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _hospital = widget.hospital;
    
    _animationController = AnimationController(
      duration: HospitalCardTheme.animationDuration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _toggleLike() async {
    final isNowLiked = !_hospital.liked;

    setState(() {
      _hospital = _hospital.copyWith(liked: isNowLiked);
    });

    try {
      if (isNowLiked) {
        await _likeRepo.postLikeBeautyHospital(
          historyCreatedAt: widget.historyCreatedAt,
          hospitalId: _hospital.id.toString(),
          source: _hospital.source,
        );
      } else {
        await _likeRepo.deleteLikeBeautyHospital(
          historyCreatedAt: widget.historyCreatedAt,
          hospitalId: _hospital.id.toString(),
          source: _hospital.source,
        );
      }

      widget.onLikedChanged?.call(_hospital);
    } catch (e) {
      setState(() {
        _hospital = _hospital.copyWith(liked: !isNowLiked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? thumbnail =
        (_hospital.thumbnailUrl != null && _hospital.thumbnailUrl.isNotEmpty)
            ? _hospital.thumbnailUrl
            : null;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: HospitalCardTheme.cardBackground,
                borderRadius: BorderRadius.circular(HospitalCardTheme.borderRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (thumbnail != null)
                    GestureDetector(
                      onTap: () {
                        context.push(
                          '/hospital-detail/${_hospital.id}/${widget.historyCreatedAt}',
                          extra: _hospital,
                        );
                      },
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(HospitalCardTheme.borderRadius),
                        ),
                        child: Stack(
                          children: [
                            CachedNetworkImage(
                              imageUrl: thumbnail,
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => Container(
                                height: 180,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.grey.shade200,
                                      Colors.grey.shade100,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                              ),
                              errorWidget: (_, __, ___) => Container(
                                height: 180,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.grey.shade300,
                                      Colors.grey.shade200,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                              ),
                            ),
                            // Source badge
                            Positioned(
                              top: 12,
                              left: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.black.withOpacity(0.8),
                                      Colors.black.withOpacity(0.6),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  _hospital.source,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                _hospital.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: HospitalCardTheme.textPrimary,
                                  height: 1.3,
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: _hospital.liked
                                      ? [Colors.red.shade400, Colors.red.shade600]
                                      : [Colors.grey.shade300, Colors.grey.shade400],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: (_hospital.liked ? Colors.red : Colors.grey).withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: IconButton(
                                icon: Icon(
                                  _hospital.liked
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                onPressed: _toggleLike,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                HospitalCardTheme.primaryGradientStart.withOpacity(0.1),
                                HospitalCardTheme.primaryGradientEnd.withOpacity(0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${_hospital.location} · ${_hospital.hospitalName}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: HospitalCardTheme.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 16,
                          runSpacing: 8,
                          children: [
                            _buildModernIconText(Icons.star, '${_hospital.rating}점', Colors.amber),
                            _buildModernIconText(Icons.reviews, '${_hospital.ratingCount}건', Colors.blue),
                            _buildModernIconText(
                              Icons.event_available,
                              '${_hospital.doctorCount}명의 의사',
                              Colors.green,
                            ),
                            _buildModernIconText(
                              Icons.question_answer,
                              '${_hospital.counselCount}건 상담',
                              Colors.purple,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: _hospital.description
                              .split(RegExp(r'\s+'))
                              .map(
                                (word) => Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        HospitalCardTheme.secondaryGradientStart.withOpacity(0.1),
                                        HospitalCardTheme.secondaryGradientEnd.withOpacity(0.1),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: HospitalCardTheme.secondaryGradientStart.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    word.startsWith('#') ? word : '#$word',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: HospitalCardTheme.secondaryGradientStart,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
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

  Widget _buildModernIconText(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: HospitalCardTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
