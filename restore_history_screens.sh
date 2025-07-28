#!/bin/bash
# 🚨 History Screen Restore Script
# 이 스크립트를 실행하면 원래 상태로 복구됩니다.
echo "🔄 History Screen 복구를 시작합니다..."

if [ ! -d "backup/history" ]; then
    echo "❌ 백업 폴더가 없습니다: backup/history"
    exit 1
fi

echo "📁 백업 파일들을 원래 위치로 복원합니다..."
cp -r backup/history/* lib/features/history/

echo "✅ 복구가 완료되었습니다!"
echo ""
echo "📋 복구된 파일들:"
echo "  - history_screen.dart"
echo "  - history_card.dart"
echo "  - beauty_history_card.dart"
echo "  - foods_history_card.dart"
echo "  - care_history_card.dart"
echo "  - 모든 히스토리 관련 파일들"
echo ""
echo "🎨 새로운 디자인을 다시 적용하려면 다음 명령어를 실행하세요:"
echo "  ./apply_modern_history_design.sh" 