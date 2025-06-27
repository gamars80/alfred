// ✅ 1. 좋아요 전체 화면 구조 (탭 기반)
import 'package:alfred_clean/features/like/presentation/widget/beauty_community_liked_tab.dart';
import 'package:alfred_clean/features/like/presentation/widget/beauty_event_liked_tab.dart';
import 'package:alfred_clean/features/like/presentation/widget/beauty_hospital_liked_tab.dart';
import 'package:alfred_clean/features/like/presentation/widget/care_liked_tab.dart';
import 'package:alfred_clean/features/like/presentation/widget/food_liked_tab.dart';
import 'package:alfred_clean/features/like/presentation/widget/product_liked_tab.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LikedProductScreen extends StatefulWidget {
  const LikedProductScreen({super.key});

  @override
  State<LikedProductScreen> createState() => _LikedProductScreenState();
}

class _LikedProductScreenState extends State<LikedProductScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final List<Tab> _tabs = const [
    Tab(text: '패션'),
    Tab(text: '시술 커뮤니티'),
    Tab(text: '시술 이벤트'),
    Tab(text: '시술 병원'),
    Tab(text: '뷰티케어'),
    Tab(text: '음식/식자재'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget buildCustomTabBar(BuildContext context) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(_tabs.length, (index) {
            final selected = _tabController.index == index;
            return GestureDetector(
              onTap: () => setState(() => _tabController.index = index),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                child: Text(
                  _tabs[index].text!,
                  style: GoogleFonts.notoSans(
                    fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 14,
                    color: selected ? const Color(0xFF1A1A1A) : Colors.grey,
                  ),
                ),
              ),
            );
          }),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          '찜한 항목',
          style: GoogleFonts.notoSans(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: const Color(0xFF1A1A1A),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildCustomTabBar(context),
          const Divider(height: 1, thickness: 1, color: Color(0xFFE0E0E0)),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                FashionLikedTab(),
                BeautyCommunityLikedTab(),
                BeautyEventLikedTab(),
                BeautyHospitalLikedTab(),
                CareLikedTab(),
                FoodLikedTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
