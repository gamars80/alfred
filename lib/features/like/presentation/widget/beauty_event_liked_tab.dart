import 'package:flutter/material.dart';
import '../../../like/data/like_repository.dart';
import '../../../like/model/like_beauty_event.dart';
import 'like_beauty_event_card.dart';


class BeautyEventLikedTab extends StatefulWidget {
  const BeautyEventLikedTab({super.key});

  @override
  State<BeautyEventLikedTab> createState() => _BeautyEventLikedTabState();
}

class _BeautyEventLikedTabState extends State<BeautyEventLikedTab> {
  final LikeRepository _likeRepo = LikeRepository();
  final ScrollController _scrollController = ScrollController();

  List<LikedBeautyEvent> _likes = [];
  bool _isInitialLoading = true;
  bool _isLoadingMore = false;
  String? _error;
  int _currentPage = 0;
  int _totalPages = 1;
  bool _sortByHighPrice = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadInitial();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _currentPage < _totalPages - 1) {
      _loadMore();
    }
  }

  Future<void> _loadInitial() async {
    setState(() {
      _isInitialLoading = true;
      _error = null;
    });
    try {
      final pageData = await _likeRepo.fetchLikedBeautyEvent(page: 0);
      setState(() {
        _likes = pageData.content;
        _currentPage = pageData.page;
        _totalPages = pageData.totalPages;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isInitialLoading = false);
    }
  }

  Future<void> _loadMore() async {
    if (_currentPage >= _totalPages - 1) return;
    setState(() => _isLoadingMore = true);
    try {
      final nextPage = _currentPage + 1;
      final pageData = await _likeRepo.fetchLikedBeautyEvent(page: nextPage);
      setState(() {
        _likes.addAll(pageData.content);
        _currentPage = pageData.page;
        _totalPages = pageData.totalPages;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('추가 로딩 실패: $e')),
      );
    } finally {
      setState(() => _isLoadingMore = false);
    }
  }

  Future<void> _removeLike(LikedBeautyEvent event) async {
    try {
      await _likeRepo.deleteLikeBeautyEvent(
        historyCreatedAt: int.parse(event.historyAddedAt),
        eventId: event.eventId.toString(),
        source: event.source,
      );
      setState(() => _likes.remove(event));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('좋아요 삭제 실패: $e')),
      );
    }
  }

  void _toggleSort() {
    setState(() {
      _sortByHighPrice = !_sortByHighPrice;
      _likes.sort((a, b) => _sortByHighPrice
          ? b.discountedPrice.compareTo(a.discountedPrice)
          : a.discountedPrice.compareTo(b.discountedPrice));
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitialLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text('에러 발생: $_error', style: TextStyle(color: Colors.white)));
    }
    if (_likes.isEmpty) {
      return const Center(
        child: Text(
          '찜한 시술 이벤트가 없습니다.',
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      );
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: _toggleSort,
                icon: const Icon(Icons.swap_vert, size: 18, color: Colors.white),
                label: Text(
                  _sortByHighPrice ? '높은 가격순' : '낮은 가격순',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(12),
            itemCount: _likes.length + (_isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < _likes.length) {
                final item = _likes[index];
                return LikedBeautyEventCard(
                  event: item,
                  onUnlike: () => _removeLike(item),
                );
              } else {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
            },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
