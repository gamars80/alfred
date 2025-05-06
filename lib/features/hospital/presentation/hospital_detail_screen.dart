// hospital_detail_screen.dart
import 'package:alfred_clean/features/hospital/presentation/widget/hospital_detail_widgets.dart';
import 'package:alfred_clean/features/hospital/presentation/widget/hospital_info_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../call/model/hostpital.dart';
import '../data/hospital_repository.dart';
import '../model/hospital_detail_model.dart';

class HospitalDetailScreen extends StatefulWidget {
  final int hospitalId;
  final Hospital hospital;

  const HospitalDetailScreen({
    super.key,
    required this.hospitalId,
    required this.hospital,
  });

  @override
  State<HospitalDetailScreen> createState() => _HospitalDetailScreenState();
}

class _HospitalDetailScreenState extends State<HospitalDetailScreen> {
  late Future<HospitalDetailResponse> _hospitalDetail;

  @override
  void initState() {
    super.initState();
    _hospitalDetail = HospitalRepository().getHospitalDetail(widget.hospitalId);
  }

  @override
  Widget build(BuildContext context) {
    final hospital = widget.hospital;

    return FutureBuilder(
      future: _hospitalDetail,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const Scaffold(
            body: Center(child: Text('데이터를 불러오지 못했습니다')),
          );
        }

        final data = snapshot.data!;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text(hospital.hospitalName),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 1,
          ),
          body: ListView(
            children: [
              HospitalImageBanner(images: data.hospitalImages),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hospital.hospitalName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          hospital.location,
                          style: const TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${double.tryParse(hospital.rating) ?? 0.0}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${hospital.ratingCount}명)',
                          style: const TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: hospital.description
                          .split(RegExp(r'\s+'))
                          .where((e) => e.startsWith('#'))
                          .take(5)
                          .map((tag) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.deepPurple.shade50,
                        ),
                        child: Text(
                          tag,
                          style: const TextStyle(fontSize: 11, color: Colors.deepPurple),
                        ),
                      ))
                          .toList(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              const SizedBox(height: 12),
              HospitalEventList(events: data.events),
              const Divider(),
              HospitalReviewList(reviews: data.reviews),
              const Divider(),
              HospitalDoctorInfo(doctors: data.doctors),
            ],
          ),
        );
      },
    );
  }
}
