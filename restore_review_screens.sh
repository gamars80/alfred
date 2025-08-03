#!/bin/bash

# 리뷰 관련 화면 복원 스크립트
echo "리뷰 관련 화면 복원을 시작합니다..."

# 백업 디렉토리 찾기
BACKUP_DIR=$(ls -d backup_review_screens_* | head -1)

if [ -z "$BACKUP_DIR" ]; then
    echo "백업 디렉토리를 찾을 수 없습니다."
    exit 1
fi

echo "복원할 백업 디렉토리: $BACKUP_DIR"

# 리뷰 관련 파일들 복원
echo "리뷰 관련 파일들을 복원합니다..."

# 메인 리뷰 화면들
cp "$BACKUP_DIR/review_list_screen.dart" lib/features/search/presentation/
cp "$BACKUP_DIR/review_search_screen.dart" lib/features/search/presentation/
cp "$BACKUP_DIR/review_detail_screen.dart" lib/features/search/presentation/

# 카테고리별 리뷰 화면들
cp "$BACKUP_DIR/care_keyword_review_list_screen.dart" lib/features/search/presentation/
cp "$BACKUP_DIR/care_review_detail_screen.dart" lib/features/search/presentation/
cp "$BACKUP_DIR/care_review_search_screen.dart" lib/features/search/presentation/

cp "$BACKUP_DIR/food_ingredient_review_list_screen.dart" lib/features/search/presentation/
cp "$BACKUP_DIR/food_review_detail_screen.dart" lib/features/search/presentation/

# 리뷰 모델
cp "$BACKUP_DIR/review.dart" lib/features/search/model/

# 리뷰 관련 위젯들
if [ -f "$BACKUP_DIR/keyword_review_card.dart" ]; then
    cp "$BACKUP_DIR/keyword_review_card.dart" lib/features/search/presentation/widget/
fi

echo "복원 완료!"
echo "복원된 파일들:"
ls -la "$BACKUP_DIR" 