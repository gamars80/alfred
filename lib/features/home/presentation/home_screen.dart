// lib/features/home/presentation/home_screen.dart
import 'package:alfred_clean/features/home/presentation/surgery_tab.dart';
import 'package:alfred_clean/features/home/presentation/widget/weekly_top_keyword_section.dart';
import 'package:alfred_clean/features/home/presentation/widget/weekly_top_product_section.dart';
import 'package:flutter/material.dart';
import 'popular_section.dart';
import 'package:alfred_clean/features/home/presentation/widget/weekly_top_food_command_section.dart';
import 'package:alfred_clean/features/home/presentation/widget/weekly_top_food_product_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  static const List<Tab> tabs = [
    Tab(icon: Icon(Icons.shopping_bag_outlined), text: '패션쇼핑'),
    Tab(icon: Icon(Icons.face_retouching_natural), text: '시술성형'),
    Tab(icon: Icon(Icons.restaurant), text: '음식/식자재'),
  ];
  
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
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
      body: NestedScrollView(
        headerSliverBuilder: (_, __) {
          return [
            SliverAppBar(
              title: const Text('홈'),
              centerTitle: true,
              pinned: true,
              floating: true,
              snap: true,
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0.5,
              bottom: TabBar(
                controller: _tabController,
                tabs: tabs,
                indicatorColor: Colors.black,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                isScrollable: true,
                labelPadding: const EdgeInsets.symmetric(horizontal: 16),
                tabAlignment: TabAlignment.start,
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: const [
            FashionShoppingTab(),
            SurgeryTab(), // ✅ 연결됨
            FoodShoppingTab(), // 음식/식자재 탭
          ],
        ),
      ),
    );
  }
}

// 🛍️ 패션쇼핑 탭 콘텐츠
class FashionShoppingTab extends StatelessWidget {
  const FashionShoppingTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: const [
        WeeklyTopKeywordSection(),
        WeeklyTopProductSection(),
        PopularSection(),
        // 👉 오늘의 추천, 히스토리 등 추가 가능
      ],
    );
  }
}

// 🍽️ 음식/식자재 탭 콘텐츠
class FoodShoppingTab extends StatelessWidget {
  const FoodShoppingTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: const [
        WeeklyTopFoodCommandSection(),
        WeeklyTopFoodProductSection(),
        // 👉 추가 섹션들 구현 예정
      ],
    );
  }
}
