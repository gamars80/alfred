import 'package:flutter/material.dart';
import '../../data/like_repository.dart';
import '../../model/like_beauty_community.dart';
import 'like_beauty_community_card.dart';


class BeautyCommunityLikedTab extends StatefulWidget {
  const BeautyCommunityLikedTab({super.key});

  @override
  State<BeautyCommunityLikedTab> createState() => _BeautyCommunityLikedTabState();
}

class _BeautyCommunityLikedTabState extends State<BeautyCommunityLikedTab> {
  final LikeRepository _likeRepo = LikeRepository();
  final ScrollController _scrollController = ScrollController();

  List<LikedBeautyCommunity> _likes = [];
  bool _isInitialLoading = true;
  bool _isLoadingMore = false;
  String? _error;
  int _currentPage = 0;
  int _totalPages = 1;

  @override
  void initState() {
    super.initState();
    _setupScroll();
    _loadInitial();
  }

  void _setupScroll() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200 &&
          !_isLoadingMore &&
          _currentPage < _totalPages - 1) {
        _loadMore();
      }
    });
  }

  Future<void> _loadInitial() async {
    setState(() {
      _isInitialLoading = true;
      _error = null;
    });
    try {
      final pageData = await _likeRepo.fetchLikedBeautyCommunity(page: 0);
      setState(() {
        _likes = pageData.content;
        _currentPage = pageData.page;
        _totalPages = pageData.totalPages;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isInitialLoading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_currentPage >= _totalPages - 1) return;
    setState(() => _isLoadingMore = true);
    try {
      final nextPage = _currentPage + 1;
      final pageData = await _likeRepo.fetchLikedBeautyCommunity(page: nextPage);
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

  Future<void> _removeLike(LikedBeautyCommunity p) async {
    try {
      await _likeRepo.deleteLikeBeautyCommunity(
        historyCreatedAt: int.parse(p.historyAddedAt),
        beautyCommunityId: p.beautyCommunityId.toString(),
        source: p.source,
      );
      setState(() {
        _likes.remove(p);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('좋아요 삭제 실패: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitialLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Text('에러 발생: $_error', style: TextStyle(color: Colors.white)),
      );
    }
    if (_likes.isEmpty) {
      return const Center(
        child: Text(
          '찜한 커뮤니티 게시글이 없습니다.',
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      );
    }
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(12),
      itemCount: _likes.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < _likes.length) {
          final item = _likes[index];
          return BeautyCommunityLikedCard(
            item: item,
            onUnlike: () => _removeLike(item),
          );
        } else {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}
