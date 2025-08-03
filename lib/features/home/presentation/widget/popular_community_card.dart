import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';
import 'package:url_launcher/url_launcher.dart'; // ✅ 외부 브라우저 열기용
import '../../model/popular_community.dart';

class PopularCommunityCardTheme {
  // 색상 팔레트
  static const Color primaryGradientStart = Color(0xFF667eea);
  static const Color primaryGradientEnd = Color(0xFF764ba2);
  static const Color secondaryGradientStart = Color(0xFFf093fb);
  static const Color secondaryGradientEnd = Color(0xFFf5576c);
  static const Color accentGradientStart = Color(0xFF4facfe);
  static const Color accentGradientEnd = Color(0xFF00f2fe);
  
  // 배경 색상
  static const Color backgroundColor = Colors.white;
  static const Color cardBackgroundColor = Colors.white;
  
  // 간격
  static const double spacing = 16.0;
  static const double cardRadius = 20.0;
  static const double imageRadius = 16.0;
}

class PopularCommunityCard extends StatelessWidget {
  final PopularCommunity community;
  final int rank;
  final VoidCallback? onTap;

  const PopularCommunityCard({
    super.key,
    required this.community,
    required this.rank,
    this.onTap,
  });

  Widget _buildRankBadge() {
    Color badgeColor;
    Color textColor;
    
    if (rank == 1) {
      badgeColor = const Color(0xFFFFD700); // 골드
      textColor = const Color(0xFF8B4513);
    } else if (rank == 2) {
      badgeColor = const Color(0xFFC0C0C0); // 실버
      textColor = const Color(0xFF2F4F4F);
    } else if (rank == 3) {
      badgeColor = const Color(0xFFCD7F32); // 브론즈
      textColor = Colors.white;
    } else {
      badgeColor = PopularCommunityCardTheme.primaryGradientStart;
      textColor = Colors.white;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: rank <= 3 
            ? null 
            : LinearGradient(
                colors: [
                  PopularCommunityCardTheme.primaryGradientStart,
                  PopularCommunityCardTheme.primaryGradientEnd,
                ],
              ),
        color: rank <= 3 ? badgeColor : null,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (rank <= 3) ...[
            Icon(
              rank == 1 ? Icons.emoji_events_rounded : 
              rank == 2 ? Icons.workspace_premium_rounded : 
              Icons.military_tech_rounded,
              size: 14,
              color: textColor,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            'TOP $rank',
            style: TextStyle(
              fontSize: 12,
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceBadge(String source) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: source == '강남언니' 
            ? const Color(0xFF667eea).withOpacity(0.1)
            : const Color(0xFFf093fb).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: source == '강남언니' 
              ? const Color(0xFF667eea).withOpacity(0.3)
              : const Color(0xFFf093fb).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        source,
        style: TextStyle(
          fontSize: 11,
          color: source == '강남언니' 
              ? const Color(0xFF667eea)
              : const Color(0xFFf093fb),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildKeywordBadge(String keyword) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            PopularCommunityCardTheme.secondaryGradientStart,
            PopularCommunityCardTheme.secondaryGradientEnd,
          ],
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        keyword,
        style: const TextStyle(
          fontSize: 11,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = community.photoUrls.isNotEmpty;
    final imageUrl = hasImage ? community.photoUrls.first : null;

    return GestureDetector(
      onTap: () async {
        final baseUrl = community.source == '강남언니'
            ? 'https://www.gangnamunni.com/community/'
            : 'https://web.babitalk.com/community/';
        final url = '$baseUrl${community.communityId}';

        final uri = Uri.tryParse(url);
        if (uri != null && await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('링크를 열 수 없습니다.')),
            );
          }
        }
      },
      child: Container(
        width: 280,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TOP 배지
            Row(
              children: [
                _buildRankBadge(),
                const Spacer(),
                if (community.keyword != null && community.keyword!.isNotEmpty)
                  _buildKeywordBadge(community.keyword!),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // 컨텐츠
            Expanded(
              child: Text(
                community.content.replaceAll('\r\n', '\n').trim(),
                maxLines: 6,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF1F2937),
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 하단 정보
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSourceBadge(community.source),
                if (community.keyword != null && community.keyword!.isNotEmpty)
                  _buildKeywordBadge(community.keyword!),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
