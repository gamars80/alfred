#!/bin/bash

# 🚨 Call Screen Restore Script
# 이 스크립트를 실행하면 원래 상태로 복구됩니다.

echo "🔄 Call Screen 복구를 시작합니다..."

# 백업 파일들이 존재하는지 확인
if [ ! -f "lib/features/call/presentation/call_screen_backup.dart" ]; then
    echo "❌ 백업 파일이 없습니다: call_screen_backup.dart"
    exit 1
fi

if [ ! -f "lib/features/call/presentation/call_screen_body_backup.dart" ]; then
    echo "❌ 백업 파일이 없습니다: call_screen_body_backup.dart"
    exit 1
fi

if [ ! -f "lib/features/call/presentation/voice_command_bottom_sheet_backup.dart" ]; then
    echo "❌ 백업 파일이 없습니다: voice_command_bottom_sheet_backup.dart"
    exit 1
fi

echo "📁 백업 파일들을 원래 위치로 복원합니다..."

# 현재 파일들을 백업 (현재 상태 보존)
cp lib/features/call/presentation/call_screen.dart lib/features/call/presentation/call_screen_current.dart
cp lib/features/call/presentation/call_screen_body.dart lib/features/call/presentation/call_screen_body_current.dart
cp lib/features/call/presentation/voice_command_bottom_sheet.dart lib/features/call/presentation/voice_command_bottom_sheet_current.dart

# 백업 파일들을 원래 위치로 복원
cp lib/features/call/presentation/call_screen_backup.dart lib/features/call/presentation/call_screen.dart
cp lib/features/call/presentation/call_screen_body_backup.dart lib/features/call/presentation/call_screen_body.dart
cp lib/features/call/presentation/voice_command_bottom_sheet_backup.dart lib/features/call/presentation/voice_command_bottom_sheet.dart

echo "✅ 복구가 완료되었습니다!"
echo ""
echo "📋 복구된 파일들:"
echo "  - call_screen.dart"
echo "  - call_screen_body.dart"
echo "  - voice_command_bottom_sheet.dart"
echo ""
echo "💾 현재 상태는 다음 파일들에 보존되었습니다:"
echo "  - call_screen_current.dart"
echo "  - call_screen_body_current.dart"
echo "  - voice_command_bottom_sheet_current.dart"
echo ""
echo "🔄 다시 새로운 디자인을 적용하려면 다음 명령어를 실행하세요:"
echo "  ./apply_modern_design.sh" 