// lib/features/home/widget/popular_product_skeleton_card.dart
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class PopularProductSkeletonCard extends StatelessWidget {
  const PopularProductSkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: 160,
        height: 250,
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
