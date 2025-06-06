import 'package:flutter/material.dart';

class CommandAuthorityHistory {
  final int id;
  final int userId;
  final String changeType;
  final int changeCount;
  final int beforeCount;
  final int afterCount;
  final String reason;
  final DateTime createdAt;

  const CommandAuthorityHistory({
    required this.id,
    required this.userId,
    required this.changeType,
    required this.beforeCount,
    required this.afterCount,
    required this.changeCount,
    required this.reason,
    required this.createdAt,
  });

  factory CommandAuthorityHistory.fromJson(Map<String, dynamic> json) {
    return CommandAuthorityHistory(
      id: json['id'] as int,
      userId: json['userId'] as int,
      changeType: json['changeType'] as String,
      changeCount: json['changeCount'] as int,
      beforeCount: json['beforeCount'] as int,
      afterCount: json['afterCount'] as int,
      reason: json['reason'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Color getChangeTypeColor() {
    return changeType == 'INCREASE' ? Colors.blue : Colors.red;
  }

  String getChangeTypeText() {
    return changeType == 'INCREASE' ? '+$changeCount' : '-$changeCount';
  }
} 