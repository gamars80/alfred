import 'package:flutter/material.dart';

/// 선택형 AI 채팅의 카테고리 선택 버튼 위젯
/// 
/// 메인 카테고리, 서브 카테고리, 연령대를 선택할 수 있는 인터랙티브 버튼들을 제공합니다.
/// 실무 수준의 디자인과 확장 가능한 구조를 구현했습니다.
class ChoiceButtonsWidget extends StatelessWidget {
  final String? currentMainCategory;
  final String? currentSubCategory;
  final String? currentAgeGroup;
  final Function(String) onMainCategorySelected;
  final Function(String) onSubCategorySelected;
  final Function(String) onAgeGroupSelected;

  const ChoiceButtonsWidget({
    super.key,
    this.currentMainCategory,
    this.currentSubCategory,
    this.currentAgeGroup,
    required this.onMainCategorySelected,
    required this.onSubCategorySelected,
    required this.onAgeGroupSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 메인 카테고리 선택 (첫 번째 단계)
          if (currentMainCategory == null) ...[
            _buildSectionTitle('서비스를 선택해주세요'),
            const SizedBox(height: 16),
            _buildMainCategoryButtons(),
          ],

          // 세부 카테고리 선택 (두 번째 단계)
          if (currentMainCategory != null && currentSubCategory == null) ...[
            _buildSectionTitle('카테고리를 선택해주세요'),
            const SizedBox(height: 16),
            _buildSubCategoryButtons(),
            const SizedBox(height: 16),
            _buildBackButton(() => onMainCategorySelected('')),
          ],

          // 연령대 선택 (세 번째 단계) - 패션쇼핑일 때만
          if (currentMainCategory == '추천' &&
              currentSubCategory == '패션쇼핑' &&
              currentAgeGroup == null) ...[
            _buildSectionTitle('연령대를 선택해주세요'),
            const SizedBox(height: 16),
            _buildAgeGroupButtons(),
            const SizedBox(height: 16),
            _buildBackButton(() => onSubCategorySelected('')),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildMainCategoryButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildMainChoiceButton(
            '추천',
            Icons.recommend_rounded,
            const Color(0xFF6366F1),
            // '개인화된 추천',
            // 'AI가 당신의 취향을 분석하여\n맞춤형 추천을 제공합니다','개인화된 추천',
            // 'AI가 당신의 취향을 분석하여\n맞춤형 추천을 제공합니다',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMainChoiceButton(
            '보고서',
            Icons.analytics_rounded,
            const Color(0xFF10B981),
            // '데이터 분석',
            // '트렌드와 인사이트를\n기반으로 한 보고서',
          ),
        ),
      ],
    );
  }

  Widget _buildSubCategoryButtons() {
    if (currentMainCategory == '추천') {
      return _buildRecommendationSubCategories();
    } else if (currentMainCategory == '보고서') {
      return _buildReportSubCategories();
    }

    return const SizedBox.shrink();
  }

  Widget _buildAgeGroupButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildAgeGroupButton(
            '20대',
            'TWENTY',
            Icons.person_rounded,
            const Color(0xFF3B82F6),
            '젊은 감각의 패션',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildAgeGroupButton(
            '30대',
            'THIRTY',
            Icons.person_rounded,
            const Color(0xFF8B5CF6),
            '세련된 스타일',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildAgeGroupButton(
            '40대',
            'FORTY',
            Icons.person_rounded,
            const Color(0xFFEF4444),
            '클래식한 패션',
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationSubCategories() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildSubChoiceButton(
          '패션쇼핑',
          Icons.shopping_bag_rounded,
          const Color(0xFFF59E0B),
          // '의류, 신발, 액세서리',
        ),
        _buildSubChoiceButton(
          '성형/시술',
          Icons.medical_services_rounded,
          const Color(0xFFEC4899),
          // '병원, 클리닉, 시술',
        ),
        _buildSubChoiceButton(
          '뷰티',
          Icons.face_rounded,
          const Color(0xFF8B5CF6),
          // '화장품, 스킨케어',
        ),
        _buildSubChoiceButton(
          '음식/과일/식자재',
          Icons.restaurant_rounded,
          const Color(0xFFEF4444),
          // '레시피, 식재료',
        ),
      ],
    );
  }

  Widget _buildReportSubCategories() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildSubChoiceButton(
          '트렌드 분석',
          Icons.trending_up_rounded,
          const Color(0xFF3B82F6),
          // '시장 동향 분석',
        ),
        _buildSubChoiceButton(
          '소비 패턴',
          Icons.pie_chart_rounded,
          const Color(0xFF10B981),
          // '구매 행동 분석',
        ),
        _buildSubChoiceButton(
          '시장 동향',
          Icons.insights_rounded,
          const Color(0xFFF59E0B),
          // '업계 트렌드',
        ),
        _buildSubChoiceButton(
          '예측 리포트',
          Icons.auto_graph_rounded,
          const Color(0xFF8B5CF6),
          // '미래 전망',
        ),
      ],
    );
  }

  Widget _buildMainChoiceButton(
      String text,
      IconData icon,
      Color color
      ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onMainCategorySelected(text),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 28,
                    color: color,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                // Text(
                //   subtitle,
                //   style: TextStyle(
                //     fontSize: 12,
                //     fontWeight: FontWeight.w500,
                //     color: color.withOpacity(0.8),
                //   ),
                //   textAlign: TextAlign.center,
                // ),
                // const SizedBox(height: 8),
                // Text(
                //   // description,
                //   style: TextStyle(
                //     fontSize: 10,
                //     color: color.withOpacity(0.6),
                //     height: 1.3,
                //   ),
                //   textAlign: TextAlign.center,
                //   maxLines: 2,
                //   overflow: TextOverflow.ellipsis,
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubChoiceButton(
      String text,
      IconData icon,
      Color color,
      // String subtitle,
      ) {
    return Builder(
      builder: (context) => Container(
        width: (MediaQuery.of(context).size.width - 80) / 2,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.1),
              color.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onSubCategorySelected(text),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      size: 24,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  // const SizedBox(height: 2),
                  // Text(
                  //   subtitle,
                  //   style: TextStyle(
                  //     fontSize: 10,
                  //     color: color.withOpacity(0.7),
                  //   ),
                  //   textAlign: TextAlign.center,
                  //   maxLines: 1,
                  //   overflow: TextOverflow.ellipsis,
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAgeGroupButton(
      String text,
      String value,
      IconData icon,
      Color color,
      String subtitle,
      ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onAgeGroupSelected(value),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: color,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10,
                    color: color.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(VoidCallback onPressed) {
    return Center(
      child: TextButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.arrow_back_ios_rounded, size: 16),
        label: const Text('뒤로 가기'),
        style: TextButton.styleFrom(
          foregroundColor: Colors.grey[600],
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
} 