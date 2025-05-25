class PopularBeautyKeyword {
  final String keyword;
  final int count;

  const PopularBeautyKeyword({
    required this.keyword,
    required this.count,
  });

  factory PopularBeautyKeyword.fromJson(Map<String, dynamic> json) {
    return PopularBeautyKeyword(
      keyword: json['keyword'] as String,
      count: json['count'] as int,
    );
  }
} 