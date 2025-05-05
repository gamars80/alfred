import 'package:alfred_clean/features/call/presentation/widget/event_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

import 'package:alfred_clean/features/call/presentation/widget/community_card.dart';
import 'package:alfred_clean/features/call/presentation/widget/hospital_card.dart';
import 'package:alfred_clean/features/call/presentation/widget/product_card.dart';
import 'package:alfred_clean/features/call/presentation/widget/youtube_list.dart';
import 'package:alfred_clean/features/call/presentation/widget/voice_command_input_widget.dart';
import '../../../common/overay/alfred_loading_overlay.dart';
import '../data/product_api.dart';
import '../data/beauty_api.dart';
import '../model/event.dart';

import '../model/hostpital.dart';
import '../model/product.dart';
import '../model/community_post.dart';
import '../model/age_range.dart';
import '../model/youtube_video.dart';

class CallScreen extends StatefulWidget {
  const CallScreen({Key? key}) : super(key: key);

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  static const platform = MethodChannel('com.alfred/voice');

  final TextEditingController _commandController = TextEditingController();
  bool _isLoading = false;
  bool _isListening = false;

  Map<String, List<Product>> _categorizedProducts = {};
  List<CommunityPost> _communityPosts = [];
  List<Event> _events = [];
  List<YouTubeVideo> _youtubeVideos = [];
  List<Hospital> _hospitals = [];

  String? _selectedGender;
  String? _selectedAge;
  String? _errorMessage;
  String _selectedCategory = '쇼핑';

