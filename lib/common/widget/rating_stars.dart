import 'package:flutter/material.dart';

class RatingStars extends StatelessWidget {
  final int rating;
  final double size;
  final Color? color;

  const RatingStars({
    Key? key,
    required this.rating,
    this.size = 16,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          size: size,
          color: color ?? Colors.amber,
        );
      }),
    );
  }
} 