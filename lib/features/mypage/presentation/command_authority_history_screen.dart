import 'package:flutter/material.dart';
import '../data/command_authority_service.dart';
import '../model/command_authority_history.dart';
import '../model/paginated_command_authority_history.dart';
import 'widget/command_authority_history_card.dart';

class CommandAuthorityHistoryScreen extends StatefulWidget {
  const CommandAuthorityHistoryScreen({Key? key}) : super(key: key);

  @override
  State<CommandAuthorityHistoryScreen> createState() => _CommandAuthorityHistoryScreenState();
}

class _CommandAuthorityHistoryScreenState extends State<CommandAuthorityHistoryScreen> {
  final _service = CommandAuthorityService();
  final _scrollController = ScrollController();
  final _histories = <CommandAuthorityHistory>[];
  
  bool _isLoading = false;
  bool _hasNextPage = true;
  int _currentPage = 0;
  static const _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadMore();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMore() async {
    if (_isLoading || !_hasNextPage) return;

    setState(() => _isLoading = true);

    try {
      final PaginatedCommandAuthorityHistory response = 
          await _service.getCommandAuthorityHistory(
        page: _currentPage,
        size: _pageSize,
      );

      setState(() {
        _histories.addAll(response.content);
        _hasNextPage = response.hasNextPage;
        _currentPage++;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('명령권 내역을 불러오는데 실패했습니다.')),
      );
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _onRefresh() async {
    setState(() {
      _histories.clear();
      _currentPage = 0;
      _hasNextPage = true;
    });
    await _loadMore();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('명령권 내역'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: _histories.isEmpty && _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                controller: _scrollController,
                itemCount: _histories.length + (_hasNextPage ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _histories.length) {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                        child: _isLoading
                            ? const CircularProgressIndicator()
                            : const SizedBox.shrink(),
                      ),
                    );
                  }
                  return CommandAuthorityHistoryCard(
                    history: _histories[index],
                  );
                },
              ),
      ),
    );
  }
} 