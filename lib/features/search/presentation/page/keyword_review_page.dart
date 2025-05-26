import 'package:flutter/material.dart';
import '../../data/search_repository.dart';
import '../../model/keyword_review.dart';
import '../widget/keyword_review_card.dart';

class KeywordReviewPage extends StatefulWidget {
  final String keyword;

  const KeywordReviewPage({
    Key? key,
    required this.keyword,
  }) : super(key: key);

  @override
  State<KeywordReviewPage> createState() => _KeywordReviewPageState();
}

class _KeywordReviewPageState extends State<KeywordReviewPage> {
  final _searchRepository = SearchRepository();
  final _scrollController = ScrollController();
  
  List<KeywordReview> _reviews = [];
  String? _nextCursor;
  bool _isLoading = false;
  bool _hasError = false;
  int _totalCount = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadInitialData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final result = await _searchRepository.fetchKeywordReviews(
        keyword: widget.keyword,
      );
      
      setState(() {
        _reviews = result.items;
        _nextCursor = result.nextCursor;
        _totalCount = result.totalCount;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreData() async {
    if (_isLoading || _nextCursor == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _searchRepository.fetchKeywordReviews(
        keyword: widget.keyword,
        cursor: _nextCursor,
      );

      setState(() {
        _reviews.addAll(result.items);
        _nextCursor = result.nextCursor;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.keyword} 리뷰 $_totalCount건'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('데이터를 불러오는데 실패했습니다.'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadInitialData,
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    if (_isLoading && _reviews.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: _reviews.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _reviews.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }
        return KeywordReviewCard(review: _reviews[index]);
      },
    );
  }
} 