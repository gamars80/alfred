import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../model/chat_message.dart';
import 'product_suggestion_card.dart';

/// AI 메시지 카드 위젯
/// 
/// AI의 응답을 표시하는 카드입니다.
/// 실무 수준의 디자인과 다양한 메시지 타입을 지원합니다.
class AiMessageCard extends StatefulWidget {
  final ChatMessage message;
  final Function(Map<String, dynamic>)? onProductTap;
  final bool showAvatar;

  const AiMessageCard({
    super.key,
    required this.message,
    this.onProductTap,
    this.showAvatar = true,
  });

  @override
  State<AiMessageCard> createState() => _AiMessageCardState();
}

class _AiMessageCardState extends State<AiMessageCard>
    with TickerProviderStateMixin {
  late AnimationController _thinkingController;
  late Animation<double> _thinkingAnimation;

  @override
  void initState() {
    super.initState();
    _thinkingController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _thinkingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _thinkingController,
      curve: Curves.easeInOut,
    ));

    // 로딩 상태일 때 애니메이션 시작
    if (_isLoadingMessage) {
      _thinkingController.repeat(reverse: true);
    }
  }

  bool get _isLoadingMessage => 
    widget.message.metadata?['type'] == 'loading';

  @override
  void dispose() {
    _thinkingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.showAvatar) ...[
            _buildAvatar(),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.showAvatar) _buildNameTag(),
                _buildMessageBubble(),
                if (widget.message.metadata != null && !_isLoadingMessage) ...[
                  const SizedBox(height: 12),
                  _buildRecommendations(),
                ],
                _buildTimestamp(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: 18,
        backgroundColor: Colors.deepPurple,
        backgroundImage: const AssetImage('assets/icon/alfred_icon.png'),
        onBackgroundImageError: (exception, stackTrace) {
          debugPrint('알프레드 아이콘 로드 실패: $exception');
        },
      ),
    );
  }

  Widget _buildNameTag() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(
            '알프레드',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.deepPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'AI',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Colors.deepPurple[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(4),
          topRight: Radius.circular(16),
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: _isLoadingMessage 
        ? _buildThinkingAnimation()
        : Text(
            widget.message.content,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 15,
              fontWeight: FontWeight.w400,
              height: 1.4,
            ),
          ),
    );
  }

  Widget _buildThinkingAnimation() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 알프레드 아이콘 (생각하는 모습)
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const CircleAvatar(
              radius: 16,
              backgroundColor: Colors.deepPurple,
              backgroundImage: AssetImage('assets/icon/alfred_icon.png'),
            ),
          ),
          const SizedBox(width: 12),
          // 생각하는 텍스트와 애니메이션
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '알프레드',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'AI',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Colors.blue.shade600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  AnimatedBuilder(
                    animation: _thinkingAnimation,
                    builder: (context, child) {
                      return Text(
                        '생각중',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 4),
                  // 점 애니메이션
                  AnimatedBuilder(
                    animation: _thinkingAnimation,
                    builder: (context, child) {
                      return Row(
                        children: List.generate(3, (index) {
                          final delay = index * 0.2;
                          final opacity = _thinkingAnimation.value > delay 
                              ? (_thinkingAnimation.value - delay) / 0.8 
                              : 0.0;
                          return AnimatedOpacity(
                            opacity: opacity.clamp(0.0, 1.0),
                            duration: const Duration(milliseconds: 200),
                            child: Text(
                              '.',
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendations() {
    final metadata = widget.message.metadata!;
    
    if (metadata['foodRecommendation'] != null) {
      return _buildFoodRecommendation(metadata['foodRecommendation']);
    } else if (metadata['beautyCareRecommendation'] != null) {
      return _buildBeautyCareRecommendation(metadata['beautyCareRecommendation']);
    } else if (metadata['products'] != null) {
      return ProductSuggestionCard(
        products: metadata['products'],
        onProductTap: widget.onProductTap,
      );
    } else if (metadata['careProducts'] != null) {
      return ProductSuggestionCard(
        products: metadata['careProducts'],
        onProductTap: widget.onProductTap,
      );
    } else if (metadata['beautyData'] != null) {
      return _buildBeautyDataRecommendation(metadata['beautyData']);
    } else if (metadata['fashionRecommendation'] != null) {
      return _buildFashionRecommendation(metadata['fashionRecommendation']);
    } else if (metadata['beautyRecommendation'] != null) {
      return _buildBeautyRecommendation(metadata['beautyRecommendation']);
    }
    
    return const SizedBox.shrink();
  }

  Widget _buildFoodRecommendation(dynamic foodData) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.orange.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.restaurant_rounded,
                  color: Colors.orange,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                '음식/식자재 추천',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '음식/식자재 정보 추천이 완료되었습니다!',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          // 히스토리로 이동하는 버튼 (음식/식자재 탭으로 이동)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // 하단 메뉴의 히스토리 탭의 음식/식자재 탭으로 이동
                _navigateToFoodHistory();
              },
              icon: const Icon(
                Icons.history_rounded,
                color: Colors.white,
                size: 18,
              ),
              label: const Text(
                '히스토리 보러가기',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBeautyDataRecommendation(dynamic beautyData) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF3E5F5), Color(0xFFE1BEE7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.purple.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.medical_services_rounded,
                  color: Colors.purple,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                '병원/시술 정보',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            beautyData.toString(),
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFashionRecommendation(dynamic fashionData) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFCE4EC), Color(0xFFF8BBD9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.pink.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.pink.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.shopping_bag_rounded,
                  color: Colors.pink,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                '패션 추천',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.pink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '패션 상품 추천이 완료되었습니다!',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          // 히스토리로 이동하는 버튼
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // 하단 메뉴의 히스토리로 이동
                _navigateToHistory();
              },
              icon: const Icon(
                Icons.history_rounded,
                color: Colors.white,
                size: 18,
              ),
              label: const Text(
                '히스토리 보러가기',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBeautyRecommendation(dynamic beautyData) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE8F5E8), Color(0xFFC8E6C9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.green.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.medical_services_rounded,
                  color: Colors.green,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                '성형/시술 추천',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '성형/시술 정보 추천이 완료되었습니다!',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          // 히스토리로 이동하는 버튼 (시술/성형 탭으로 이동)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // 하단 메뉴의 히스토리 탭의 시술/성형 탭으로 이동
                _navigateToBeautyHistory();
              },
              icon: const Icon(
                Icons.history_rounded,
                color: Colors.white,
                size: 18,
              ),
              label: const Text(
                '히스토리 보러가기',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToHistory() {
    // 안전한 네비게이션을 위해 mounted 체크
    if (!mounted) return;
    
    try {
      // 직접 히스토리 탭으로 이동 (채팅 화면은 자동으로 닫힘)
      context.go('/history');
      debugPrint('히스토리 탭으로 이동 완료');
    } catch (e) {
      debugPrint('네비게이션 오류: $e');
    }
  }

  void _navigateToBeautyHistory() {
    // 안전한 네비게이션을 위해 mounted 체크
    if (!mounted) return;
    
    try {
      // 히스토리 탭의 시술/성형 탭으로 이동
      context.go('/history/beauty');
      debugPrint('성형/시술 히스토리 탭으로 이동 완료');
    } catch (e) {
      debugPrint('네비게이션 오류: $e');
    }
  }

  void _navigateToFoodHistory() {
    // 안전한 네비게이션을 위해 mounted 체크
    if (!mounted) return;
    
    try {
      // 히스토리 탭의 음식/식자재 탭으로 이동
      context.go('/history/food');
      debugPrint('음식/식자재 히스토리 탭으로 이동 완료');
    } catch (e) {
      debugPrint('네비게이션 오류: $e');
    }
  }

  Widget _buildBeautyCareRecommendation(dynamic beautyCareData) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFCE4EC), Color(0xFFF8BBD9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.pink.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.pink.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.face_retouching_natural_rounded,
                  color: Colors.pink,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                '뷰티케어 추천',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.pink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '뷰티케어 정보 추천이 완료되었습니다!',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          // 히스토리로 이동하는 버튼 (뷰티케어 탭으로 이동)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // 하단 메뉴의 히스토리 탭의 뷰티케어 탭으로 이동
                _navigateToBeautyCareHistory();
              },
              icon: const Icon(
                Icons.history_rounded,
                color: Colors.white,
                size: 18,
              ),
              label: const Text(
                '히스토리 보러가기',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToBeautyCareHistory() {
    // 안전한 네비게이션을 위해 mounted 체크
    if (!mounted) return;
    
    try {
      // 히스토리 탭의 뷰티케어 탭으로 이동
      context.go('/history/beauty-care');
      debugPrint('뷰티케어 히스토리 탭으로 이동 완료');
    } catch (e) {
      debugPrint('네비게이션 오류: $e');
    }
  }

  Widget _buildTimestamp() {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        _formatTime(widget.message.timestamp),
        style: TextStyle(
          fontSize: 11,
          color: Colors.grey[500],
        ),
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return '방금 전';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}시간 전';
    } else {
      return '${timestamp.month}/${timestamp.day} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }
} 