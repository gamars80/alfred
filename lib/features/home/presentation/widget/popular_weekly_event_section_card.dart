// lib/features/home/presentation/widget/popular_weekly_event_section_card.dart
import 'package:flutter/material.dart';
import '../../data/popular_repository.dart';
import '../../model/popular_weekly_event.dart';
import 'popular_weekly_event_card.dart';

class PopularWeeklyEventSectionCard extends StatefulWidget {
  const PopularWeeklyEventSectionCard({super.key, required List<PopularWeeklyEvent> events});

  @override
  State<PopularWeeklyEventSectionCard> createState() => _PopularWeeklyEventSectionCardState();
}

class _PopularWeeklyEventSectionCardState extends State<PopularWeeklyEventSectionCard> {
  late Future<List<PopularWeeklyEvent>> futureEvents;

  @override
  void initState() {
    super.initState();
    futureEvents = PopularRepository().fetchPopularWeeklyEvents();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PopularWeeklyEvent>>(
      future: futureEvents,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final events = snapshot.data!;
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
      },
    );
  }
}
