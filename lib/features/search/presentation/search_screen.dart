// lib/features/search/presentation/search_screen.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  List<String> _recent = [];

  @override
  void initState() {
    super.initState();
    _loadRecent();
  }

  Future<void> _loadRecent() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _recent = prefs.getStringList('recentSearch') ?? [];
    });
  }

  Future<void> _addRecent(String keyword) async {
    final prefs = await SharedPreferences.getInstance();
    _recent.remove(keyword);
    _recent.insert(0, keyword);
    if (_recent.length > 10) {
      _recent = _recent.sublist(0, 10);
    }
    await prefs.setStringList('recentSearch', _recent);
  }

  void _submit(String keyword) {
    final kw = keyword.trim();
    if (kw.isEmpty) return;
    _addRecent(kw);
    Navigator.pop(context, kw);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.search,
          onSubmitted: _submit,
          decoration: const InputDecoration(
            hintText: '검색어를 입력하세요',
            border: InputBorder.none,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_recent.isNotEmpty) ...[
              const Text(
                '최근 검색어',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _recent.map((kw) {
                  return ActionChip(
                    label: Text(kw),
                    onPressed: () => _submit(kw),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
