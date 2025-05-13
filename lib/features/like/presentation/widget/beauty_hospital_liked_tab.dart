// lib/features/like/presentation/widget/beauty_hospital_liked_tab.dart

import 'package:flutter/material.dart';
import 'package:alfred_clean/features/like/data/like_repository.dart';
import 'package:alfred_clean/features/like/model/liked_beauty_hospital.dart';

import 'like_beauty_hospital_card.dart';


class BeautyHospitalLikedTab extends StatefulWidget {
  const BeautyHospitalLikedTab({Key? key}) : super(key: key);

  @override
  State<BeautyHospitalLikedTab> createState() => _BeautyHospitalLikedTabState();
}

class _BeautyHospitalLikedTabState extends State<BeautyHospitalLikedTab> {
  final LikeRepository _repo = LikeRepository();
  final ScrollController _ctrl = ScrollController();

  List<LikedBeautyHospital> _items = [];
  int _page = 0;
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _fetchPage();
    _ctrl.addListener(() {
      if (_ctrl.position.pixels >= _ctrl.position.maxScrollExtent - 200 &&
          !_isLoading &&
          _hasMore) {
        _fetchPage();
      }
    });
  }

  Future<void> _fetchPage() async {
    setState(() => _isLoading = true);
    try {
      final paged = await _repo.fetchLikedBeautyHospital(page: _page);
      setState(() {
        _page++;
        _hasMore = _page < paged.totalPages;
        _items.addAll(paged.content);
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onUnlike(int hospitalId) {
    setState(() {
      _items.removeWhere((h) => h.hospitalId == hospitalId);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty && _isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_items.isEmpty) {
      return const Center(
        child: Text(
          '찜한 병원이 없습니다.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _page = 0;
          _items.clear();
          _hasMore = true;
        });
        await _fetchPage();
      },
      child: ListView.builder(
        controller: _ctrl,
        itemCount: _items.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, idx) {
          if (idx == _items.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final h = _items[idx];
          return LikeBeautyHospitalCard(
            hospital: h,
            onUnlike: _onUnlike,
          );
        },
      ),
    );
  }
}
