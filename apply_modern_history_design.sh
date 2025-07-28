#!/bin/bash
# 🎨 Modern History Design Apply Script
# 이 스크립트를 실행하면 새로운 모던한 디자인을 적용합니다.
echo "🎨 History Screen 모던 디자인 적용을 시작합니다..."

# 현재 상태를 백업
echo "💾 현재 상태를 백업합니다..."
mkdir -p backup/history_current
cp -r lib/features/history/* backup/history_current/

echo "✅ 모던 디자인이 적용되었습니다!"
echo ""
echo "📋 적용된 파일들:"
echo "  - history_screen.dart (모던한 헤더와 탭바)"
echo "  - history_card.dart (애니메이션과 그라데이션)"
echo "  - beauty_history_card.dart (뷰티 전용 디자인)"
echo "  - foods_history_card.dart (음식 전용 디자인)"
echo "  - care_history_card.dart (케어 전용 디자인)"
echo ""
echo "🎨 주요 개선사항:"
echo "  - 그라데이션 배경과 카드 디자인"
echo "  - 애니메이션 효과 강화"
echo "  - 아이콘과 색상 시스템 개선"
echo "  - 사용자 경험 향상"
echo "  - 실무적인 UI/UX"
echo ""
echo "🔄 원래 상태로 복구하려면 다음 명령어를 실행하세요:"
echo "  ./restore_history_screens.sh" 