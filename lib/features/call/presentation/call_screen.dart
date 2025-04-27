import 'package:alfred_clean/features/call/presentation/widget/community_card.dart';
import 'package:alfred_clean/features/call/presentation/widget/product_card.dart';
import 'package:alfred_clean/features/call/presentation/widget/youtube_list.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../data/product_api.dart';
import '../data/beauty_api.dart';
import '../model/product.dart';
import '../model/community_post.dart';
import '../model/age_range.dart';
import '../model/youtube_video.dart';
import '../widget/voice_command_input_widget.dart';

class CallScreen extends StatefulWidget {
  const CallScreen({Key? key}) : super(key: key);

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  static const platform = MethodChannel('com.alfred/voice');

  final TextEditingController _commandController = TextEditingController();
  Key? _bottomSheetKey;
  bool _showingBottomSheet = false;
  bool _isLoading = false;
  bool _isListening = false;

  // 쇼핑 결과
  Map<String, List<Product>> _categorizedProducts = {};
  // 커뮤니티 결과
  List<CommunityPost> _communityPosts = [];
  // 유튜브 영상 결과
  List<YouTubeVideo> _youtubeVideos = [];

  final _currencyFormatter = NumberFormat('#,###', 'ko_KR');

  String? _selectedGender;
  String? _selectedAge;
  String? _errorMessage;
  String _selectedCategory = '쇼핑';

