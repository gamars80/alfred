#!/bin/bash

# 리뷰 관련 화면 백업 스크립트
echo "리뷰 관련 화면 백업을 시작합니다..."

# 백업 디렉토리 생성
BACKUP_DIR="backup_review_screens_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

# 리뷰 관련 파일들 백업
echo "리뷰 관련 파일들을 백업합니다..."

# 메인 리뷰 화면들
cp lib/features/search/presentation/review_list_screen.dart "$BACKUP_DIR/"
cp lib/features/search/presentation/review_search_screen.dart "$BACKUP_DIR/"
cp lib/features/search/presentation/review_detail_screen.dart "$BACKUP_DIR/"

# 카테고리별 리뷰 화면들
cp lib/features/search/presentation/care_keyword_review_list_screen.dart "$BACKUP_DIR/"
cp lib/features/search/presentation/care_review_detail_screen.dart "$BACKUP_DIR/"
cp lib/features/search/presentation/care_review_search_screen.dart "$BACKUP_DIR/"

cp lib/features/search/presentation/food_ingredient_review_list_screen.dart "$BACKUP_DIR/"
cp lib/features/search/presentation/food_review_detail_screen.dart "$BACKUP_DIR/"

# 리뷰 모델
cp lib/features/search/model/review.dart "$BACKUP_DIR/"

# 리뷰 관련 위젯들 (있는 경우)
find lib/features/search/presentation/widget/ -name "*review*" -type f -exec cp {} "$BACKUP_DIR/" \;

echo "백업 완료: $BACKUP_DIR"
echo "백업된 파일들:"
ls -la "$BACKUP_DIR"

echo ""
echo "복원 명령어:"
echo "cp $BACKUP_DIR/* lib/features/search/presentation/"
echo "cp $BACKUP_DIR/review.dart lib/features/search/model/" 