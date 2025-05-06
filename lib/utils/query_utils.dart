// ✅ query_utils.dart
class QueryUtils {
  static String appendGenderAndAge(String base, String? gender, String? ageCode) {
    final parts = <String>[];
    if (base.trim().isNotEmpty) parts.add(base.trim());
    if (gender != null) parts.add(gender == 'MALE' ? '남성' : '여성');
    if (ageCode != null) parts.add(_mapAgeCodeToString(ageCode));
    return parts.join(' ');
  }

  static String _mapAgeCodeToString(String code) {
    switch (code) {
      case '0-5': return '0~5세';
      case '6-9': return '6~9세';
      case '10s': return '10대';
      case '20s': return '20대';
      case '30s': return '30대';
      case '40s': return '40대';
      case '50s': return '50대';
      case '60s':
      case '60+': return '60대';
      default: return '';
    }
  }
}
