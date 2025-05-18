// lib/features/community/presentation/popular_community_section.dart
import 'package:flutter/material.dart';
import '../../data/popular_repository.dart';

import '../../model/popular_community.dart';
import '../widget/popular_community_card.dart';

class PopularCommunitySectionCard extends StatefulWidget {
  const PopularCommunitySectionCard({super.key});

  @override
  State<PopularCommunitySectionCard> createState() => _PopularCommunitySectionState();
}

class _PopularCommunitySectionState extends State<PopularCommunitySectionCard> {
  final repo = PopularRepository();
  late Future<List<PopularCommunity>> futureCommunities;

  @override
  void initState() {
    super.initState();
    futureCommunities = repo.fetchPopularCommunities();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            '인기 커뮤니티 Top 10',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white, // 또는 Colors.black (배경에 따라)
            ),
          ),
        ),
        SizedBox(
          height: 180,
          child: FutureBuilder<List<PopularCommunity>>(
            future: futureCommunities,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('에러: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('데이터 없음'));
              }

              final communities = snapshot.data!;
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: communities.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final community = communities[index];
                  return PopularCommunityCard(
                    community: community,
                    rank: index + 1,
                    onTap: () {
                      // TODO: 상세 이동
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
