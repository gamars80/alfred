class Event {
  final String id;
  final String title;
  final int price;
  final String? imageUrl;
  final DateTime? startDate;
  final DateTime? endDate;

  Event({
    required this.id,
    required this.title,
    required this.price,
    this.imageUrl,
    this.startDate,
    this.endDate,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] as String,
      title: json['title'] as String,
      price: json['price'] as int,
      imageUrl: json['imageUrl'] as String?,
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
    );
  }
} 