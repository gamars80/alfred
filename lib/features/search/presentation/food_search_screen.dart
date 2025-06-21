import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FoodSearchScreen extends StatefulWidget {
  const FoodSearchScreen({super.key});

  @override
  State<FoodSearchScreen> createState() => _FoodSearchScreenState();
}

class _FoodSearchScreenState extends State<FoodSearchScreen> {
  final _textController = TextEditingController();
  SharedPreferences? _prefs;
  List<String> _recentSearches = [];
  static const _maxRecentSearches = 10;
  static const _prefsKey = 'food_recent_searches';

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

  void _performSearch(String keyword) async {
    if (keyword.trim().isEmpty) return;
    
    await _saveRecentSearch(keyword.trim());
    if (mounted) {
      Navigator.pop(context, keyword.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          '음식 재료 검색',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        children: [
          // 검색 입력 필드
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    autofocus: true,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      hintText: '검색어를 입력해주세요',
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.deepOrange),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search, color: Colors.deepOrange),
                        onPressed: () => _performSearch(_textController.text),
                      ),
                    ),
                    onSubmitted: _performSearch,
                  ),
                ),
              ],
            ),
          ),

          // 최근 검색어
          if (_recentSearches.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '최근 검색어',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
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
                      color: Colors.grey,
                      size: 20,
                    ),
                    title: Text(
                      keyword,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.grey,
                        size: 18,
                      ),
                      onPressed: () => _removeRecentSearch(keyword),
                    ),
                    onTap: () => _performSearch(keyword),
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