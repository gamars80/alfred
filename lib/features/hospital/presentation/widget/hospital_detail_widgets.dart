import 'package:flutter/material.dart';
import '../../model/hospital_detail_model.dart';

class HospitalImageCarousel extends StatelessWidget {
  final List<String> images;

  const HospitalImageCarousel({super.key, required this.images});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: PageView.builder(
        itemCount: images.length,
        itemBuilder: (_, i) => Image.network(images[i], fit: BoxFit.cover),
      ),
    );
  }
}

class HospitalEventList extends StatelessWidget {
  final List<Event> events;

  const HospitalEventList({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: events.map((event) {
        return ListTile(
          leading: Image.network(event.image, width: 60),
          title: Text(event.name),
          subtitle: Text('${event.rating}⭐️ · ${event.reviewCount}건'),
          trailing: Text('${event.discountPrice}원'),
        );
      }).toList(),
    );
  }
}

class HospitalReviewList extends StatelessWidget {
  final List<Review> reviews;

  const HospitalReviewList({super.key, required this.reviews});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: reviews.map((review) {
        return ListTile(
          title: Text('${review.rating}점 후기'),
          subtitle: Text(review.text, maxLines: 2, overflow: TextOverflow.ellipsis),
        );
      }).toList(),
    );
  }
}

class HospitalDoctorInfo extends StatelessWidget {
  final List<Doctor> doctors;

  const HospitalDoctorInfo({super.key, required this.doctors});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: doctors.map((doctor) {
        return ListTile(
          leading: CircleAvatar(backgroundImage: NetworkImage(doctor.profilePhoto)),
          title: Text(doctor.name),
          subtitle: Text(doctor.specialist),
        );
      }).toList(),
    );
  }
}


class HospitalImageBanner extends StatefulWidget {
  final List<String> images;

  const HospitalImageBanner({super.key, required this.images});

  @override
  State<HospitalImageBanner> createState() => _HospitalImageBannerState();
}

class _HospitalImageBannerState extends State<HospitalImageBanner> {
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: 240,
          child: PageView.builder(
            itemCount: widget.images.length,
            onPageChanged: (index) => setState(() => _current = index),
            itemBuilder: (_, i) {
              return Image.network(
                widget.images[i],
                fit: BoxFit.cover,
                width: double.infinity,
              );
            },
          ),
        ),
        Positioned(
          bottom: 10,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${_current + 1} / ${widget.images.length}',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }
}