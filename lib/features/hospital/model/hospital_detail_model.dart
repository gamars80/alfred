class HospitalDetailResponse {
  final List<String> hospitalImages;
  final List<Event> events;
  final List<Review> reviews;
  final List<Doctor> doctors;
  final List<Youtube> youtubes;

  HospitalDetailResponse({
    required this.hospitalImages,
    required this.events,
    required this.reviews,
    required this.doctors,
    required this.youtubes,
  });

  factory HospitalDetailResponse.fromJson(Map<String, dynamic> json) {
    return HospitalDetailResponse(
      hospitalImages: List<String>.from(json['hospitalImages'] ?? []),
      events: (json['events'] as List).map((e) => Event.fromJson(e)).toList(),
      reviews: (json['reviews'] as List).map((e) => Review.fromJson(e)).toList(),
      doctors: (json['doctors'] as List).map((e) => Doctor.fromJson(e)).toList(),
      youtubes: (json['youtubes'] as List?)?.map((e) => Youtube.fromJson(e)).toList() ?? [],
    );
  }
}

// 참고로 Event/Review/Doctor 모델도 아래와 같이 분리해서 생성
class Event {
  final String name;
  final String image;
  final String? bannerImage;
  final double rating;
  final int reviewCount;
  final int discountPrice;
  final int discountRate;


  Event({
    required this.name,
    required this.image,
    required this.bannerImage,
    required this.rating,
    required this.reviewCount,
    required this.discountPrice,
    required this.discountRate,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      name: json['name'],
      image: json['image'],
      bannerImage: json['banner_image'],
      rating: json['rating'].toDouble(),
      reviewCount: json['review_count'],
      discountPrice: json['discount_price'],
      discountRate: json['discount_rate'],
    );
  }
}

class Review {
  final String text;
  final int rating;
  final List<String> images;
  final List<String> subCategories;

  Review({
    required this.text,
    required this.rating,
    required this.images,
    required this.subCategories,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      text: json['text'],
      rating: json['rating'],
      images: (json['images'] as List).map((e) => e['url'] as String).toList(),
      subCategories: (json['sub_categories'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          [],
    );
  }
}

class Doctor {
  final String name;
  final String position;
  final String? specialist;
  final String profilePhoto;
  final List<String> subject;
  final int reviewCount;
  final int askCount;
  final int qnaAnswerCount;

  Doctor({
    required this.name,
    required this.position,
    required this.specialist,
    required this.profilePhoto,
    required this.subject,
    required this.reviewCount,
    required this.askCount,
    required this.qnaAnswerCount,
  });
  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      name: json['name'],
      position: json['position'],
      specialist: json['specialist'] as String?,
      profilePhoto: json['profile_photo'],
      subject: (json['subject'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          [],
      reviewCount: json['review_count'] is int
          ? json['review_count']
          : int.tryParse(json['review_count'].toString()) ?? 0,
      askCount: json['ask_count'] is int
          ? json['ask_count']
          : int.tryParse(json['ask_count'].toString()) ?? 0,
      qnaAnswerCount: json['qna_answer_count'] is int
          ? json['qna_answer_count']
          : int.tryParse(json['qna_answer_count'].toString()) ?? 0,
    );
  }
}


class Youtube {
  final String title;
  final String description;
  final String videoId;
  final String playlistId;
  final String thumbnails;

  Youtube({
    required this.title,
    required this.description,
    required this.videoId,
    required this.playlistId,
    required this.thumbnails,
  });
  factory Youtube.fromJson(Map<String, dynamic> json) {
    return Youtube(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      videoId: json['video_id'] ?? '',
      playlistId: json['playlist_id'] ?? '',
      thumbnails: json['thumbnails'] ?? '',
    );
  }
}