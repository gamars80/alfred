class Event {
  final int id;
  final String title;
  final String thumbnailUrl;
  final String location;
  final String hospitalName;
  final int discountedPrice;
  final int discountRate;
  final double? rating;
  final int ratingCount;

  Event({
    required this.id,
    required this.title,
    required this.thumbnailUrl,
    required this.location,
    required this.hospitalName,
    required this.discountedPrice,
    required this.discountRate,
    this.rating,
    required this.ratingCount,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      title: json['title'],
      thumbnailUrl: json['thumbnailUrl'],
      location: json['location'],
      hospitalName: json['hospitalName'],
      discountedPrice: json['discountedPrice'],
      discountRate: json['discountRate'],
      rating: double.tryParse(json['rating']?.toString() ?? ''),
      ratingCount: json['ratingCount'],
    );
  }
}