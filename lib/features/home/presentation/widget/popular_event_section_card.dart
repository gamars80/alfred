import 'package:flutter/material.dart';
import '../../data/popular_repository.dart';
import '../../model/popular_event.dart';
import '../widget/popular_event_card.dart';

class PopularEventSectionCard extends StatefulWidget {
  const PopularEventSectionCard({super.key, required List<PopularEvent> events});

  @override
  State<PopularEventSectionCard> createState() => _PopularEventSectionCardState();
}

class _PopularEventSectionCardState extends State<PopularEventSectionCard> {
  final repo = PopularRepository();
  late Future<List<PopularEvent>> futureEvents;

  @override
  void initState() {
    super.initState();
    futureEvents = repo.fetchPopularEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            '찜 시술 이벤트 Top 10',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
          ),
        ),
        SizedBox(
          height: 250,
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
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: events.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final event = events[index];
                  return PopularEventCard(event: event, rank: index + 1);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
