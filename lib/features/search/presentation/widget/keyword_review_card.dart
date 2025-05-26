import 'package:flutter/material.dart';
import '../../model/keyword_review.dart';
import '../../../../common/widget/rating_stars.dart';
import '../../../../common/util/date_formatter.dart';

class KeywordReviewCard extends StatelessWidget {
  final KeywordReview review;

  const KeywordReviewCard({
    Key? key,
    required this.review,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 12),
            if (review.images.isNotEmpty) _buildImages(),
            const SizedBox(height: 12),
            Text(
              review.text,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        if (review.doctor?.profilePhoto != null)
          CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(review.doctor!.profilePhoto!),
          ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (review.doctor != null)
                Text(
                  '${review.doctor!.name} ${review.doctor!.position}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              const SizedBox(height: 4),
              RatingStars(rating: review.rating),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImages() {
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: review.images.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final image = review.images[index];
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              image.isBlur ? image.smallUrl : image.url,
              height: 120,
              width: 120,
              fit: BoxFit.cover,
            ),
          );
        },
      ),
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          DateFormatter.format(review.createdAt),
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        if (review.price > 0)
          Text(
            '${review.price}원',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
      ],
    );
  }
} 