  int _selectedProcedureTab = 0; // 상단에 추가 (상태)

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('추천 결과', style: TextStyle(fontSize: 15, color: Colors.black)),
          backgroundColor: Colors.white,
          elevation: 0.5,
          iconTheme: const IconThemeData(color: Colors.black),

        ),
        body: Stack(
          children: [
            _isLoading ? const AlfredLoadingOverlay() : _buildMainContent(),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _handleVoiceCommand,
          label: const Text('알프레드~'),
          icon: const Icon(Icons.mic),
          backgroundColor: Colors.deepPurple,
        ),
      ),
    );
  }


  Widget _buildMainContent() {
    final List<Widget> items = [];

    if (_communityPosts.isNotEmpty) {
      items.add(_buildSectionTitle('추천 커뮤니티'));
      items.addAll(_communityPosts.map((post) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: CommunityCard(post: post),
      )));
    }

    // ✅ 여기가 중요!
    if (_events.isNotEmpty || _hospitals.isNotEmpty) {
      items.add(_buildSectionTitle('추천 시술'));
      items.add(_buildEventHospitalTabs());
    }

    if (_youtubeVideos.isNotEmpty) {
      items.add(_buildSectionTitle('추천 Youtube 영상'));
      items.add(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: YouTubeList(videos: _youtubeVideos),
      ));
    }

    if (_categorizedProducts.isNotEmpty) {
      items.addAll(_categorizedProducts.entries.map((entry) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(entry.key),
            const SizedBox(height: 8),
            ...entry.value.map((p) => ProductCard(product: p)).toList(),
            const SizedBox(height: 24),
          ],
        ),
      )));
    }

    if (items.isEmpty) {
      return const Center(
        child: Text('추천된 데이터가 없습니다.', style: TextStyle(color: Colors.grey)),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: items,
    );
  }

  Widget _buildEventHospitalTabs() {
    return DefaultTabController(
      length: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TabBar(
            onTap: (index) => setState(() => _selectedProcedureTab = index),
            labelColor: Colors.deepPurple,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.deepPurple,
            tabs: const [
              Tab(text: '이벤트'),
              Tab(text: '병원'),
            ],
          ),
          const SizedBox(height: 12),

          // 👇 탭 인덱스에 따라 위젯 리스트 조건부 렌더링
          if (_selectedProcedureTab == 0)
            ..._events.map((e) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: EventCard(event: e),
            )),
          if (_selectedProcedureTab == 1)
            ..._hospitals.map((h) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: HospitalCard(hospital: h),
            )),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 24, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.deepPurple,
        ),
      ),
    );
  }

  Future<void> _handleVoiceCommand() async {
    _commandController.clear();
    String? rawQuery = await _openBottomSheet();
    if (rawQuery == null || rawQuery.isEmpty) return;

    while (true) {
      final fullQuery = _appendGenderAndAge(rawQuery!);
      setState(() => _isLoading = true);
      bool success = await _fetchRecommendation(fullQuery);
      setState(() => _isLoading = false);
      if (success) break;
      rawQuery = await _openBottomSheet();
      if (rawQuery == null || rawQuery.isEmpty) break;
    }
  }

  Future<bool> _fetchRecommendation(String query) async {
    try {
      if (_selectedCategory == '쇼핑') {
        await _fetchProducts(query);
      } else {
        await _fetchCommunity(query);
      }
      setState(() => _errorMessage = null);
      return true;
    } catch (e) {
      return await _handleError(e);
    }
  }

  Future<String?> _openBottomSheet() async {
    return await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCategorySelector(setModalState),
                const SizedBox(height: 16),
                if (_errorMessage == null)
                  VoiceCommandInputWidget(
                    controller: _commandController,
                    isListening: _isListening,
                    isLoading: _isLoading,
                    onMicPressed: () async {
                      setModalState(() => _isListening = true);
                      try {
                        final res = await platform.invokeMethod<String>('startListening');
                        if (res != null && res.isNotEmpty) {
                          _commandController.text = res;
                        }
                      } catch (_) {}
                      setModalState(() => _isListening = false);
                    },
                    onSubmit: () {
                      final q = _commandController.text.trim();
                      if (q.isEmpty) {
                        Fluttertoast.showToast(msg: '검색어를 입력해주세요.');
                        return;
                      }
                      Navigator.pop(context, q);
                    },
                    category: _selectedCategory,
                  )
                else
                  _buildExtraInfoInputForError(setModalState, context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExtraInfoInputForError(StateSetter setModalState, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_errorMessage == 'gender' || _errorMessage == 'both') ...[
          const Text('성별을 선택해주세요', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(
            children: [
              Radio<String>(value: 'MALE', groupValue: _selectedGender, onChanged: (v) => setModalState(() => _selectedGender = v)),
              const Text('남자'),
              const SizedBox(width: 16),
              Radio<String>(value: 'FEMALE', groupValue: _selectedGender, onChanged: (v) => setModalState(() => _selectedGender = v)),
              const Text('여자'),
            ],
          ),
        ],
        if (_errorMessage == 'age' || _errorMessage == 'both') ...[
          const SizedBox(height: 16),
          const Text('연령대를 선택해주세요', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AgeRange.values.map((r) {
              return ChoiceChip(
                label: Text(r.description),
                selected: _selectedAge == r.code,
                onSelected: (s) => setModalState(() => _selectedAge = s ? r.code : null),
              );
            }).toList(),
          ),
        ],
        const SizedBox(height: 16),
        Center(
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context, _commandController.text.trim()),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
            child: const Text('명령하기'),
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySelector(StateSetter setModalState) {
    return Row(
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
  }

  Future<void> _fetchProducts(String query) async {
    _communityPosts.clear();
    _youtubeVideos.clear();

    final api = ProductApi();
    final result = await api.fetchRecommendedProducts(query);
    setState(() {
      _categorizedProducts = result;
    });
  }

  Future<void> _fetchCommunity(String query) async {
    _categorizedProducts.clear();

    final api = BeautyApi();
    final result = await api.fetchBeautyData(query);
    setState(() {
      _communityPosts = result.communityPosts;
      _events = result.events;
      _hospitals = result.hospitals;
      _youtubeVideos = result.youtubeVideos;
    });
  }

  Future<bool> _handleError(Object e) async {
    final msg = e.toString();
    if (msg.contains('Not Gender')) {
      setState(() => _errorMessage = 'gender');
    } else if (msg.contains('Not Age')) {
      setState(() => _errorMessage = 'age');
    } else if (msg.contains('More Information')) {
      setState(() => _errorMessage = 'both');
    } else {
      Fluttertoast.showToast(msg: '알 수 없는 오류가 발생했습니다.');
      return true;
    }
    return false;
  }

  String _appendGenderAndAge(String base) {
    final parts = <String>[];
    if (base.trim().isNotEmpty) parts.add(base.trim());
    if (_selectedGender != null) parts.add(_selectedGender == 'MALE' ? '남성' : '여성');
    if (_selectedAge != null) parts.add(_mapAgeCodeToString(_selectedAge!));
    return parts.join(' ');
  }

  String _mapAgeCodeToString(String code) {
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
      default: return '';
    }
  }
}
