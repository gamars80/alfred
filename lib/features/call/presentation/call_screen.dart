// ✅ call_screen.dart (리팩토링된 메인 파일)
import 'package:alfred_clean/features/call/presentation/voice_command_bottom_sheet.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
  String? _selectedGender;
  String? _selectedAge;
  String? _errorMessage;
  String _selectedCategory = '';
  String _resultCategory = '';
  String? _recipeSummary;
  String? _requiredIngredients;
  String? _suggestionReason;
  String? _reason; // 뷰티케어 추천 이유

  Map<String, List<Product>> _categorizedProducts = {};
  List<CommunityPost> _communityPosts = [];
  List<Event> _events = [];
  List<YouTubeVideo> _youtubeVideos = [];
  List<Hospital> _hospitals = [];
  List<String>? _choiceItemTypes;
  int _createdAt = 0;
  int _id = 0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text('추천 결과', style: TextStyle(fontSize: 20, color: Colors.black)),
            backgroundColor: Colors.white,
            elevation: 0.5,
            iconTheme: const IconThemeData(color: Colors.black),
          ),
          body: Stack(
            children: [
              _isLoading
                  ? const AlfredLoadingOverlay()
                  : CallScreenBody(
                      key: UniqueKey(),
                      id: _id,
                      createdAt: _createdAt,
                      categorizedProducts: _categorizedProducts,
                      communityPosts: _communityPosts,
                      events: _events,
                      hospitals: _hospitals,
                      youtubeVideos: _youtubeVideos,
                      selectedCategory: _resultCategory,
                      recipeSummary: _recipeSummary,
                      requiredIngredients: _requiredIngredients,
                      suggestionReason: _suggestionReason,
                      reason: _reason,
                    ),
            ],
          ),
          floatingActionButton: Builder(
            builder: (context) {
              if (_isLoading) return const SizedBox.shrink();
              return FloatingActionButton.extended(
                onPressed: _handleVoiceCommand,
                label: const Text('알프레드~'),
                icon: const Icon(Icons.mic),
                backgroundColor: Colors.deepPurple,
              );
            },
          ),
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
          _id = data.id;
          _createdAt = data.createdAt;
          _recipeSummary = data.recipeSummary;
          _requiredIngredients = data.requiredIngredients?.join(', ');
          _suggestionReason = data.suggestionReason;
          _reason = data.reason;
          // ── 여기서 성별/연령대 초기화 ───────────────────
          _selectedGender = null;
          _selectedAge = null;
          _errorMessage = null;
        }),
        onError: (msg) => setState(() => _errorMessage = msg),
        onChoiceType: (items) => setState(() {
          _choiceItemTypes = items;
          _errorMessage = 'Choice Type';
        }),
      );

      setState(() => _isLoading = false);

      if (success) {
        setState(() {
          _resultCategory = _selectedCategory;
          _selectedCategory = '';
        });
        if (_resultCategory == '쇼핑' || _resultCategory == '음식/식자재' || _resultCategory == '뷰티케어') {
          Flushbar(
            message: '현재 결과는 일부입니다. 히스토리에서 모두 확인하세요 🛍️',
            duration: const Duration(seconds: 3),
            margin: const EdgeInsets.fromLTRB(12, kToolbarHeight + 12, 12, 0),
            borderRadius: BorderRadius.circular(8),
            backgroundColor: Colors.black87,
            flushbarPosition: FlushbarPosition.TOP,
            animationDuration: const Duration(milliseconds: 500),
          ).show(context);
        }
        break;
      }

      if (_errorMessage == 'Choice Type' && _choiceItemTypes != null) {
        Fluttertoast.showToast(
          msg: '죄송합니다 주인님 ${_choiceItemTypes!.join(', ')} 중에 하나만 명령해 주세요',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
        );
        setState(() {
          _errorMessage = null;
          _choiceItemTypes = null;
        });
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
        continue;
      }

      if (_errorMessage == 'itemType') {
        setState(() {
          _selectedCategory = '쇼핑';
          _errorMessage = null;
        });
        _commandController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('어떤 물건인지 더 구체적으로 말씀해 주세요! 예: "여성용 여름 반팔 티셔츠" 같이요 😊'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 5),
          ),
        );
        break;
      }

      if (_errorMessage == 'alreadyRecommend') {
        final wasShopping = _selectedCategory == '쇼핑';

        setState(() {
          // 쇼핑이었을 때만 카테고리를 '쇼핑'으로 설정 (실제로는 이미 '쇼핑' 상태이므로 유지)
          if (wasShopping) {
            _selectedCategory = '쇼핑';
          }
          // 시술/성형이었을 땐 _selectedCategory를 그대로 두어야 하므로 별도 처리 없음
          _errorMessage = null;
        });

        _commandController.clear();

        // 쇼핑 메시지와 일반 메시지를 분기
        final snackMessage = wasShopping
            ? '주인님 이미 유사한 조건의 상품 추천이 존재 합니다. 24시간 뒤에 새롭게 추천 됩니다. 😊'
            : '주인님 이미 유사한 조건의 추천이 존재 합니다. 24시간 뒤에 새롭게 추천 됩니다. 😊';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(snackMessage),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5),
          ),
        );

        break;
      }

      if (_errorMessage == 'not_enough_command') {
        setState(() {
          _errorMessage = null;
        });
        _commandController.clear();
        
        Fluttertoast.showToast(
          msg: '명령권이 존재하지 않습니다. 내일 다시 시도해주세요',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
        );
        
        break;
      }

      if (success) break;

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
