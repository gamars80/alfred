import 'package:alfred_clean/features/home/presentation/widget/popular_beauty_hospital_section_card.dart';
import 'package:alfred_clean/features/home/presentation/widget/popular_community_section_card.dart';
import 'package:alfred_clean/features/home/presentation/widget/popular_event_section_card.dart';
import 'package:flutter/material.dart';


class SurgeryTab extends StatelessWidget {
  const SurgeryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: const [
        PopularCommunitySectionCard(),
        SizedBox(height: 16),
        Divider(height: 1, thickness: 0.5, indent: 16, endIndent: 16, color: Colors.grey),
        SizedBox(height: 16),
        PopularEventSectionCard(),
        SizedBox(height: 32),
        PopularBeautyHospitalSectionCard(), // ✅ 추가됨
        SizedBox(height: 32),
      ],
    );
  }
}
