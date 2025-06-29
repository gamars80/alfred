class PopularCareKeyword {
  final String keyword;
  final int count;

  PopularCareKeyword({
    required this.keyword,
    required this.count,
  });

  factory PopularCareKeyword.fromJson(Map<String, dynamic> json) {
    return PopularCareKeyword(
      keyword: json['keyword'] ?? '',
      count: json['count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'keyword': keyword,
      'count': count,
    };
  }
} 