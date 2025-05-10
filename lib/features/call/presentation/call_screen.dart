// ✅ call_screen.dart (리팩토링된 메인 파일)
import 'package:alfred_clean/features/call/presentation/voice_command_bottom_sheet.dart';
import 'package:flutter/material.dart';
import '../../../common/overay/alfred_loading_overlay.dart';
import '../../../utils/query_utils.dart';
import '../model/community_post.dart';
import '../model/event.dart';
import '../model/hostpital.dart';
import '../model/product.dart';
import '../model/youtube_video.dart';
import '../service/recommendation_service.dart';
import 'package:alfred_clean/features/call/presentation/call_screen_body.dart';


class CallScreen extends StatefulWidget {
  const CallScreen({super.key});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final TextEditingController _commandController = TextEditingController();

  bool _isLoading = false;
  bool _isListening = false;
  int _selectedProcedureTab = 0;
  String? _selectedGender;
  String? _selectedAge;
  String? _errorMessage;
  String _selectedCategory = '쇼핑';

  Map<String, List<Product>> _categorizedProducts = {};
  List<CommunityPost> _communityPosts = [];
  List<Event> _events = [];
  List<YouTubeVideo> _youtubeVideos = [];
  List<Hospital> _hospitals = [];
  int _createdAt = 0;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('추천 결과', style: TextStyle(fontSize: 16, color: Colors.black)),
          backgroundColor: Colors.white,
          elevation: 0.5,
          // iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: Stack(
          children: [
            _isLoading
                ? const AlfredLoadingOverlay()
                : CallScreenBody(
              createdAt: _createdAt,
              categorizedProducts: _categorizedProducts,
              communityPosts: _communityPosts,
              events: _events,
              hospitals: _hospitals,
              youtubeVideos: _youtubeVideos,
              selectedProcedureTab: _selectedProcedureTab,
              onProcedureTabChanged: (i) => setState(() => _selectedProcedureTab = i),
            ),
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

  Future<void> _handleVoiceCommand() async {
    _commandController.clear();
    String? rawQuery = await VoiceCommandBottomSheet.show(
      context: context,
      selectedCategory: _selectedCategory,
      selectedGender: _selectedGender,
      selectedAge: _selectedAge,
      errorMessage: _errorMessage,
      controller: _commandController,
      isListening: _isListening,
      isLoading: _isLoading,
      onCategoryChanged: (v) => setState(() => _selectedCategory = v),
      onGenderChanged: (v) => setState(() => _selectedGender = v),
      onAgeChanged: (v) => setState(() => _selectedAge = v),
    );
    if (rawQuery == null || rawQuery.isEmpty) return;

    while (true) {
      final fullQuery = QueryUtils.appendGenderAndAge(rawQuery!, _selectedGender, _selectedAge);
      setState(() => _isLoading = true);

      bool success = await RecommendationService.fetch(
        query: fullQuery,
        selectedCategory: _selectedCategory,
        onSuccess: (data) => setState(() {
          _categorizedProducts = data.products;
          _communityPosts = data.communityPosts;
          _events = data.events;
          _hospitals = data.hospitals;
          _youtubeVideos = data.youtubeVideos;
          _createdAt = data.createdAt;
          _errorMessage = null;
        }),
        onError: (msg) => setState(() => _errorMessage = msg),
      );

      // 항상 로딩 해제
      setState(() => _isLoading = false);

      // Not ItemType 에러: 상태 초기화 + 긴 SnackBar 띄우고 종료
      if (_errorMessage == 'itemType') {
        setState(() {
          _selectedCategory = '쇼핑';
          _selectedGender = null;
          _selectedAge = null;
          _errorMessage = null;
        });
        _commandController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('어떤 물건인지 더 구체적으로 말씀해 주세요! 예: “여성용 여름 반팔 티셔츠” 같이요 😊'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 5),
          ),
        );
        break;
      }

      // 성공 시 종료
      if (success) break;

      // 그 외 에러는 다시 바텀시트 열기
      rawQuery = await VoiceCommandBottomSheet.show(
        context: context,
        selectedCategory: _selectedCategory,
        selectedGender: _selectedGender,
        selectedAge: _selectedAge,
        errorMessage: _errorMessage,
        controller: _commandController,
        isListening: _isListening,
        isLoading: _isLoading,
        onCategoryChanged: (v) => setState(() => _selectedCategory = v),
        onGenderChanged: (v) => setState(() => _selectedGender = v),
        onAgeChanged: (v) => setState(() => _selectedAge = v),
      );
      if (rawQuery == null || rawQuery.isEmpty) break;
    }
  }
}
