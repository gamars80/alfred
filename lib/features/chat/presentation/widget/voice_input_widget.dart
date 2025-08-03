import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:async';

/// 음성 입력 위젯
/// 
/// 사용자가 음성으로 메시지를 입력할 수 있는 위젯입니다.
/// 실무 수준의 디자인과 다양한 상태를 지원합니다.
class VoiceInputWidget extends StatefulWidget {
  final Function(String) onVoiceInput;
  final bool isLoading;
  final double? size;
  final Color? activeColor;
  final Color? inactiveColor;

  const VoiceInputWidget({
    super.key,
    required this.onVoiceInput,
    required this.isLoading,
    this.size,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  State<VoiceInputWidget> createState() => _VoiceInputWidgetState();
}

class _VoiceInputWidgetState extends State<VoiceInputWidget>
    with TickerProviderStateMixin {
  bool _isListening = false;
  late AnimationController _pulseController;
  late AnimationController _scaleController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size ?? 48.0;
    final activeColor = widget.activeColor ?? Colors.red;
    final inactiveColor = widget.inactiveColor ?? Colors.deepPurple;

    debugPrint('🎤 [VoiceInputWidget] build 호출 - _isListening: $_isListening');

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Tooltip(
          message: _isListening 
            ? '음성 인식 중입니다. 말씀하신 후 잠시 기다려주세요.'
            : '음성으로 메시지를 입력하세요',
          child: GestureDetector(
            onTapDown: (_) => _onTapDown(),
            onTapUp: (_) => _onTapUp(),
            onTapCancel: _onTapCancel,
            child: AnimatedBuilder(
              animation: Listenable.merge([_pulseAnimation, _scaleAnimation]),
              builder: (context, child) {
                debugPrint('🎤 [VoiceInputWidget] AnimatedBuilder - _isListening: $_isListening');
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      color: _isListening ? activeColor : inactiveColor,
                      borderRadius: BorderRadius.circular(size / 2),
                      boxShadow: [
                        BoxShadow(
                          color: (_isListening ? activeColor : inactiveColor).withOpacity(0.3),
                          blurRadius: _isListening ? 12 : 8,
                          offset: const Offset(0, 2),
                          spreadRadius: _isListening ? 2 : 0,
                        ),
                        if (_isListening)
                          BoxShadow(
                            color: activeColor.withOpacity(0.2),
                            blurRadius: _pulseAnimation.value * 20,
                            spreadRadius: _pulseAnimation.value * 5,
                          ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: null, // GestureDetector에서 처리하므로 여기서는 비활성화
                        borderRadius: BorderRadius.circular(size / 2),
                        child: Center(
                          child: _buildIcon(),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        // 상태 텍스트 제거 - 아이콘과 애니메이션으로만 상태 표시
        // if (_isListening) ...[
        //   const SizedBox(height: 8),
        //   AnimatedOpacity(
        //     opacity: _isListening ? 1.0 : 0.0,
        //     duration: const Duration(milliseconds: 300),
        //     child: Text(
        //       '듣는 중...',
        //       style: TextStyle(
        //         fontSize: 12,
        //         color: activeColor,
        //         fontWeight: FontWeight.w500,
        //       ),
        //     ),
        //   ),
        // ],
      ],
    );
  }

  Widget _buildIcon() {
    debugPrint('🎤 [VoiceInputWidget] _buildIcon 호출 - _isListening: $_isListening, isLoading: ${widget.isLoading}');
    
    if (widget.isLoading) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    if (_isListening) {
      debugPrint('🎤 [VoiceInputWidget] 듣는 중 아이콘 표시');
      return const Icon(
        Icons.mic_rounded,
        color: Colors.white,
        size: 24,
      );
    }

    debugPrint('🎤 [VoiceInputWidget] 기본 아이콘 표시');
    return const Icon(
      Icons.mic_none_rounded,
      color: Colors.white,
      size: 24,
    );
  }

  void _onTapDown() {
    debugPrint('🎤 [VoiceInputWidget] _onTapDown 호출됨');
    if (!_isListening && !widget.isLoading) {
      debugPrint('🎤 [VoiceInputWidget] 음성인식 상태 시작');
      // 즉시 상태 변경
      setState(() {
        _isListening = true;
      });
      debugPrint('🎤 [VoiceInputWidget] 상태 변경 완료 - _isListening: $_isListening');
      _scaleController.forward();
      _pulseController.repeat(reverse: true);
      // 음성인식 시작
      _startListening();
    }
  }

  void _onTapUp() {
    debugPrint('🎤 [VoiceInputWidget] _onTapUp 호출됨');
    // _onTapDown에서 이미 시작했으므로 여기서는 아무것도 하지 않음
  }

  void _onTapCancel() {
    if (_isListening) {
      setState(() {
        _isListening = false;
      });
      _scaleController.reverse();
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  void _startListening() async {
    if (widget.isLoading) return;

    debugPrint('🎤 [VoiceInputWidget] 음성인식 시작');
    
    // Flutter 강제 타이머 제거 - 네이티브 침묵 감지 사용
    // Timer(const Duration(milliseconds: 3500), () {
    //   if (mounted && _isListening) {
    //     setState(() {
    //       _isListening = false;
    //     });
    //     _scaleController.reverse();
    //     _pulseController.stop();
    //     _pulseController.reset();
    //     debugPrint('🎤 [VoiceInputWidget] 3.5초 후 자동 상태 변경');
    //   }
    // });
    
    try {
      const platform = MethodChannel('com.alfred/voice');
      debugPrint('🎤 [VoiceInputWidget] platform.invokeMethod 호출');
      final result = await platform.invokeMethod<String>('startListening');
      debugPrint('🎤 [VoiceInputWidget] 결과 수신: $result');
      
      if (mounted) {
        if (result != null && result.isNotEmpty) {
          debugPrint('🎤 [VoiceInputWidget] 음성인식 성공: $result');
          // 성공 시 즉시 상태 변경
          setState(() {
            _isListening = false;
          });
          _scaleController.reverse();
          _pulseController.stop();
          _pulseController.reset();
          widget.onVoiceInput(result);
        } else {
          debugPrint('🎤 [VoiceInputWidget] 빈 결과 수신');
          // UI 상태 초기화
          setState(() {
            _isListening = false;
          });
          _scaleController.reverse();
          _pulseController.stop();
          _pulseController.reset();
          
          // 스낵바로 더 나은 사용자 경험 제공
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.mic_off, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        '음성이 감지되지 않았습니다. 다시 말씀해주세요.',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
                backgroundColor: Colors.orange[600],
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                margin: const EdgeInsets.all(16),
                duration: const Duration(seconds: 3),
                action: SnackBarAction(
                  label: '확인',
                  textColor: Colors.white,
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  },
                ),
              ),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('🎤 [VoiceInputWidget] 오류 발생: $e');
      if (mounted) {
        if (e.toString().contains('PERMISSION_DENIED')) {
          debugPrint('🎤 [VoiceInputWidget] 권한 거부됨');
          await _handlePermissionDenied();
        } else if (e.toString().contains('No speech detected')) {
          debugPrint('🎤 [VoiceInputWidget] 음성 미감지');
          // UI 상태 초기화
          setState(() {
            _isListening = false;
          });
          _scaleController.reverse();
          _pulseController.stop();
          _pulseController.reset();
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.mic_off, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        '음성이 감지되지 않았습니다. 다시 말씀해주세요.',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
                backgroundColor: Colors.orange[600],
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                margin: const EdgeInsets.all(16),
                duration: const Duration(seconds: 3),
                action: SnackBarAction(
                  label: '확인',
                  textColor: Colors.white,
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  },
                ),
              ),
            );
          }
        } else {
          debugPrint('🎤 [VoiceInputWidget] 일반 오류');
          // UI 상태 초기화
          setState(() {
            _isListening = false;
          });
          _scaleController.reverse();
          _pulseController.stop();
          _pulseController.reset();
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        '음성 인식에 실패했습니다. 다시 시도해주세요.',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
                backgroundColor: Colors.red[600],
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                margin: const EdgeInsets.all(16),
                duration: const Duration(seconds: 3),
                action: SnackBarAction(
                  label: '확인',
                  textColor: Colors.white,
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  },
                ),
              ),
            );
          }
        }
      }
    } finally {
      debugPrint('🎤 [VoiceInputWidget] 음성인식 종료');
    }
  }

  Future<void> _handlePermissionDenied() async {
    final shouldOpenSettings = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          '마이크 권한 필요', 
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
        ),
        content: const Text(
          '음성 인식을 위해\n마이크 권한이 필요합니다.', 
          style: TextStyle(fontSize: 14), 
          textAlign: TextAlign.center
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), 
            child: const Text('취소')
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: const Text('권한 설정하기')
          ),
        ],
      ),
    );
    
    if (shouldOpenSettings == true) {
      await openAppSettings();
    }
  }



  @override
  void dispose() {
    _pulseController.dispose();
    _scaleController.dispose();
    super.dispose();
  }
} 