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
import 'package:go_router/go_router.dart';

class CallScreen extends StatefulWidget {
  const CallScreen({super.key});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> with TickerProviderStateMixin {
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

  // 애니메이션 컨트롤러들
  late AnimationController _pulseController;
  late AnimationController _floatController;
  late AnimationController _glowController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _floatAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    // 펄스 애니메이션 (알프레드 호출 느낌)
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // 플로팅 애니메이션 (부드러운 움직임)
    _floatController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    _floatAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOut,
    ));

    // 글로우 애니메이션 (빛나는 효과)
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    // 애니메이션 시작
    _pulseController.repeat(reverse: true);
    _floatController.repeat(reverse: true);
    _glowController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _floatController.dispose();
    _glowController.dispose();
    super.dispose();
  }

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
              return AnimatedBuilder(
                animation: Listenable.merge([_pulseAnimation, _floatAnimation, _glowAnimation]),
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _floatAnimation.value * 4 - 2),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          // 메인 그림자
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                            spreadRadius: 2,
                          ),
                          // 글로우 효과
                          BoxShadow(
                            color: const Color(0xFF667eea).withOpacity(_glowAnimation.value * 0.3),
                            blurRadius: 20 + (_glowAnimation.value * 10),
                            offset: const Offset(0, 0),
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            context.go('/guided-chat');
                          },
                          borderRadius: BorderRadius.circular(40),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // 펄스 애니메이션 배경
                                Transform.scale(
                                  scale: _pulseAnimation.value,
                                  child: Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: const LinearGradient(
                                        colors: [Colors.white, Color(0xFFf8f9ff)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                // 알프레드 아이콘
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: const DecorationImage(
                                      image: AssetImage('assets/icon/alfred_icon.png'),
                                      fit: BoxFit.cover,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),
                                // 채팅 버블 효과 (애니메이션)
                                Positioned(
                                  right: -2,
                                  top: -2,
                                  child: Transform.scale(
                                    scale: 0.8 + (_pulseAnimation.value * 0.2),
                                    child: Container(
                                      width: 16,
                                      height: 16,
                                      decoration: BoxDecoration(
                                        color: Colors.orange,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 2),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.2),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.chat_bubble,
                                        size: 8,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                // "알프레드" 텍스트 (호버 시 표시)
                                Positioned(
                                  bottom: -30,
                                  child: AnimatedOpacity(
                                    opacity: _glowAnimation.value * 0.8,
                                    duration: const Duration(milliseconds: 300),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.7),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Text(
                                        '알프레드',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
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
