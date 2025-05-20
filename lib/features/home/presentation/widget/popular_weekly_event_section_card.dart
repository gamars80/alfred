// lib/features/home/presentation/widget/popular_weekly_event_section_card.dart
import 'package:flutter/material.dart';
import '../../data/popular_repository.dart';
import '../../model/popular_weekly_event.dart';
import 'popular_weekly_event_card.dart';

class PopularWeeklyEventSectionCard extends StatelessWidget {
  final List<PopularWeeklyEvent> events;

  const PopularWeeklyEventSectionCard({
    Key? key,
    required this.events,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            '이번주 조회 Top10 이벤트',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
        SizedBox(
          height: 220,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: events.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, index) {
              return PopularWeeklyEventCard(event: events[index]);
            },
          ),
        ),
      ],
    );
  }
}
