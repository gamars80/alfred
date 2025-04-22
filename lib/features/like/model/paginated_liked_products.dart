import 'liked_product.dart';

class PaginatedLikedProducts {
  final List<LikedProduct> content;
  final int page;
  final int size;
  final int totalPages;
  final int totalElements;

  PaginatedLikedProducts({
    required this.content,
    required this.page,
    required this.size,
    required this.totalPages,
    required this.totalElements,
  });

  factory PaginatedLikedProducts.fromJson(Map<String, dynamic> json) {
    final rawList = json['content'] as List<dynamic>;
    return PaginatedLikedProducts(
      content: rawList
          .map((e) => LikedProduct.fromJson(e as Map<String, dynamic>))
          .toList(),
      page:          json['page'] as int,
      size:          json['size'] as int,
      totalPages:    json['totalPages'] as int,
      totalElements: json['totalElements'] as int,
    );
  }
}
