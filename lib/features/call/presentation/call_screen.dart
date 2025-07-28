// 🎨 Modern Call Screen - Redesigned with enhanced UI/UX
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

// 🎨 Modern Design Constants
class CallScreenTheme {
  static const Color primaryGradientStart = Color(0xFF667eea);
  static const Color primaryGradientEnd = Color(0xFF764ba2);
  static const Color secondaryGradientStart = Color(0xFFf093fb);
  static const Color secondaryGradientEnd = Color(0xFFf5576c);
  static const Color backgroundGradientStart = Color(0xFF667eea);
  static const Color backgroundGradientEnd = Color(0xFF764ba2);
  static const Color cardBackground = Color(0xFFffffff);
  static const Color textPrimary = Color(0xFF2d3748);
  static const Color textSecondary = Color(0xFF718096);
  static const Color accentColor = Color(0xFFed8936);
  static const double borderRadius = 20.0;
  static const double cardElevation = 8.0;
  static const Duration animationDuration = Duration(milliseconds: 300);
}

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
  String? _reason;

  Map<String, List<Product>> _categorizedProducts = {};
  List<CommunityPost> _communityPosts = [];
  List<Event> _events = [];
  List<YouTubeVideo> _youtubeVideos = [];
  List<Hospital> _hospitals = [];
  List<String>? _choiceItemTypes;
  int _createdAt = 0;
  int _id = 0;

  // Enhanced Animation Controllers
  late AnimationController _pulseController;
  late AnimationController _floatController;
  late AnimationController _glowController;
  late AnimationController _scaleController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _floatAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    // Enhanced Pulse Animation
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.elasticOut,
    ));

    // Smooth Floating Animation
    _floatController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    );
    _floatAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOut,
    ));

    // Enhanced Glow Animation
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    // Scale Animation for Interactions
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    // Start Animations
    _pulseController.repeat(reverse: true);
    _floatController.repeat(reverse: true);
    _glowController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _floatController.dispose();
    _glowController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFf8fafc),
              Color(0xFFe2e8f0),
              Color(0xFFcbd5e0),
            ],
          ),
        ),
        child: Stack(
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
      ),
      floatingActionButton: _buildModernFloatingActionButton(),
    );
  }



  Widget _buildModernFloatingActionButton() {
    if (_isLoading) return const SizedBox.shrink();
    
    return AnimatedBuilder(
      animation: Listenable.merge([
        _pulseAnimation,
        _floatAnimation,
        _glowAnimation,
        _scaleAnimation,
      ]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnimation.value * 6 - 3),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [
                    CallScreenTheme.primaryGradientStart,
                    CallScreenTheme.primaryGradientEnd,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  // Primary Shadow
                  BoxShadow(
                    color: CallScreenTheme.primaryGradientStart.withOpacity(0.4),
                    blurRadius: 20 + (_glowAnimation.value * 15),
                    offset: const Offset(0, 8),
                    spreadRadius: 2,
                  ),
                  // Glow Effect
                  BoxShadow(
                    color: CallScreenTheme.primaryGradientStart.withOpacity(_glowAnimation.value * 0.6),
                    blurRadius: 30 + (_glowAnimation.value * 20),
                    offset: const Offset(0, 0),
                    spreadRadius: 8,
                  ),
                  // Ambient Light
                  BoxShadow(
                    color: Colors.white.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    _scaleController.forward().then((_) {
                      _scaleController.reverse();
                    });
                    context.go('/guided-chat');
                  },
                  borderRadius: BorderRadius.circular(44),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Pulse Background
                        Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Container(
                            width: 56,
                            height: 56,
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
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Alfred Icon
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: const DecorationImage(
                              image: AssetImage('assets/icon/alfred_icon.png'),
                              fit: BoxFit.cover,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                        // Chat Bubble Indicator
                        Positioned(
                          right: -4,
                          top: -4,
                          child: Transform.scale(
                            scale: 0.8 + (_pulseAnimation.value * 0.3),
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: CallScreenTheme.accentColor,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.chat_bubble,
                                size: 10,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        // Alfred Label
                        Positioned(
                          bottom: -35,
                          child: AnimatedOpacity(
                            opacity: _glowAnimation.value * 0.9,
                            duration: const Duration(milliseconds: 300),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Text(
                                '알프레드',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
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
          ),
        );
      },
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
            borderRadius: BorderRadius.circular(12),
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
          SnackBar(
            content: const Text('어떤 물건인지 더 구체적으로 말씀해 주세요! 예: "여성용 여름 반팔 티셔츠" 같이요 😊'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5),
            backgroundColor: CallScreenTheme.primaryGradientStart,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        break;
      }

      if (_errorMessage == 'alreadyRecommend') {
        final wasShopping = _selectedCategory == '쇼핑';

        setState(() {
          if (wasShopping) {
            _selectedCategory = '쇼핑';
          }
          _errorMessage = null;
        });

        _commandController.clear();

        final snackMessage = wasShopping
            ? '주인님 이미 유사한 조건의 상품 추천이 존재 합니다. 24시간 뒤에 새롭게 추천 됩니다. 😊'
            : '주인님 이미 유사한 조건의 추천이 존재 합니다. 24시간 뒤에 새롭게 추천 됩니다. 😊';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(snackMessage),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5),
            backgroundColor: CallScreenTheme.primaryGradientStart,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
