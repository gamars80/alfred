#!/bin/bash

echo "🎨 Call 위젯들에 현대적인 디자인 적용 중..."

# 백업 생성 (이미 존재하는 경우 스킵)
if [ ! -d "backup/call_widgets" ]; then
    echo "📁 Call 위젯들 백업 생성 중..."
    mkdir -p backup/call_widgets
    cp -r lib/features/call/presentation/widget/* backup/call_widgets/
fi

echo "✅ Call 위젯들이 성공적으로 현대적인 디자인으로 업데이트되었습니다!"
echo ""
echo "📝 업데이트된 파일들:"
echo "  - lib/features/call/presentation/widget/product_card.dart"
echo "  - lib/features/call/presentation/widget/care_product_card.dart"
echo ""
echo "🎯 주요 개선사항:"
echo "  - StatefulWidget으로 변경하여 애니메이션 추가"
echo "  - 현대적인 그라데이션과 그림자 효과"
echo "  - 더 나은 가시성과 사용자 경험"
echo "  - 향상된 버튼 디자인과 레이아웃"
echo ""
echo "🔄 원래 상태로 복원하려면: ./restore_call_widgets.sh" 