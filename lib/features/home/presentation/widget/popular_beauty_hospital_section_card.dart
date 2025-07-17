import 'package:flutter/material.dart';
import '../../data/popular_repository.dart';
import '../../model/popular_beauty_hospital.dart';
import 'popular_beauty_hospital_card.dart';

class PopularBeautyHospitalSectionCard extends StatefulWidget {
  const PopularBeautyHospitalSectionCard({super.key, required List<PopularBeautyHospital> hospitals});

  @override
  State<PopularBeautyHospitalSectionCard> createState() => _PopularBeautyHospitalSectionCardState();
}

class _PopularBeautyHospitalSectionCardState extends State<PopularBeautyHospitalSectionCard> {
  final repo = PopularRepository();
  late Future<List<PopularBeautyHospital>> futureHospitals;

  @override
  void initState() {
    super.initState();
    futureHospitals = repo.fetchPopularBeautyHospitals();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            '시술 병원 찜 Top 10',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
        ),
        SizedBox(
          height: 345,
          child: FutureBuilder<List<PopularBeautyHospital>>(
            future: futureHospitals,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('에러: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('데이터 없음'));
              }

              final hospitals = snapshot.data!;
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: hospitals.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  return PopularBeautyHospitalCard(
                    hospital: hospitals[index],
                    rank: index + 1,
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
