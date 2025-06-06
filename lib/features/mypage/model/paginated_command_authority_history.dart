import 'command_authority_history.dart';

class PaginatedCommandAuthorityHistory {
  final List<CommandAuthorityHistory> content;
  final int page;
  final int size;
  final int totalPages;
  final int totalElements;

  const PaginatedCommandAuthorityHistory({
    required this.content,
    required this.page,
    required this.size,
    required this.totalPages,
    required this.totalElements,
  });

  factory PaginatedCommandAuthorityHistory.fromJson(Map<String, dynamic> json) {
    return PaginatedCommandAuthorityHistory(
      content: (json['content'] as List)
          .map((e) => CommandAuthorityHistory.fromJson(e as Map<String, dynamic>))
          .toList(),
      page: json['page'] as int,
      size: json['size'] as int,
      totalPages: json['totalPages'] as int,
      totalElements: json['totalElements'] as int,
    );
  }

  bool get hasNextPage => page < totalPages - 1;
} 