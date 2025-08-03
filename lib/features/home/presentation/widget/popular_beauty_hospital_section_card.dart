import 'package:flutter/material.dart';
import '../../data/popular_repository.dart';
import '../../model/popular_beauty_hospital.dart';
import 'popular_beauty_hospital_card.dart';

class PopularBeautyHospitalSectionTheme {
  // 뷰티다운 우아한 색상 팔레트
  static const Color primaryColor = Color(0xFFE91E63); // 핑크
  static const Color secondaryColor = Color(0xFFF06292); // 연한 핑크
  static const Color accentColor = Color(0xFFFFC0CB); // 라이트 핑크
  static const Color elegantBackground = Color(0xFFFFF5F7); // 우아한 크림색
  static const Color textColor = Color(0xFF2D3748);
  static const Color subtitleColor = Color(0xFF718096);
  
  // 섹션 스타일
  static const double sectionRadius = 20.0;
  static const double headerRadius = 16.0;
  
  // 섹션 배경 그라데이션
  static const LinearGradient sectionGradient = LinearGradient(
    colors: [Color(0xFFFFF5F7), Color(0xFFFFF0F3)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // 헤더 그라데이션
  static const LinearGradient headerGradient = LinearGradient(
    colors: [Color(0xFFE91E63), Color(0xFFF06292)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // 그림자 효과
  static const List<BoxShadow> sectionShadow = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 16,
      offset: Offset(0, 8),
    ),
    BoxShadow(
      color: Color(0x0AE91E63),
      blurRadius: 24,
      offset: Offset(0, 12),
    ),
  ];
}

class PopularBeautyHospitalSectionCard extends StatefulWidget {
  const PopularBeautyHospitalSectionCard({super.key, required List<PopularBeautyHospital> hospitals});

  @override
  State<PopularBeautyHospitalSectionCard> createState() => _PopularBeautyHospitalSectionCardState();
}

class _PopularBeautyHospitalSectionCardState extends State<PopularBeautyHospitalSectionCard> {
  final repo = PopularRepository();
  Future<List<PopularBeautyHospital>>? futureHospitals;

  @override
  void initState() {
    super.initState();
    _loadHospitals();
  }

  void _loadHospitals() {
    if (futureHospitals == null) {
      futureHospitals = repo.fetchPopularBeautyHospitals();
    }
  }

  Widget _buildModernHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, PopularBeautyHospitalSectionTheme.sectionRadius, 20, 16),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 32,
            decoration: BoxDecoration(
              gradient: PopularBeautyHospitalSectionTheme.headerGradient,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '시술 병원 찜 Top 10',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: PopularBeautyHospitalSectionTheme.textColor,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '가장 많은 추천을 받은 병원',
                  style: TextStyle(
                    fontSize: 14,
                    color: PopularBeautyHospitalSectionTheme.subtitleColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  PopularBeautyHospitalSectionTheme.primaryColor.withOpacity(0.1),
                  PopularBeautyHospitalSectionTheme.secondaryColor.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(PopularBeautyHospitalSectionTheme.headerRadius),
              boxShadow: [
                BoxShadow(
                  color: PopularBeautyHospitalSectionTheme.primaryColor.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.local_hospital_rounded,
              size: 24,
              color: PopularBeautyHospitalSectionTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonLoading() {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(width: 16),
      itemBuilder: (_, __) => Container(
        width: 200,
        decoration: BoxDecoration(
          color: PopularBeautyHospitalSectionTheme.elegantBackground,
          borderRadius: BorderRadius.circular(PopularBeautyHospitalSectionTheme.sectionRadius),
          boxShadow: PopularBeautyHospitalSectionTheme.sectionShadow,
        ),
        child: Column(
          children: [
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: PopularBeautyHospitalSectionTheme.secondaryColor.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 14,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: PopularBeautyHospitalSectionTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 12,
                    width: 120,
                    decoration: BoxDecoration(
                      color: PopularBeautyHospitalSectionTheme.subtitleColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: PopularBeautyHospitalSectionTheme.elegantBackground,
        borderRadius: BorderRadius.circular(PopularBeautyHospitalSectionTheme.sectionRadius),
        boxShadow: PopularBeautyHospitalSectionTheme.sectionShadow,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: PopularBeautyHospitalSectionTheme.headerGradient,
              borderRadius: BorderRadius.circular(PopularBeautyHospitalSectionTheme.headerRadius),
            ),
            child: Icon(
              Icons.local_hospital_rounded,
              size: 48,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '병원 정보를 불러올 수 없습니다',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: PopularBeautyHospitalSectionTheme.textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '잠시 후 다시 시도해주세요',
            style: TextStyle(
              fontSize: 14,
              color: PopularBeautyHospitalSectionTheme.subtitleColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: PopularBeautyHospitalSectionTheme.elegantBackground,
        borderRadius: BorderRadius.circular(PopularBeautyHospitalSectionTheme.sectionRadius),
        boxShadow: PopularBeautyHospitalSectionTheme.sectionShadow,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: PopularBeautyHospitalSectionTheme.headerGradient,
              borderRadius: BorderRadius.circular(PopularBeautyHospitalSectionTheme.headerRadius),
            ),
            child: Icon(
              Icons.favorite_rounded,
              size: 48,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '아직 인기 병원이 없습니다',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: PopularBeautyHospitalSectionTheme.textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '이번주 인기 병원을 기다려주세요',
            style: TextStyle(
              fontSize: 14,
              color: PopularBeautyHospitalSectionTheme.subtitleColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: PopularBeautyHospitalSectionTheme.sectionGradient,
        borderRadius: BorderRadius.circular(PopularBeautyHospitalSectionTheme.sectionRadius),
        boxShadow: PopularBeautyHospitalSectionTheme.sectionShadow,
      ),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        children: [
          _buildModernHeader(),
          
          // 병원 리스트
          SizedBox(
            height: 340,
            child: FutureBuilder<List<PopularBeautyHospital>>(
              future: futureHospitals,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildSkeletonLoading();
                }
                
                if (snapshot.hasError) {
                  return _buildErrorState();
                }
                
                final hospitals = snapshot.data ?? [];
                if (hospitals.isEmpty) {
                  return _buildEmptyState();
                }
                
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  itemCount: hospitals.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    return PopularBeautyHospitalCard(
                      hospital: hospitals[index],
                      rank: index + 1,
                    );
                  },
                );
              },
            ),
          ),
          
          const SizedBox(height: PopularBeautyHospitalSectionTheme.sectionRadius),
        ],
      ),
    );
  }
}
