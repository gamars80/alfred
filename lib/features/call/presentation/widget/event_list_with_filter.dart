import 'package:flutter/material.dart';
import '../../model/event.dart';
import 'event_card.dart';

class EventListWithFilter extends StatefulWidget {
  final List<Event> allEvents;
  final int historyCreatedAt;

  const EventListWithFilter({
    Key? key,
    required this.allEvents,
    required this.historyCreatedAt,
  }) : super(key: key);

  @override
  State<EventListWithFilter> createState() => _EventListWithFilterState();
}

class _EventListWithFilterState extends State<EventListWithFilter> {
  String selectedSource = '강남언니'; // 초기 디폴트

  @override
  Widget build(BuildContext context) {
    final filteredEvents = widget.allEvents
        .where((event) => event.source == selectedSource)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSourceFilter(),
        const SizedBox(height: 12),
        if (filteredEvents.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('이벤트가 없습니다.', style: TextStyle(color: Colors.grey)),
          )
        else
          ...filteredEvents.map(
                (e) => EventCard(
              event: e,
              historyCreatedAt: widget.historyCreatedAt,
              onLikedChanged: (updated) {
                setState(() {
                  final index = widget.allEvents.indexWhere((ev) => ev.id == updated.id);
                  if (index != -1) widget.allEvents[index] = updated;
                });
              },
            ),
          ),
      ],
    );
  }

  Widget _buildSourceFilter() {
    return Row(
      children: [
        _buildFilterButton('강남언니'),
        const SizedBox(width: 8),
        _buildFilterButton('바비톡'),
      ],
    );
  }

  Widget _buildFilterButton(String source) {
    final isSelected = selectedSource == source;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedSource = source;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.deepPurple : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          source,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.black54,
          ),
        ),
      ),
    );
  }
}
