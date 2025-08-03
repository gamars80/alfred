#!/bin/bash

echo "🔄 홈 디자인을 원래 상태로 복원합니다..."

# 백업에서 복원
if [ -d "backup_home/home" ]; then
    rm -rf lib/features/home
    cp -r backup_home/home lib/features/home
    echo "✅ 홈 디자인이 성공적으로 복원되었습니다!"
else
    echo "❌ 백업 파일을 찾을 수 없습니다."
    exit 1
fi

echo "🎉 복원 완료! 앱을 다시 실행해보세요." 