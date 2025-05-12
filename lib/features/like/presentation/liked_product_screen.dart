// ✅ 1. 좋아요 전체 화면 구조 (탭 기반)
import 'package:alfred_clean/features/like/presentation/widget/beauty_community_liked_tab.dart';
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
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        backgroundColor: const Color(0xFF121212),
        appBar: AppBar(
          title: Text(
            '찜한 항목',
            style: GoogleFonts.notoSans(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                labelStyle: GoogleFonts.notoSans(fontWeight: FontWeight.bold),
                indicatorColor: Colors.amber,
                labelColor: Colors.amber,
                unselectedLabelColor: Colors.white70,
                labelPadding: const EdgeInsets.only(left: 0, right: 12),
                padding: EdgeInsets.zero,
                tabs: _tabs,
              ),
            ),
          ),
          backgroundColor: Colors.black,
        ),
        body: TabBarView(
          controller: _tabController,
          children: const [
            FashionLikedTab(),
            BeautyCommunityLikedTab(),
            Center(
              child: Text(
                '시술 이벤트 좋아요 준비 중',
                style: TextStyle(color: Colors.white),
              ),
            ),
            Center(
              child: Text(
                '시술 병원 좋아요 준비 중',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
