import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../model/chat_message.dart';
import '../service/guided_chat_service.dart';
import 'widget/chat_message_widget.dart';
import 'widget/chat_input_widget.dart';
import 'widget/choice_buttons_widget.dart';
import 'widget/voice_input_widget.dart';
import '../../../common/widget/loading_overlay.dart';

/// 선택형 AI 채팅 화면
/// 
/// 사용자가 카테고리를 선택하고 AI와 대화할 수 있는 화면입니다.
/// 실무 수준의 상태관리와 생명주기 안전성을 보장합니다.
class GuidedChatScreen extends StatefulWidget {
  const GuidedChatScreen({super.key});

  @override
  State<GuidedChatScreen> createState() => _GuidedChatScreenState();
}

class _GuidedChatScreenState extends State<GuidedChatScreen> 
    with TickerProviderStateMixin {
  
  // ===== Controllers =====
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final AnimationController _fadeAnimationController;
  late final AnimationController _slideAnimationController;
  
  // ===== State Variables =====
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _currentMainCategory;
  String? _currentSubCategory;
  String? _currentAgeGroup;  // 연령대 추가
  String? _errorMessage;
  
  // ===== Animation Values =====
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeChat();
  }

  void _initializeAnimations() {
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _slideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeAnimationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideAnimationController,
      curve: Curves.easeOutCubic,
    ));
  }

  void _initializeChat() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // AI 인사 메시지 추가
      _addMessage(
        ChatMessage.ai(
          '안녕하세요! 저는 알프레드입니다. 🏠\n\n무엇을 도와드릴까요?',
          metadata: {'type': 'greeting'},
        ),
      );
      
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _isLoading = false;
        });
        
        // 애니메이션 시작
        _fadeAnimationController.forward();
        _slideAnimationController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = '채팅을 초기화하는데 실패했습니다.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded),
        onPressed: () {
          debugPrint('🔍 [뒤로가기] 현재 상태:');
          debugPrint('  - _currentMainCategory: $_currentMainCategory');
          debugPrint('  - _currentSubCategory: $_currentSubCategory');
          debugPrint('  - _currentAgeGroup: $_currentAgeGroup');
          debugPrint('  - _messages.length: ${_messages.length}');
          
          // 현재 선택 단계에 따라 다른 동작 수행
          if (_currentAgeGroup != null) {
            debugPrint('🔄 [뒤로가기] 연령대 선택 단계 → 카테고리 선택으로 돌아가기');
            setState(() {
              _currentAgeGroup = null;
              // 연령대 선택 이후의 모든 메시지 제거 (인사 메시지 1개만 남김)
              if (_messages.length > 1) {
                _messages.removeRange(1, _messages.length);
              }
            });
            debugPrint('✅ [뒤로가기] 연령대 선택 해제 완료, 메시지 개수: ${_messages.length}');
          } else if (_currentSubCategory != null) {
            debugPrint('🔄 [뒤로가기] 카테고리 선택 단계 → 서비스 선택으로 돌아가기');
            setState(() {
              _currentSubCategory = null;
              // 카테고리 선택 이후의 모든 메시지 제거 (인사 메시지 1개만 남김)
              if (_messages.length > 1) {
                _messages.removeRange(1, _messages.length);
              }
            });
            debugPrint('✅ [뒤로가기] 카테고리 선택 해제 완료, 메시지 개수: ${_messages.length}');
          } else if (_currentMainCategory != null && _currentMainCategory!.isNotEmpty) {
            debugPrint('🔄 [뒤로가기] 서비스 선택 단계 → 초기 상태로 돌아가기');
            setState(() {
              _currentMainCategory = null;
              // 서비스 선택 이후의 모든 메시지 제거 (인사 메시지 1개만 남김)
              if (_messages.length > 1) {
                _messages.removeRange(1, _messages.length);
              }
            });
            debugPrint('✅ [뒤로가기] 서비스 선택 해제 완료, 메시지 개수: ${_messages.length}');
          } else {
            debugPrint('🔄 [뒤로가기] 초기 상태 → 메인 화면으로 이동');
            // 초기 상태 → 메인 화면으로 이동
            try {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                context.go('/main');
              }
            } catch (e) {
              debugPrint('뒤로가기 에러: $e');
              context.go('/main');
            }
          }
        },
        tooltip: '이전 단계로 돌아가기',
      ),
      title: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const CircleAvatar(
              radius: 16,
              backgroundColor: Colors.deepPurple,
              backgroundImage: AssetImage('assets/icon/alfred_icon.png'),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            '알프레드 AI',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.black87),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded),
          onPressed: _resetChat,
          tooltip: '대화 초기화',
        ),
        IconButton(
          icon: const Icon(Icons.help_outline_rounded),
          onPressed: _showHelp,
          tooltip: '도움말',
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingOverlay(
        message: '추천 결과를 분석하고 있습니다...',
      );
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          children: [
            // 채팅 메시지 영역
            Expanded(
              child: _buildChatArea(),
            ),
            
            // 선택 버튼들 (입력창이 표시되지 않을 때만)
            if (!_isLoading && _messages.isNotEmpty && !_shouldShowInputArea())
              _buildChoiceButtons(),
            
            // 입력 영역 (연령대 선택 후 또는 다른 카테고리 선택 후)
            if (_shouldShowInputArea())
              _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildChatArea() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        itemCount: _messages.length,
        itemBuilder: (context, index) {
          final message = _messages[index];
          return ChatMessageWidget(
            message: message,
            onProductTap: _handleProductTap,
          );
        },
      ),
    );
  }

  Widget _buildChoiceButtons() {
    return ChoiceButtonsWidget(
      currentMainCategory: _currentMainCategory,
      currentSubCategory: _currentSubCategory,
      currentAgeGroup: _currentAgeGroup,
      onMainCategorySelected: _handleMainCategorySelection,
      onSubCategorySelected: _handleSubCategorySelection,
      onAgeGroupSelected: _handleAgeGroupSelection,
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ChatInputWidget(
              controller: _messageController,
              isLoading: _isLoading,
              onSendMessage: _handleTextInput,
            ),
          ),
          const SizedBox(width: 12),
          VoiceInputWidget(
            onVoiceInput: _handleVoiceInput,
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _errorMessage ?? '오류가 발생했습니다.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _initializeChat,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('다시 시도'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===== Event Handlers =====

  void _handleMainCategorySelection(String category) async {
    if (!mounted || _isLoading) return;

    debugPrint('🎯 [메인카테고리] 선택: $category');
    
    // 빈 문자열이 들어오면 초기 상태로 리셋
    if (category.isEmpty) {
      debugPrint('🔄 [메인카테고리] 빈 문자열 감지, 초기 상태로 리셋');
      setState(() {
        _currentMainCategory = null;
        _currentSubCategory = null;
        _currentAgeGroup = null;
        // 모든 메시지 제거 (인사 메시지 1개만 남김)
        if (_messages.length > 1) {
          _messages.removeRange(1, _messages.length);
        }
      });
      return;
    }
    
    // 보고서 선택 시 출시 준비중 알럿 표시
    if (category == '보고서') {
      debugPrint('📊 [보고서] 출시 준비중 알럿 표시');
      _showComingSoonAlert();
      return;
    }
    
    setState(() {
      _currentMainCategory = category;
      _isLoading = true;
    });

    try {
      // AI 응답 추가
      final aiResponse = _getMainCategoryResponse(category);
      _addMessage(ChatMessage.ai(
        aiResponse, 
        metadata: {'type': 'main_category_selected'}
      ));

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = '카테고리 선택 중 오류가 발생했습니다.';
          _isLoading = false;
        });
      }
    }

    _scrollToBottom();
  }

  void _handleSubCategorySelection(String subCategory) async {
    if (!mounted || _isLoading) return;

    debugPrint('🎯 [서브카테고리] 선택: $subCategory');
    
    // 빈 문자열이 들어오면 이전 단계로 돌아가기
    if (subCategory.isEmpty) {
      debugPrint('🔄 [서브카테고리] 빈 문자열 감지, 이전 단계로 돌아가기');
      setState(() {
        _currentSubCategory = null;
        _currentAgeGroup = null;
        // 서브카테고리 선택 이후의 모든 메시지 제거 (인사 메시지 1개만 남김)
        if (_messages.length > 1) {
          _messages.removeRange(1, _messages.length);
        }
      });
      return;
    }
    
    setState(() {
      _currentSubCategory = subCategory;
      _isLoading = true;
    });

    try {
      // AI 응답 추가
      final aiResponse = _getSubCategoryResponse(subCategory);
      _addMessage(ChatMessage.ai(
        aiResponse, 
        metadata: {'type': 'sub_category_selected'}
      ));

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = '세부 카테고리 선택 중 오류가 발생했습니다.';
          _isLoading = false;
        });
      }
    }

    _scrollToBottom();
  }

  void _handleAgeGroupSelection(String ageGroup) async {
    if (!mounted || _isLoading) return;

    debugPrint('🎯 [연령대] 선택: $ageGroup');
    setState(() {
      _currentAgeGroup = ageGroup;
      _isLoading = true;
    });

    try {
      // AI 응답 추가
      final aiResponse = _getAgeGroupResponse(ageGroup);
      _addMessage(ChatMessage.ai(
        aiResponse, 
        metadata: {'type': 'age_group_selected'}
      ));

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = '연령대 선택 중 오류가 발생했습니다.';
          _isLoading = false;
        });
      }
    }

    _scrollToBottom();
  }

  void _handleTextInput(String message) async {
    if (!mounted || message.trim().isEmpty || _isLoading) return;

    // 사용자 메시지 추가
    _addMessage(ChatMessage.user(message));

    // 로딩 메시지 추가 (알프레드 생각 애니메이션)
    final loadingMessageId = DateTime.now().millisecondsSinceEpoch.toString();
    _addMessage(ChatMessage.ai(
      '알프레드가 생각중입니다...',
      metadata: {'type': 'loading', 'id': loadingMessageId},
    ));

    setState(() {
      _isLoading = true;
    });

    try {
      debugPrint('🔄 [GuidedChatScreen] GuidedChatService.generateResponse 호출 시작');
      // AI 응답 생성
      final aiResponse = await GuidedChatService.generateResponse(
        message,
        _currentMainCategory,
        _currentSubCategory,
        _currentAgeGroup,  // 연령대 정보 추가
      );
      debugPrint('✅ [GuidedChatScreen] GuidedChatService.generateResponse 성공: $aiResponse');
      
      if (mounted) {
        // 로딩 메시지 제거
        _messages.removeWhere((msg) => 
          msg.metadata?['type'] == 'loading' && 
          msg.metadata?['id'] == loadingMessageId
        );
        
        // 실제 응답 추가 (메시지와 메타데이터 분리)
        final messageText = aiResponse['message'] as String;
        final metadata = Map<String, dynamic>.from(aiResponse);
        metadata.remove('message'); // 메시지 텍스트는 제거하고 메타데이터만 남김
        
        _addMessage(ChatMessage.ai(messageText, metadata: metadata));
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        // 로딩 메시지 제거
        _messages.removeWhere((msg) => 
          msg.metadata?['type'] == 'loading' && 
          msg.metadata?['id'] == loadingMessageId
        );
        
        // 에러 메시지 처리
        final errorMessage = e.toString();
        debugPrint('🔍 [GuidedChatScreen] 에러 메시지: "$errorMessage"');
        String snackMessage = '죄송합니다. 응답을 생성하는데 실패했습니다.';
        
        if (errorMessage.contains('alreadyRecommend')) {
          debugPrint('✅ [GuidedChatScreen] Already Recommend 스낵바 표시');
          snackMessage = '주인님 이미 유사한 조건의 상품 추천이 존재 합니다. 24시간 뒤에 새롭게 추천 됩니다. 😊';
        } else if (errorMessage.contains('not_enough_command')) {
          debugPrint('✅ [GuidedChatScreen] Not enough Command 스낵바 표시');
          snackMessage = '명령권이 존재하지 않습니다. 내일 다시 시도해주세요';
        } else if (errorMessage.contains('itemType')) {
          debugPrint('✅ [GuidedChatScreen] ItemType 스낵바 표시');
          snackMessage = '어떤 물건인지 더 구체적으로 말씀해 주세요! 예: "여성용 여름 반팔 티셔츠" 같이요 😊';
        } else if (errorMessage.contains('쿼리가 너무 짧습니다')) {
          debugPrint('✅ [GuidedChatScreen] 쿼리 짧음 스낵바 표시');
          snackMessage = '더 구체적으로 말씀해주세요. 예: "여름 원피스 추천해줘"';
        } else {
          debugPrint('⚠️ [GuidedChatScreen] 알 수 없는 에러: "$errorMessage"');
        }
        
        // 스낵바로 에러 메시지 표시 (화면 상단에 표시)
        debugPrint('🎯 [GuidedChatScreen] 스낵바 표시 시도: "$snackMessage"');
        
        // 기존 스낵바 숨기기
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        
        // 새로운 스낵바 표시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(snackMessage),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5),
            margin: EdgeInsets.only(
              top: 50, // 화면 상단에서 50px 아래
              left: 16,
              right: 16,
            ),
            backgroundColor: Colors.red.shade600,
            action: SnackBarAction(
              label: '확인',
              textColor: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );
        
        debugPrint('✅ [GuidedChatScreen] 스낵바 표시 완료');
        
        setState(() {
          _isLoading = false;
        });
      }
    }

    _messageController.clear();
    _scrollToBottom();
  }

  void _handleVoiceInput(String voiceText) async {
    if (!mounted || voiceText.trim().isEmpty || _isLoading) return;

    // 사용자 메시지 추가 (음성 입력 표시)
    _addMessage(ChatMessage.user('🎤 $voiceText'));

    // 로딩 메시지 추가 (알프레드 생각 애니메이션)
    final loadingMessageId = DateTime.now().millisecondsSinceEpoch.toString();
    _addMessage(ChatMessage.ai(
      '알프레드가 생각중입니다...',
      metadata: {'type': 'loading', 'id': loadingMessageId},
    ));

    setState(() {
      _isLoading = true;
    });

    try {
      debugPrint('🔄 [GuidedChatScreen] GuidedChatService.generateResponse 호출 시작 (음성)');
      // AI 응답 생성
      final aiResponse = await GuidedChatService.generateResponse(
        voiceText,
        _currentMainCategory,
        _currentSubCategory,
        _currentAgeGroup,  // 연령대 정보 추가
      );
      debugPrint('✅ [GuidedChatScreen] GuidedChatService.generateResponse 성공 (음성): $aiResponse');
      
      if (mounted) {
        // 로딩 메시지 제거
        _messages.removeWhere((msg) => 
          msg.metadata?['type'] == 'loading' && 
          msg.metadata?['id'] == loadingMessageId
        );
        
        // 실제 응답 추가 (메시지와 메타데이터 분리)
        final messageText = aiResponse['message'] as String;
        final metadata = Map<String, dynamic>.from(aiResponse);
        metadata.remove('message'); // 메시지 텍스트는 제거하고 메타데이터만 남김
        
        _addMessage(ChatMessage.ai(messageText, metadata: metadata));
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        // 로딩 메시지 제거
        _messages.removeWhere((msg) => 
          msg.metadata?['type'] == 'loading' && 
          msg.metadata?['id'] == loadingMessageId
        );
        
        // 에러 메시지 처리
        final errorMessage = e.toString();
        String snackMessage = '죄송합니다. 응답을 생성하는데 실패했습니다.';
        
        if (errorMessage.contains('alreadyRecommend')) {
          snackMessage = '주인님 이미 유사한 조건의 상품 추천이 존재 합니다. 24시간 뒤에 새롭게 추천 됩니다. 😊';
        } else if (errorMessage.contains('not_enough_command')) {
          debugPrint('✅ [GuidedChatScreen] Not enough Command 스낵바 표시');
          snackMessage = '명령권이 존재하지 않습니다. 내일 다시 시도해주세요';
        } else if (errorMessage.contains('itemType')) {
          debugPrint('✅ [GuidedChatScreen] ItemType 스낵바 표시');
          snackMessage = '어떤 물건인지 더 구체적으로 말씀해 주세요! 예: "여성용 여름 반팔 티셔츠" 같이요 😊';
        } else if (errorMessage.contains('쿼리가 너무 짧습니다')) {
          debugPrint('✅ [GuidedChatScreen] 쿼리 짧음 스낵바 표시');
          snackMessage = '더 구체적으로 말씀해주세요. 예: "여름 원피스 추천해줘"';
        } else {
          debugPrint('⚠️ [GuidedChatScreen] 알 수 없는 에러: "$errorMessage"');
        }
        
        // 스낵바로 에러 메시지 표시 (화면 상단에 표시)
        debugPrint('🎯 [GuidedChatScreen] 스낵바 표시 시도: "$snackMessage"');
        
        // 기존 스낵바 숨기기
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        
        // 새로운 스낵바 표시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(snackMessage),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5),
            margin: EdgeInsets.only(
              top: 50, // 화면 상단에서 50px 아래
              left: 16,
              right: 16,
            ),
            backgroundColor: Colors.red.shade600,
            action: SnackBarAction(
              label: '확인',
              textColor: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );
        
        debugPrint('✅ [GuidedChatScreen] 스낵바 표시 완료');
        
        setState(() {
          _isLoading = false;
        });
      }
    }

    _scrollToBottom();
  }

  void _handleProductTap(Map<String, dynamic> product) {
    if (!mounted) return;
    
    // 상품 상세 페이지로 이동
    if (product['url'] != null) {
      context.go('/webview?url=${Uri.encodeComponent(product['url'])}&title=${Uri.encodeComponent(product['name'] ?? '상품 상세')}');
    }
  }

  void _resetChat() {
    if (!mounted) return;
    
    setState(() {
      _messages.clear();
      _currentMainCategory = null;
      _currentSubCategory = null;
      _currentAgeGroup = null;
      _isLoading = false;
      _errorMessage = null;
    });
    
    _initializeChat();
  }

  void _showHelp() {
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('도움말'),
        content: const Text(
          '1. 원하는 서비스를 선택하세요 (추천/보고서)\n'
          '2. 세부 카테고리를 선택하세요\n'
          '3. 음성이나 텍스트로 요청하세요\n'
          '4. AI가 개인화된 추천을 제공합니다',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _showComingSoonAlert() {
    if (!mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: false, // 배경 탭으로 닫기 방지
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.construction_rounded,
                color: Colors.blue,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              '출시 준비중',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '보고서 기능이 곧 출시됩니다! 📊',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '현재 추천 기능을 이용해보세요.\n더 나은 서비스를 위해 준비하고 있습니다.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text(
              '확인',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===== Utility Methods =====

  void _addMessage(ChatMessage message) {
    if (!mounted) return;
    
    setState(() {
      _messages.add(message);
    });
  }

  void _scrollToBottom() {
    if (!mounted) return;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _getMainCategoryResponse(String category) {
    switch (category) {
      case '추천':
        return '추천을 도와드릴게요! 🎯\n\n어떤 분야의 추천을 원하시나요?';
      case '보고서':
        return '보고서를 도와드릴게요! 📊\n\n어떤 종류의 보고서를 원하시나요?';
      default:
        return '어떤 도움이 필요하신가요?';
    }
  }

  String _getSubCategoryResponse(String subCategory) {
    if (subCategory == '패션쇼핑') {
      return '패션쇼핑을 선택하셨네요! 👗\n\n연령대를 선택해주세요.';
    }
    return '좋은 선택이에요! $subCategory 추천을 찾아드릴게요. 🎯\n\n음성으로 말씀하거나 텍스트로 입력해주세요.';
  }

  String _getAgeGroupResponse(String ageGroup) {
    String ageText = '';
    switch (ageGroup) {
      case 'TWENTY':
        ageText = '20대';
        break;
      case 'THIRTY':
        ageText = '30대';
        break;
      case 'FORTY':
        ageText = '40대';
        break;
      default:
        ageText = ageGroup;
    }
    return '$ageText 연령대를 선택하셨네요! 🎯\n\n원하시는 스타일이나 상품을 음성으로 말씀하거나 텍스트로 입력해주세요.';
  }

  bool _shouldShowInputArea() {
    debugPrint('🔍 [_shouldShowInputArea] 상태 확인:');
    debugPrint('  - _currentMainCategory: $_currentMainCategory');
    debugPrint('  - _currentSubCategory: $_currentSubCategory');
    debugPrint('  - _currentAgeGroup: $_currentAgeGroup');
    
    // 패션쇼핑의 경우 연령대까지 선택해야 입력 영역 표시
    if (_currentMainCategory == '추천' && _currentSubCategory == '패션쇼핑') {
      final result = _currentAgeGroup != null;
      debugPrint('  - 패션쇼핑 선택됨, 연령대 선택 여부: $result');
      return result;
    }
    // 다른 카테고리는 서브카테고리 선택 후 바로 입력 영역 표시
    final result = _currentSubCategory != null;
    debugPrint('  - 다른 카테고리, 서브카테고리 선택 여부: $result');
    return result;
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _fadeAnimationController.dispose();
    _slideAnimationController.dispose();
    super.dispose();
  }
} 