import 'package:flutter/material.dart';
import '../../model/popular_beauty_keyword.dart';
import '../../../../features/search/presentation/page/keyword_review_page.dart';

class PopularBeautyKeywordSectionCard extends StatelessWidget {
  final List<PopularBeautyKeyword> keywords;

  const PopularBeautyKeywordSectionCard({
    super.key,
    required this.keywords,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '이번주 인기 시술 키워드 Top10',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 35,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            scrollDirection: Axis.horizontal,
            itemCount: keywords.length,
            itemBuilder: (context, index) {
              final keyword = keywords[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: _KeywordCard(
                  rank: index + 1,
                  keyword: keyword,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _KeywordCard extends StatelessWidget {
  final int rank;
  final PopularBeautyKeyword keyword;

  const _KeywordCard({
    required this.rank,
    required this.keyword,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => KeywordReviewPage(
              keyword: keyword.keyword,
            ),
          ),
        );
      },
      child: Container(
        width: 110,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          border: Border.all(
            color: Colors.grey[800]!,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '$rank',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                keyword.keyword,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 