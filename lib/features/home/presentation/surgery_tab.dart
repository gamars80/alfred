// lib/features/home/presentation/surgery_tab.dart

import 'package:flutter/material.dart';
import '../data/popular_repository.dart';
import '../model/popular_community.dart';
import '../model/popular_event.dart';
import '../model/popular_beauty_hospital.dart';
import '../model/popular_weekly_event.dart'; // ✅ 추가
import 'widget/popular_community_section_card.dart';
import 'widget/popular_event_section_card.dart';
import 'widget/popular_beauty_hospital_section_card.dart';
import 'widget/popular_weekly_event_section_card.dart'; // ✅ 추가

class SurgeryTab extends StatefulWidget {
  const SurgeryTab({super.key});

  @override
  State<SurgeryTab> createState() => _SurgeryTabState();
}

class _SurgeryTabState extends State<SurgeryTab> {
  final _repo = PopularRepository();
  late Future<List<PopularWeeklyEvent>> _futureWeeklyEvents; // ✅ 추가
  late Future<List<PopularCommunity>> _futureCommunities;
  late Future<List<PopularEvent>> _futureEvents;
  late Future<List<PopularBeautyHospital>> _futureHospitals;

  @override
  void initState() {
    super.initState();
    _futureWeeklyEvents = _repo.fetchPopularWeeklyEvents(); // ✅ 추가
    _futureCommunities = _repo.fetchPopularCommunities();
    _futureEvents      = _repo.fetchPopularEvents();
    _futureHospitals   = _repo.fetchPopularBeautyHospitals();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // ✅ 0) 이번주 조회 Top 10 병원 섹션
        FutureBuilder<List<PopularWeeklyEvent>>(
          future: _futureWeeklyEvents,
          builder: (ctx, snap) {
            if (snap.hasData && snap.data!.isNotEmpty) {
              return Column(
                children: [
                  PopularWeeklyEventSectionCard(events: snap.data!), // ✅ 커스텀 위젯 활용
                  const SizedBox(height: 16),
                  const Divider(
                    height: 1, thickness: 0.5,
                    indent: 16, endIndent: 16, color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),

        // 1) 찜 커뮤니티 섹션
        FutureBuilder<List<PopularCommunity>>(
          future: _futureCommunities,
          builder: (ctx, snap) {
            if (snap.hasData && snap.data!.isNotEmpty) {
              return Column(
                children: [
                  PopularCommunitySectionCard(communities: snap.data!),
                  const SizedBox(height: 16),
                  const Divider(
                    height: 1, thickness: 0.5,
                    indent: 16, endIndent: 16, color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                ],
              );
            }
            return const SizedBox.shrink();
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
                  const SizedBox(height: 32),
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
                  const SizedBox(height: 32),
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
