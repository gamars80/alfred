#!/bin/bash

echo "🔄 Call 위젯들을 원래 상태로 복원 중..."

# Call 위젯들 복원
echo "📁 Call 위젯들 복원 중..."
cp -r backup/call_widgets/* lib/features/call/presentation/widget/

echo "✅ Call 위젯들이 성공적으로 복원되었습니다!"
echo ""
echo "📝 복원된 파일들:"
echo "  - lib/features/call/presentation/widget/product_card.dart"
echo "  - lib/features/call/presentation/widget/care_product_card.dart"
echo "  - 기타 모든 call 위젯 파일들"
echo ""
echo "🎯 이제 원래 디자인의 call 위젯들을 사용할 수 있습니다." 