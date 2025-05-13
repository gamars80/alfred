import 'package:alfred_clean/features/like/model/liked_beauty_hospital.dart';


class PaginatedLikedBeautyHospital {
  final List<LikedBeautyHospital> content;
  final int page;
  final int size;
  final int totalPages;
  final int totalElements;

  PaginatedLikedBeautyHospital({
    required this.content,
    required this.page,
    required this.size,
    required this.totalPages,
    required this.totalElements,
  });

  factory PaginatedLikedBeautyHospital.fromJson(Map<String, dynamic> json) {
    final rawList = json['content'] as List<dynamic>;
    return PaginatedLikedBeautyHospital(
      content:
      rawList
          .map((e) => LikedBeautyHospital.fromJson(e as Map<String, dynamic>))
          .toList(),
      page: json['page'] as int,
      size: json['size'] as int,
      totalPages: json['totalPages'] as int,
      totalElements: json['totalElements'] as int,
    );
  }
}

