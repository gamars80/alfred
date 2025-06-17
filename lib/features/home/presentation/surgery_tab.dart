// lib/features/home/presentation/surgery_tab.dart

import 'package:flutter/material.dart';
import '../data/popular_repository.dart';
import '../model/popular_community.dart';
import '../model/popular_event.dart';
import '../model/popular_beauty_hospital.dart';
import '../model/popular_weekly_event.dart'; // ✅ 추가
import '../model/popular_beauty_keyword.dart';
import 'widget/popular_community_section_card.dart';
import 'widget/popular_event_section_card.dart';
import 'widget/popular_beauty_hospital_section_card.dart';
import 'widget/popular_weekly_event_section_card.dart'; // ✅ 추가
import 'widget/popular_beauty_keyword_section_card.dart';

class SurgeryTab extends StatefulWidget {
  const SurgeryTab({super.key});

  @override
  State<SurgeryTab> createState() => _SurgeryTabState();
}

class _SurgeryTabState extends State<SurgeryTab> {
  final _repo = PopularRepository();
  
  // Remove late keyword and initialize directly
  final Future<List<PopularBeautyKeyword>> _futureKeywords;
  final Future<List<PopularWeeklyEvent>> _futureWeeklyEvents;
  final Future<List<PopularCommunity>> _futureCommunities;
  final Future<List<PopularEvent>> _futureEvents;
  final Future<List<PopularBeautyHospital>> _futureHospitals;

  // Initialize in constructor
  _SurgeryTabState()
      : _futureKeywords = PopularRepository().fetchWeeklyTopBeautyKeywords(),
        _futureWeeklyEvents = PopularRepository().fetchPopularWeeklyEvents(),
        _futureCommunities = PopularRepository().fetchPopularCommunities(),
        _futureEvents = PopularRepository().fetchPopularEvents(),
        _futureHospitals = PopularRepository().fetchPopularBeautyHospitals();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // ✨ 0) 이번주 인기 키워드 Top 10
        FutureBuilder<List<PopularBeautyKeyword>>(
          future: _futureKeywords,
          builder: (ctx, snap) {
            if (!snap.hasData || snap.data!.isEmpty) {
              return const SizedBox.shrink();
            }
            return Column(
              children: [
                PopularBeautyKeywordSectionCard(keywords: snap.data!),
                Divider(
                  height: 16,
                  thickness: 1,
                  indent: 16,
                  endIndent: 16,
                  color: Colors.grey.shade100,
                ),
              ],
            );
          },
        ),

        // ✅ 0) 이번주 조회 Top 10 병원 섹션
        // ––––– 이번주 조회 Top10 이벤트 –––––
        FutureBuilder<List<PopularWeeklyEvent>>(
          future: _futureWeeklyEvents,
          builder: (ctx, snap) {
            if (!snap.hasData || snap.data!.isEmpty) {
              return const SizedBox.shrink();
            }
            return Column(
              children: [
                PopularWeeklyEventSectionCard(events: snap.data!),
                Divider(
                  height: 16,
                  thickness: 1,
                  indent: 16,
                  endIndent: 16,
                  color: Colors.grey.shade100,
                ),
              ],
            );
          },
        ),

        // 1) 찜 커뮤니티 섹션
        FutureBuilder<List<PopularCommunity>>(
          future: _futureCommunities,
          builder: (ctx, snap) {
            if (!snap.hasData || snap.data!.isEmpty) {
              return const SizedBox.shrink();
            }
            return Column(
              children: [
                PopularCommunitySectionCard(communities: snap.data!),
                Divider(
                  height: 16,
                  thickness: 1,
                  indent: 16,
                  endIndent: 16,
                  color: Colors.grey.shade100,
                ),
              ],
            );
          },
        ),

        // 2) 찜 시술 이벤트 섹션
        FutureBuilder<List<PopularEvent>>(
          future: _futureEvents,
          builder: (ctx, snap) {
            if (snap.hasData && snap.data!.isNotEmpty) {
              return Column(
                children: [
                  PopularEventSectionCard(events: snap.data!),
                  const SizedBox(height: 16),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),

        // 3) 찜 병원 Top 10 섹션
        FutureBuilder<List<PopularBeautyHospital>>(
          future: _futureHospitals,
          builder: (ctx, snap) {
            if (snap.hasData && snap.data!.isNotEmpty) {
              return Column(
                children: [
                  PopularBeautyHospitalSectionCard(hospitals: snap.data!),
                  const SizedBox(height: 16),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}
