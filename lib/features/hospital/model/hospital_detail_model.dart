class HospitalDetailResponse {
  final List<String> hospitalImages;
  final List<Event> events;
  final List<Review> reviews;
  final List<Doctor> doctors;

  HospitalDetailResponse({
    required this.hospitalImages,
    required this.events,
    required this.reviews,
    required this.doctors,
  });

  factory HospitalDetailResponse.fromJson(Map<String, dynamic> json) {
    return HospitalDetailResponse(
      hospitalImages: List<String>.from(json['hospitalImages'] ?? []),
      events: (json['events'] as List).map((e) => Event.fromJson(e)).toList(),
      reviews: (json['reviews'] as List).map((e) => Review.fromJson(e)).toList(),
      doctors: (json['doctors'] as List).map((e) => Doctor.fromJson(e)).toList(),
    );
  }
}

// 참고로 Event/Review/Doctor 모델도 아래와 같이 분리해서 생성
class Event {
  final String name;
  final String image;
  final double rating;
  final int reviewCount;
  final int discountPrice;

  Event({
    required this.name,
    required this.image,
    required this.rating,
    required this.reviewCount,
    required this.discountPrice,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      name: json['name'],
      image: json['image'],
      rating: json['rating'].toDouble(),
      reviewCount: json['review_count'],
      discountPrice: json['discount_price'],
    );
  }
}

class Review {
  final String text;
  final int rating;
  final List<String> images;

  Review({
    required this.text,
    required this.rating,
    required this.images,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      text: json['text'],
      rating: json['rating'],
      images: (json['images'] as List).map((e) => e['url'] as String).toList(),
    );
  }
}

class Doctor {
  final String name;
  final String specialist;
  final String profilePhoto;

  Doctor({
    required this.name,
    required this.specialist,
    required this.profilePhoto,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      name: json['name'],
      specialist: json['specialist'],
      profilePhoto: json['profile_photo'],
    );
  }
}
