class Hospital {
  final int id;
  final String title;
  final String source;
  final String thumbnailUrl;
  final String location;
  final String hospitalName;
  final String rating;
  final int ratingCount;
  final int counselCount;
  final int doctorCount;
  final String description;
  final bool liked;

  Hospital({
    required this.id,
    required this.title,
    required this.source,
    required this.thumbnailUrl,
    required this.location,
    required this.hospitalName,
    required this.rating,
    required this.ratingCount,
    required this.counselCount,
    required this.doctorCount,
    required this.description,
    required this.liked,

  });

  factory Hospital.fromJson(Map<String, dynamic> json) {
    return Hospital(
      id: json['id'],
      title: json['title'],
      source: json['source'],
      thumbnailUrl: json['thumbnailUrl'],
      location: json['location'],
      hospitalName: json['hospitalName'],
      rating: json['rating'],
      ratingCount: json['ratingCount'],
      counselCount: json['counselCount'],
      doctorCount: json['doctorCount'],
      description: json['description'],
      liked: json['liked'] ?? false,
    );
  }

  Hospital copyWith({
    int? id,
    String? title,
    String? source,
    String? thumbnailUrl,
    String? location,
    String? hospitalName,
    String? rating,
    int? ratingCount,
    int? counselCount,
    int? doctorCount,
    String? description,
    bool? liked,
  }) {
    return Hospital(
      id: id ?? this.id,
      title: title ?? this.title,
      source: source ?? this.source,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      location: location ?? this.location,
      hospitalName: hospitalName ?? this.hospitalName,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      counselCount: counselCount ?? this.counselCount,
      doctorCount: doctorCount ?? this.doctorCount,
      description: description ?? this.description,
      liked: liked ?? this.liked,
    );
  }

}
