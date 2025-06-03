// lib/features/call/model/recent_beauty_command.dart
class RecentBeautyCommand {
  final String id;
  final String query;
  final int createdAt;

  RecentBeautyCommand({
    required this.id,
    required this.query,
    required this.createdAt,
  });

  factory RecentBeautyCommand.fromJson(Map<String, dynamic> json) {
    return RecentBeautyCommand(
      id: json['id'] as String,
      query: json['query'] as String,
      createdAt: (json['createdAt'] as num).toInt(),
    );
  }
}