  // 쇼핑 API 호출
  Future<void> _fetchProducts(String query, {StateSetter? setModalState}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _communityPosts.clear();
      _youtubeVideos.clear();
    });
    setModalState?.call(() {});
    try {
      final api = ProductApi();
      final fullQuery = _appendGenderAndAge(query);
      final result = await api.fetchRecommendedProducts(fullQuery);
      setState(() {
        _categorizedProducts = result;
        _selectedGender = null;
        _selectedAge = null;
      });
      _closeBottomSheet();
    } catch (e) {
      _handleError(e, setModalState);
    } finally {
      setState(() => _isLoading = false);
      setModalState?.call(() {});
    }
  }

  // 뷰티 API 호출 (커뮤니티 + 유튜브)
  Future<void> _fetchCommunity(String query, {StateSetter? setModalState}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _categorizedProducts.clear();
    });
    setModalState?.call(() {});
    try {
      final api = BeautyApi();
      final result = await api.fetchBeautyData(query);
      setState(() {
        _communityPosts = result.communityPosts;
        _youtubeVideos = result.youtubeVideos;
      });
      _closeBottomSheet();
    } catch (e) {
      _handleError(e, setModalState);
    } finally {
      setState(() => _isLoading = false);
      setModalState?.call(() {});
    }
  }

  void _handleError(Object e, StateSetter? setModalState) {
    final msg = e.toString();
    if (setModalState != null) {
      setModalState(() {
        if (msg.contains('Not Gender')) _errorMessage = 'gender';
        else if (msg.contains('Not Age')) _errorMessage = 'age';
        else if (msg.contains('More Information')) _errorMessage = 'both';
      });
    } else {
      setState(() {
        if (msg.contains('Not Gender')) _errorMessage = 'gender';
        else if (msg.contains('Not Age')) _errorMessage = 'age';
        else if (msg.contains('More Information')) _errorMessage = 'both';
      });
      if (!_showingBottomSheet) _openBottomSheet();
    }
  }

  String _appendGenderAndAge(String query) {
    final parts = <String>[];
    if (query.trim().isNotEmpty) parts.add(query.trim());
    final g = _getGender(_selectedGender);
    final a = _getAge(_selectedAge);
    if (g != null) parts.add(g);
    if (a != null) parts.add(a);
    return parts.join(' ');
  }

  String? _getGender(String? code) {
    switch (code) {
      case 'MALE': return '남성';
      case 'FEMALE': return '여성';
      default: return null;
    }
  }

  String? _getAge(String? code) {
    switch (code) {
      case '0-5': return '0~5세';
      case '6-9': return '6~9세';
      case '10s': return '10대';
      case '20s': return '20대';
      case '30s': return '30대';
      case '40s': return '40대';
      case '50s': return '50대';
      case '60s':
      case '60+': return '60대';
      default: return null;
    }
  }

  Future<void> _startNativeListening(StateSetter setModalState) async {
    setModalState(() => _isListening = true);
    try {
      final res = await platform.invokeMethod<String>('startListening');
      if (res != null && res.isNotEmpty) setModalState(() => _commandController.text = res);
    } on PlatformException {
      // ignore
    }
    setModalState(() => _isListening = false);
  }

  Future<void> _openBottomSheet() async {
    setState(() {
      _commandController.clear();
      _selectedGender = null;
      _selectedAge = null;
      _errorMessage = null;
      _isListening = false;
    });
    _bottomSheetKey = UniqueKey();
    _showingBottomSheet = true;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) {
          return _buildBottomSheet(setModalState);
        },
      ),
    );
    setState(() => _showingBottomSheet = false);
  }

  Widget _buildBottomSheet(StateSetter setModalState) {
    final w = MediaQuery.of(context).size.width - 40;
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFDFDFD),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, -4))],
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        left: 20,
        right: 20,
        top: 24,
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          key: _bottomSheetKey,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCategorySelector(setModalState),
            const SizedBox(height: 16),
            VoiceCommandInputWidget(
              controller: _commandController,
              isListening: _isListening,
              isLoading: _isLoading,
              onMicPressed: () => _startNativeListening(setModalState),
              onSubmit: () {
                final q = _commandController.text.trim();
                if (q.isEmpty) {
                  Fluttertoast.showToast(msg: '검색어를 입력해주세요.', gravity: ToastGravity.BOTTOM);
                  return;
                }
                if (_selectedCategory == '쇼핑') _fetchProducts(q, setModalState: setModalState);
                else _fetchCommunity(q, setModalState: setModalState);
              },
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              _buildExtraInfoInput(setModalState),
              const SizedBox(height: 16),
              _buildSubmitButton(setModalState),
            ],
          ],
        ),
      ),
    );
  }

  /// 바텀시트가 떠 있는 상태라면 닫아줍니다.
  void _closeBottomSheet() {
    if (_showingBottomSheet) {
      Navigator.pop(context);
      _showingBottomSheet = false;
    }
  }

  Widget _buildCategorySelector(StateSetter setModalState) => Row(
    children: [
      const Text('카테고리:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)),
      const SizedBox(width: 8),
      DropdownButton<String>(
        value: _selectedCategory,
        dropdownColor: Colors.white,
        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
        items: const [
          DropdownMenuItem(value: '쇼핑', child: Text('쇼핑')),
          DropdownMenuItem(value: '시술커뮤니티', child: Text('시술커뮤니티')),
        ],
        onChanged: (v) => setModalState(() => _selectedCategory = v!),
      ),
    ],
  );

  Widget _buildSubmitButton(StateSetter setModalState) => ElevatedButton(
    onPressed: () {
      final q = _commandController.text.trim();
      if (_selectedCategory == '쇼핑') {
        if ((_errorMessage == 'gender' && _selectedGender == null) ||
            (_errorMessage == 'age' && _selectedAge == null) ||
            (_errorMessage == 'both' && (_selectedGender == null || _selectedAge == null))) {
          Fluttertoast.showToast(msg: '필수 선택 항목을 입력해주세요.', gravity: ToastGravity.BOTTOM);
          return;
        }
        _fetchProducts(q, setModalState: setModalState);
      } else {
        _fetchCommunity(q, setModalState: setModalState);
      }
    },
    style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
    child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('명령하기'),
  );

  Widget _buildExtraInfoInput(StateSetter setModalState) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (_errorMessage == 'gender' || _errorMessage == 'both')
        Row(
          children: [
            const Text('성별 선택:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            Radio<String>(value: 'MALE', groupValue: _selectedGender, onChanged: (v) => setModalState(() => _selectedGender = v)),
            const Text('남'),
            Radio<String>(value: 'FEMALE', groupValue: _selectedGender, onChanged: (v) => setModalState(() => _selectedGender = v)),
            const Text('여'),
          ],
        ),
      if (_errorMessage == 'age' || _errorMessage == 'both')
        Row(
          children: AgeRange.values
              .map((r) => ChoiceChip(
            label: Text(r.description),
            selected: _selectedAge == r.code,
            onSelected: (s) => setModalState(() => _selectedAge = s ? r.code : null),
          ))
              .toList(),
        ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('추천 결과', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Builder(
        builder: (_) {
          if (_isLoading) return const Center(child: CircularProgressIndicator());
          if (_communityPosts.isNotEmpty) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: _communityPosts.length,
                    itemBuilder: (c, i) => CommunityCard(post: _communityPosts[i]),
                  ),
                  const SizedBox(height: 16),
                  if (_youtubeVideos.isNotEmpty) YouTubeList(videos: _youtubeVideos),
                ],
              ),
            );
          }
          if (_categorizedProducts.isNotEmpty) {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _categorizedProducts.length,
              itemBuilder: (context, index) {
                final entry = _categorizedProducts.entries.elementAt(index);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.key,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Column(
                      children: entry.value.map((p) => ProductCard(product: p)).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],
                );
              },
            );
          }
          return const Center(
            child: Text(
              '추천된 데이터가 없습니다.',
              style: TextStyle(color: Colors.grey),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openBottomSheet,
        label: const Text('알프레드~'),
        icon: const Icon(Icons.mic),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }

  String _validUrl(String? url) {
    if (url == null || url.isEmpty) return 'https://via.placeholder.com/200';
    if (url.startsWith('//')) return 'https:$url';
    if (!url.startsWith('http')) return 'https://via.placeholder.com/200';
    return url;
  }
}
