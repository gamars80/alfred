class CallValidator {
  /// 명령어 입력 유효성 검증
  static String? validateQuery(String value) {
    final trimmed = value.trim();

    if (trimmed.isEmpty) return '명령어를 입력해주세요';
    if (trimmed.length < 2) return '2글자 이상 입력해주세요';
    if (trimmed.length > 100) return '100자 이내로 작성해주세요';

    return null; // 유효할 경우 null 반환
  }
}
