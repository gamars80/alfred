import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReviewSearchScreen extends StatefulWidget {
  const ReviewSearchScreen({super.key});

  @override
  State<ReviewSearchScreen> createState() => _ReviewSearchScreenState();
}

class _ReviewSearchScreenState extends State<ReviewSearchScreen> {
  final _textController = TextEditingController();
  SharedPreferences? _prefs;
  List<String> _recentSearches = [];
  static const _maxRecentSearches = 10;
  static const _prefsKey = 'review_recent_searches';

  @override
  void initState() {
    super.initState();
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    _loadRecentSearches();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _loadRecentSearches() async {
    setState(() {
      _recentSearches = _prefs?.getStringList(_prefsKey) ?? [];
    });
  }

  Future<void> _saveRecentSearch(String keyword) async {
    if (keyword.trim().isEmpty) return;
    if (_prefs == null) return;

    final searches = _prefs!.getStringList(_prefsKey) ?? [];
    searches.remove(keyword);
    searches.insert(0, keyword);
    if (searches.length > _maxRecentSearches) {
      searches.removeLast();
    }

    await _prefs!.setStringList(_prefsKey, searches);
    setState(() {
      _recentSearches = searches;
    });
  }

  Future<void> _removeRecentSearch(String keyword) async {
    if (_prefs == null) return;
    
    final searches = _prefs!.getStringList(_prefsKey) ?? [];
    searches.remove(keyword);
    await _prefs!.setStringList(_prefsKey, searches);
    setState(() {
      _recentSearches = searches;
    });
  }

  Future<void> _clearRecentSearches() async {
    if (_prefs == null) return;
    
    await _prefs!.remove(_prefsKey);
    setState(() {
      _recentSearches = [];
    });
  }

  void _onSearch(String keyword) {
    if (keyword.trim().isEmpty) return;
    _saveRecentSearch(keyword);
    Navigator.pop(context, keyword);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 1,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          controller: _textController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: '리뷰 검색',
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: 16,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
          textInputAction: TextInputAction.search,
          onSubmitted: _onSearch,
        ),
        actions: [
          if (_textController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.black54),
              onPressed: () {
                _textController.clear();
                setState(() {});
              },
            ),
          TextButton(
            onPressed: () => _onSearch(_textController.text),
            child: const Text(
              '검색',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_recentSearches.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '최근 검색어',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: _clearRecentSearches,
                    child: const Text(
                      '전체 삭제',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _recentSearches.length,
                itemBuilder: (context, index) {
                  final keyword = _recentSearches[index];
                  return ListTile(
                    leading: const Icon(
                      Icons.history,
                      color: Colors.black54,
                      size: 20,
                    ),
                    title: Text(
                      keyword,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.black45,
                        size: 18,
                      ),
                      onPressed: () => _removeRecentSearch(keyword),
                    ),
                    onTap: () => _onSearch(keyword),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
} 