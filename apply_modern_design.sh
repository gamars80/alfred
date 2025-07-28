#!/bin/bash

# 🎨 Modern Design Apply Script
# 이 스크립트를 실행하면 새로운 모던한 디자인을 적용합니다.

echo "🎨 Call Screen 모던 디자인 적용을 시작합니다..."

# 현재 상태 파일들이 존재하는지 확인
if [ ! -f "lib/features/call/presentation/call_screen_current.dart" ]; then
    echo "❌ 현재 상태 파일이 없습니다: call_screen_current.dart"
    echo "💡 먼저 복구 스크립트를 실행하여 원래 상태로 복구한 후 다시 시도하세요."
    exit 1
fi

if [ ! -f "lib/features/call/presentation/call_screen_body_current.dart" ]; then
    echo "❌ 현재 상태 파일이 없습니다: call_screen_body_current.dart"
    echo "💡 먼저 복구 스크립트를 실행하여 원래 상태로 복구한 후 다시 시도하세요."
    exit 1
fi

if [ ! -f "lib/features/call/presentation/voice_command_bottom_sheet_current.dart" ]; then
    echo "❌ 현재 상태 파일이 없습니다: voice_command_bottom_sheet_current.dart"
    echo "💡 먼저 복구 스크립트를 실행하여 원래 상태로 복구한 후 다시 시도하세요."
    exit 1
fi

echo "📁 현재 상태 파일들을 원래 위치로 복원합니다..."

# 현재 상태 파일들을 원래 위치로 복원
cp lib/features/call/presentation/call_screen_current.dart lib/features/call/presentation/call_screen.dart
cp lib/features/call/presentation/call_screen_body_current.dart lib/features/call/presentation/call_screen_body.dart
cp lib/features/call/presentation/voice_command_bottom_sheet_current.dart lib/features/call/presentation/voice_command_bottom_sheet.dart

echo "✅ 모던 디자인이 적용되었습니다!"
echo ""
echo "📋 적용된 파일들:"
echo "  - call_screen.dart (모던한 앱바와 플로팅 액션 버튼)"
echo "  - call_screen_body.dart (그라데이션 배경과 카드 디자인)"
echo "  - voice_command_bottom_sheet.dart (인터랙티브한 바텀시트)"
echo ""
echo "🎨 주요 개선사항:"
echo "  - 그라데이션 배경과 카드 디자인"
echo "  - 애니메이션 효과 강화"
echo "  - 아이콘과 색상 시스템 개선"
echo "  - 사용자 경험 향상"
echo ""
echo "🔄 원래 상태로 복구하려면 다음 명령어를 실행하세요:"
echo "  ./restore_call_screens.sh" 