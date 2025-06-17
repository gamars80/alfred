// ✅ 1. 좋아요 전체 화면 구조 (탭 기반)
import 'package:alfred_clean/features/like/presentation/widget/beauty_community_liked_tab.dart';
import 'package:alfred_clean/features/like/presentation/widget/beauty_event_liked_tab.dart';
import 'package:alfred_clean/features/like/presentation/widget/beauty_hospital_liked_tab.dart';
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
    Tab(text: '음식/식자재'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            alignment: Alignment.centerLeft,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabs: _tabs,
              labelStyle: GoogleFonts.notoSans(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              indicatorColor: const Color(0xFF1A1A1A),
              labelColor: const Color(0xFF1A1A1A),
              unselectedLabelColor: Colors.grey,
              indicatorWeight: 2,
              padding: EdgeInsets.zero,
              labelPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          FashionLikedTab(),
          BeautyCommunityLikedTab(),
          BeautyEventLikedTab(),
          BeautyHospitalLikedTab(),
          FoodLikedTab(),
        ],
      ),
    );
  }
}
