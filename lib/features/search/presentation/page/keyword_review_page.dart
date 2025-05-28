import 'package:flutter/material.dart';
import '../../data/search_repository.dart';
import '../../model/keyword_review.dart';
import '../widget/keyword_review_card.dart';
import 'keyword_search_page.dart';

class KeywordReviewPage extends StatefulWidget {
  final String keyword;
  final String? searchText;

  const KeywordReviewPage({
    Key? key,
    required this.keyword,
    this.searchText,
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
  bool _hasEvent = false;

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
        hasEvent: _hasEvent,
        searchText: widget.searchText,
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
        hasEvent: _hasEvent,
        searchText: widget.searchText,
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
        title: Text(
          widget.keyword,
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => KeywordSearchPage(
                    initialKeyword: widget.searchText ?? widget.keyword,
                  ),
                ),
              );
            },
          ),
        ],
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            '$_totalCount개의 리뷰가 검색됩니다.',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Row(
            children: [
              Checkbox(
                value: _hasEvent,
                onChanged: (value) {
                  setState(() {
                    _hasEvent = value ?? false;
                  });
                  _loadInitialData();
                },
              ),
              const Text('이벤트 진행중'),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
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
          ),
        ),
      ],
    );
  }
} 