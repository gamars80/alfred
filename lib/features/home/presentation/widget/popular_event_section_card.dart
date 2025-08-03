import 'package:flutter/material.dart';
import '../../data/popular_repository.dart';
import '../../model/popular_event.dart';
import '../widget/popular_event_card.dart';

class PopularEventSectionTheme {
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

class PopularEventSectionCard extends StatefulWidget {
  const PopularEventSectionCard({super.key, required List<PopularEvent> events});

  @override
  State<PopularEventSectionCard> createState() => _PopularEventSectionCardState();
}

class _PopularEventSectionCardState extends State<PopularEventSectionCard> {
  final repo = PopularRepository();
  Future<List<PopularEvent>>? futureEvents;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  void _loadEvents() {
    if (futureEvents == null) {
      futureEvents = repo.fetchPopularEvents();
    }
  }

  Widget _buildModernHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, PopularEventSectionTheme.sectionSpacing, 20, 16),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  PopularEventSectionTheme.primaryGradientStart,
                  PopularEventSectionTheme.primaryGradientEnd,
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
                const Text(
                  '시술 이벤트 찜 Top 10',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '가장 인기있는 시술 이벤트',
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
                  PopularEventSectionTheme.primaryGradientStart.withOpacity(0.1),
                  PopularEventSectionTheme.primaryGradientEnd.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: PopularEventSectionTheme.primaryGradientStart.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.event_rounded,
              color: Color(0xFF667eea),
              size: 24,
            ),
          ),
        ],
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
            PopularEventSectionTheme.backgroundColor,
            Color(0xFFF1F5F9),
          ],
        ),
      ),
      child: Column(
        children: [
          _buildModernHeader(),
          
          // 이벤트 리스트
          SizedBox(
            height: 300,
            child: FutureBuilder<List<PopularEvent>>(
              future: futureEvents,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('에러: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('데이터 없음'));
                }

                final events = snapshot.data!;
                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: events.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return PopularEventCard(event: event, rank: index + 1);
                  },
                );
              },
            ),
          ),
          
          const SizedBox(height: PopularEventSectionTheme.sectionSpacing),
        ],
      ),
    );
  }
}
