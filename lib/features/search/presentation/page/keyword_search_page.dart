import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'keyword_review_page.dart';

class KeywordSearchPage extends StatefulWidget {
  final String initialKeyword;

  const KeywordSearchPage({
    Key? key,
    required this.initialKeyword,
  }) : super(key: key);

  @override
  State<KeywordSearchPage> createState() => _KeywordSearchPageState();
}

class _KeywordSearchPageState extends State<KeywordSearchPage> {
  final _textController = TextEditingController();
  final _prefs = SharedPreferences.getInstance();
  static const _recentSearchKey = 'recent_keyword_searches';
  List<String> _recentSearches = [];

  @override
  void initState() {
    super.initState();
    _textController.text = widget.initialKeyword;
    _loadRecentSearches();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _loadRecentSearches() async {
    final prefs = await _prefs;
    setState(() {
      _recentSearches = prefs.getStringList(_recentSearchKey) ?? [];
    });
  }

  Future<void> _saveRecentSearch(String keyword) async {
    if (keyword.trim().isEmpty) return;
    
    final prefs = await _prefs;
    final searches = prefs.getStringList(_recentSearchKey) ?? [];
    
    // 동일한 검색어가 있다면 제거
    searches.remove(keyword);
    // 최신 검색어를 맨 앞에 추가
    searches.insert(0, keyword);
    // 최대 10개까지만 유지
    if (searches.length > 10) {
      searches.removeLast();
    }
    
    await prefs.setStringList(_recentSearchKey, searches);
    setState(() {
      _recentSearches = searches;
    });
  }

  Future<void> _removeRecentSearch(String keyword) async {
    final prefs = await _prefs;
    final searches = prefs.getStringList(_recentSearchKey) ?? [];
    searches.remove(keyword);
    await prefs.setStringList(_recentSearchKey, searches);
    setState(() {
      _recentSearches = searches;
    });
  }

  void _onSearch(String keyword) async {
    if (keyword.trim().isEmpty) return;
    
    await _saveRecentSearch(keyword);
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => KeywordReviewPage(
          keyword: widget.initialKeyword,
          searchText: keyword,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _textController,
          decoration: InputDecoration(
            hintText: '검색어를 입력하세요',
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () => _textController.clear(),
            ),
          ),
          onSubmitted: _onSearch,
          autofocus: true,
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              '최근 검색어',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _recentSearches.length,
              itemBuilder: (context, index) {
                final keyword = _recentSearches[index];
                return ListTile(
                  title: Text(keyword),
                  trailing: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => _removeRecentSearch(keyword),
                  ),
                  onTap: () => _onSearch(keyword),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 