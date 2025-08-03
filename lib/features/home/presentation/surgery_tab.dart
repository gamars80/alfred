// lib/features/home/presentation/surgery_tab.dart

import 'package:flutter/material.dart';
import 'package:alfred_clean/features/home/presentation/widget/popular_beauty_keyword_section_card.dart';
import 'package:alfred_clean/features/home/presentation/widget/popular_weekly_event_section_card.dart';
import 'package:alfred_clean/features/home/presentation/widget/popular_community_section_card.dart';
import 'package:alfred_clean/features/home/presentation/widget/popular_event_section_card.dart';
import 'package:alfred_clean/features/home/presentation/widget/popular_beauty_hospital_section_card.dart';
import 'package:alfred_clean/features/home/data/popular_repository.dart';
import 'package:alfred_clean/features/home/model/popular_beauty_keyword.dart';
import 'package:alfred_clean/features/home/model/popular_weekly_event.dart';
import 'package:alfred_clean/features/home/model/popular_community.dart';
import 'package:alfred_clean/features/home/model/popular_event.dart';
import 'package:alfred_clean/features/home/model/popular_beauty_hospital.dart';

class SurgeryTabTheme {
  // 색상 팔레트
  static const Color primaryGradientStart = Color(0xFF667eea);
  static const Color primaryGradientEnd = Color(0xFF764ba2);
  static const Color secondaryGradientStart = Color(0xFFf093fb);
  static const Color secondaryGradientEnd = Color(0xFFf5576c);
  static const Color accentGradientStart = Color(0xFF4facfe);
  static const Color accentGradientEnd = Color(0xFF00f2fe);
  
  // 배경 색상
  static const Color backgroundColor = Color(0xFFF8FAFC);
  static const Color cardBackgroundColor = Colors.white;
  
  // 간격
  static const double spacing = 16.0;
  static const double cardRadius = 20.0;
  static const double sectionSpacing = 24.0;
}

class SurgeryTab extends StatefulWidget {
  const SurgeryTab({super.key});

  @override
  State<SurgeryTab> createState() => _SurgeryTabState();
}

class _SurgeryTabState extends State<SurgeryTab> {
  final repo = PopularRepository();
  
  late Future<List<PopularBeautyKeyword>> futureKeywords;
  late Future<List<PopularWeeklyEvent>> futureWeeklyEvents;
  late Future<List<PopularCommunity>> futureCommunities;
  late Future<List<PopularEvent>> futureEvents;
  late Future<List<PopularBeautyHospital>> futureHospitals;

  @override
  void initState() {
    super.initState();
    futureKeywords = repo.fetchWeeklyTopBeautyKeywords();
    futureWeeklyEvents = repo.fetchPopularWeeklyEvents();
    futureCommunities = repo.fetchPopularCommunities();
    futureEvents = repo.fetchPopularEvents();
    futureHospitals = repo.fetchPopularBeautyHospitals();
  }

  Widget _buildModernSectionHeader(String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, SurgeryTabTheme.sectionSpacing, 20, 16),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  SurgeryTabTheme.primaryGradientStart,
                  SurgeryTabTheme.primaryGradientEnd,
                ],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
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
                  SurgeryTabTheme.primaryGradientStart.withOpacity(0.1),
                  SurgeryTabTheme.primaryGradientEnd.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: SurgeryTabTheme.primaryGradientStart.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.medical_services_rounded,
              color: Color(0xFF667eea),
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.grey[300]!,
            Colors.grey[200]!,
            Colors.grey[300]!,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            SurgeryTabTheme.backgroundColor,
            Color(0xFFF1F5F9),
          ],
        ),
      ),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // 인기 뷰티 키워드 - 데이터가 있을 때만 표시
          FutureBuilder<List<PopularBeautyKeyword>>(
            future: futureKeywords,
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const SizedBox.shrink();
              }
              return Column(
                children: [
                  PopularBeautyKeywordSectionCard(keywords: snapshot.data!),
                  _buildModernDivider(),
                ],
              );
            },
          ),
          
          // 주간 인기 이벤트 - 데이터가 있을 때만 표시
          FutureBuilder<List<PopularWeeklyEvent>>(
            future: futureWeeklyEvents,
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const SizedBox.shrink();
              }
              return Column(
                children: [
                  PopularWeeklyEventSectionCard(events: snapshot.data!),
                  _buildModernDivider(),
                ],
              );
            },
          ),
          
          // 인기 커뮤니티 - 데이터가 있을 때만 표시
          FutureBuilder<List<PopularCommunity>>(
            future: futureCommunities,
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const SizedBox.shrink();
              }
              return Column(
                children: [
                  PopularCommunitySectionCard(communities: snapshot.data!),
                  _buildModernDivider(),
                ],
              );
            },
          ),
          
          // 진행중인 이벤트 - 데이터가 있을 때만 표시
          FutureBuilder<List<PopularEvent>>(
            future: futureEvents,
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const SizedBox.shrink();
              }
              return Column(
                children: [
                  PopularEventSectionCard(events: snapshot.data!),
                  _buildModernDivider(),
                ],
              );
            },
          ),
          
          // 인기 뷰티 병원 - 데이터가 있을 때만 표시
          FutureBuilder<List<PopularBeautyHospital>>(
            future: futureHospitals,
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const SizedBox.shrink();
              }
              return Column(
                children: [
                  PopularBeautyHospitalSectionCard(hospitals: snapshot.data!),
                  const SizedBox(height: SurgeryTabTheme.sectionSpacing),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
