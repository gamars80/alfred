// lib/features/home/presentation/widget/popular_community_section_card.dart

import 'package:flutter/material.dart';
import '../../model/popular_community.dart';
import 'popular_community_card.dart';

class PopularCommunitySectionCard extends StatelessWidget {
  final List<PopularCommunity> communities;
  const PopularCommunitySectionCard({
    super.key,
    required this.communities,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            '시술 커뮤니티 찜 Top 10',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(
          height: 180,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: communities.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final c = communities[index];
              return PopularCommunityCard(
                community: c,
                rank: index + 1,
              );
            },
          ),
        ),
      ],
    );
  }
}
