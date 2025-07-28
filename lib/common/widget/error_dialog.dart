import 'package:flutter/material.dart';

/// 재사용 가능한 에러 다이얼로그 위젯
/// 
/// 앱 전체에서 사용할 수 있는 일관된 에러 다이얼로그를 제공합니다.
/// 실무에서 자주 사용되는 패턴을 구현했습니다.
class ErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? primaryButtonText;
  final String? secondaryButtonText;
  final VoidCallback? onPrimaryPressed;
  final VoidCallback? onSecondaryPressed;
  final IconData? icon;

  const ErrorDialog({
    super.key,
    required this.title,
    required this.message,
    this.primaryButtonText,
    this.secondaryButtonText,
    this.onPrimaryPressed,
    this.onSecondaryPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Icon(
            icon ?? Icons.error_outline_rounded,
            color: Colors.red[600],
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
      content: Text(
        message,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black87,
          height: 1.4,
        ),
      ),
      actions: [
        if (secondaryButtonText != null)
          TextButton(
            onPressed: onSecondaryPressed ?? () => Navigator.of(context).pop(),
            child: Text(
              secondaryButtonText!,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        if (primaryButtonText != null)
          ElevatedButton(
            onPressed: onPrimaryPressed ?? () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              primaryButtonText!,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}

/// 간단한 에러 다이얼로그 표시 함수
/// 
/// 빠르게 에러 다이얼로그를 표시할 수 있는 편의 함수입니다.
Future<void> showErrorDialog({
  required BuildContext context,
  required String title,
  required String message,
  String? primaryButtonText,
  String? secondaryButtonText,
  VoidCallback? onPrimaryPressed,
  VoidCallback? onSecondaryPressed,
  IconData? icon,
}) {
  return showDialog(
    context: context,
    builder: (context) => ErrorDialog(
      title: title,
      message: message,
      primaryButtonText: primaryButtonText,
      secondaryButtonText: secondaryButtonText,
      onPrimaryPressed: onPrimaryPressed,
      onSecondaryPressed: onSecondaryPressed,
      icon: icon,
    ),
  );
}

/// 네트워크 에러 다이얼로그
/// 
/// 네트워크 관련 에러에 특화된 다이얼로그입니다.
Future<void> showNetworkErrorDialog({
  required BuildContext context,
  String? message,
  VoidCallback? onRetry,
}) {
  return showErrorDialog(
    context: context,
    title: '네트워크 오류',
    message: message ?? '인터넷 연결을 확인하고 다시 시도해주세요.',
    primaryButtonText: '재시도',
    secondaryButtonText: '취소',
    onPrimaryPressed: onRetry,
    icon: Icons.wifi_off_rounded,
  );
}

/// 서버 에러 다이얼로그
/// 
/// 서버 관련 에러에 특화된 다이얼로그입니다.
Future<void> showServerErrorDialog({
  required BuildContext context,
  String? message,
  VoidCallback? onRetry,
}) {
  return showErrorDialog(
    context: context,
    title: '서버 오류',
    message: message ?? '서버에 일시적인 문제가 발생했습니다. 잠시 후 다시 시도해주세요.',
    primaryButtonText: '재시도',
    secondaryButtonText: '취소',
    onPrimaryPressed: onRetry,
    icon: Icons.cloud_off_rounded,
  );
} 