class Review {
  final int rating;
  final List<String> selectedOptions;
  final String content;
  final List<String> imageUrls;

  Review({
    required this.rating,
    required this.selectedOptions,
    required this.content,
    required this.imageUrls,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      rating: json['rating'] ?? 0,
      selectedOptions: json['selectedOptions'] != null 
          ? List<String>.from(json['selectedOptions'])
          : <String>[],
      content: json['content'] ?? '',
      imageUrls: json['imageUrls'] != null 
          ? List<String>.from(json['imageUrls'])
          : <String>[],
    );
  }
}

