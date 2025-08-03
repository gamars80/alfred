// lib/features/home/presentation/home_screen.dart
import 'package:alfred_clean/features/home/presentation/surgery_tab.dart';
import 'package:alfred_clean/features/home/presentation/widget/weekly_top_keyword_section.dart';
import 'package:alfred_clean/features/home/presentation/widget/weekly_top_product_section.dart';
import 'package:flutter/material.dart';
import 'popular_section.dart';
import 'package:alfred_clean/features/home/presentation/widget/weekly_top_food_command_section.dart';
import 'package:alfred_clean/features/home/presentation/widget/weekly_top_food_product_section.dart';
import 'package:alfred_clean/features/home/presentation/widget/weekly_top_recipe_section.dart';
import 'package:alfred_clean/features/home/presentation/widget/weekly_top_care_keyword_section.dart';
import 'package:alfred_clean/features/home/presentation/widget/weekly_top_care_product_section.dart';
import 'package:alfred_clean/features/home/presentation/widget/popular_care_like_section.dart';

class HomeScreenTheme {
  // 색상 팔레트
  static const Color primaryGradientStart = Color(0xFF667eea);
  static const Color primaryGradientEnd = Color(0xFF764ba2);
  static const Color secondaryGradientStart = Color(0xFFf093fb);
  static const Color secondaryGradientEnd = Color(0xFFf5576c);
  static const Color accentGradientStart = Color(0xFF4facfe);
  static const Color accentGradientEnd = Color(0xFF00f2fe);
  
  // 탭 색상
  static const Color tabSelectedColor = Color(0xFF667eea);
  static const Color tabUnselectedColor = Color(0xFF9CA3AF);
  static const Color tabBackgroundColor = Color(0xFFF8FAFC);
  
  // 간격
  static const double spacing = 16.0;
  static const double cardRadius = 20.0;
  static const double tabHeight = 60.0;
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  static const List<Tab> tabs = [
    Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 18),
          SizedBox(width: 6),
          Text('패션쇼핑', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    ),
    Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.face_retouching_natural, size: 18),
          SizedBox(width: 6),
          Text('시술성형', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    ),
    Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.restaurant, size: 18),
          SizedBox(width: 6),
          Text('음식/식자재', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    ),
    Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.spa, size: 18),
          SizedBox(width: 6),
          Text('뷰티', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    ),
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

  Widget _buildModernHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            HomeScreenTheme.primaryGradientStart,
            HomeScreenTheme.primaryGradientEnd,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: HomeScreenTheme.primaryGradientStart.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.home_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '알프레드',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'AI가 추천하는 맞춤 콘텐츠',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.notifications_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernTabBar() {
    return Container(
      height: HomeScreenTheme.tabHeight,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: HomeScreenTheme.tabBackgroundColor,
        borderRadius: BorderRadius.circular(HomeScreenTheme.cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              HomeScreenTheme.primaryGradientStart,
              HomeScreenTheme.primaryGradientEnd,
            ],
          ),
          borderRadius: BorderRadius.circular(HomeScreenTheme.cardRadius - 4),
          boxShadow: [
            BoxShadow(
              color: HomeScreenTheme.primaryGradientStart.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        labelColor: Colors.white,
        unselectedLabelColor: HomeScreenTheme.tabUnselectedColor,
        labelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        isScrollable: true,
        labelPadding: const EdgeInsets.symmetric(horizontal: 12),
        tabs: tabs,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          _buildModernHeader(),
          _buildModernTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                FashionShoppingTab(),
                SurgeryTab(),
                FoodShoppingTab(),
                BeautyTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 🛍️ 패션쇼핑 탭 콘텐츠
class FashionShoppingTab extends StatelessWidget {
  const FashionShoppingTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF8FAFC),
            Color(0xFFF1F5F9),
          ],
        ),
      ),
      child: ListView(
        padding: EdgeInsets.zero,
        children: const [
          WeeklyTopKeywordSection(),
          WeeklyTopProductSection(),
          PopularSection(),
        ],
      ),
    );
  }
}

// 🍽️ 음식/식자재 탭 콘텐츠
class FoodShoppingTab extends StatelessWidget {
  const FoodShoppingTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF8FAFC),
            Color(0xFFF1F5F9),
          ],
        ),
      ),
      child: ListView(
        padding: EdgeInsets.zero,
        children: const [
          WeeklyTopFoodCommandSection(),
          WeeklyTopFoodProductSection(),
          WeeklyTopRecipeSection(),
        ],
      ),
    );
  }
}

// 💄 뷰티 탭 콘텐츠
class BeautyTab extends StatelessWidget {
  const BeautyTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF8FAFC),
            Color(0xFFF1F5F9),
          ],
        ),
      ),
      child: ListView(
        padding: EdgeInsets.zero,
        children: const [
          WeeklyTopCareKeywordSection(),
          WeeklyTopCareProductSection(),
          PopularCareLikeSection(),
        ],
      ),
    );
  }
}
