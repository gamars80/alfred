// hospital_detail_screen.dart
import 'package:alfred_clean/features/hospital/presentation/widget/hospital_detail_widgets.dart';
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
            title: Text(hospital.hospitalName,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
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
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 6,
                      children: [
                        const Icon(Icons.location_on, size: 16, color: Colors.grey),
                        Text(
                          hospital.location,
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Wrap(
                      spacing: 10,
                      runSpacing: 6,
                      children: [
                        _iconText(Icons.star, '${hospital.rating}점'),
                        _iconText(Icons.reviews, '${hospital.ratingCount}건'),
                        _iconText(Icons.event_available, '${hospital.doctorCount}명의 의사'),
                        _iconText(Icons.question_answer, '${hospital.counselCount}건 상담'),
                      ],
                    ),
                    const SizedBox(height: 2),
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
              HospitalEventList(events: data.events, hospitalId: widget.hospitalId),
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

  Widget _iconText(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.deepPurple),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 12, color: Colors.black87),
        ),
      ],
    );
  }
}
