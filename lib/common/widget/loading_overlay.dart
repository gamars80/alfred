import 'package:flutter/material.dart';

/// 재사용 가능한 로딩 오버레이 위젯
/// 
/// 전체 화면을 덮는 로딩 인디케이터를 제공합니다.
/// 실무에서 자주 사용되는 패턴을 구현했습니다.
class LoadingOverlay extends StatefulWidget {
  final String? message;
  final Color? backgroundColor;
  final Color? indicatorColor;
  final double? size;

  const LoadingOverlay({
    super.key,
    this.message,
    this.backgroundColor,
    this.indicatorColor,
    this.size,
  });

  @override
  State<LoadingOverlay> createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends State<LoadingOverlay> 
    with TickerProviderStateMixin {
  
  late final AnimationController _thinkingController;
  late final Animation<double> _thinkingAnimation;

  @override
  void initState() {
    super.initState();
    _thinkingController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _thinkingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _thinkingController,
      curve: Curves.easeInOut,
    ));
    
    _thinkingController.repeat();
  }

  @override
  void dispose() {
    _thinkingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.backgroundColor ?? Colors.black.withOpacity(0.3),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.blue.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 알프레드 아이콘
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.deepPurple,
                  backgroundImage: AssetImage('assets/icon/alfred_icon.png'),
                ),
              ),
              const SizedBox(height: 24),
              
              // 알프레드 이름과 AI 태그
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '알프레드',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'AI',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // 생각하는 애니메이션
              AnimatedBuilder(
                animation: _thinkingAnimation,
                builder: (context, child) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '생각중',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // 점 애니메이션
                      Row(
                        children: List.generate(3, (index) {
                          final delay = index * 0.2;
                          final opacity = _thinkingAnimation.value > delay 
                              ? (_thinkingAnimation.value - delay) / 0.8 
                              : 0.0;
                          return AnimatedOpacity(
                            opacity: opacity.clamp(0.0, 1.0),
                            duration: const Duration(milliseconds: 200),
                            child: Text(
                              '.',
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  );
                },
              ),
              
              if (widget.message != null) ...[
                const SizedBox(height: 16),
                Text(
                  widget.message!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// 작은 로딩 인디케이터
/// 
/// 버튼이나 작은 영역에서 사용할 수 있는 로딩 인디케이터입니다.
class SmallLoadingIndicator extends StatelessWidget {
  final Color? color;
  final double? size;

  const SmallLoadingIndicator({
    super.key,
    this.color,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size ?? 20,
      height: size ?? 20,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? Colors.white,
        ),
      ),
    );
  }
} 