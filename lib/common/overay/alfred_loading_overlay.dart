import 'package:flutter/material.dart';

class AlfredLoadingOverlay extends StatefulWidget {
  const AlfredLoadingOverlay({Key? key}) : super(key: key);

  @override
  State<AlfredLoadingOverlay> createState() => _AlfredLoadingOverlayState();
}

class _AlfredLoadingOverlayState extends State<AlfredLoadingOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _jumpController;
  late final AnimationController _rotateController;
  late final Animation<double> _jumpAnimation;
  late final Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();

    _jumpController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _jumpAnimation = Tween<double>(begin: 0, end: -20).animate(
      CurvedAnimation(parent: _jumpController, curve: Curves.easeInOut),
    );

    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _rotateAnimation = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(parent: _rotateController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _jumpController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: Listenable.merge([_jumpAnimation, _rotateAnimation]),
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _jumpAnimation.value),
                  child: Transform.rotate(
                    angle: _rotateAnimation.value,
                    child: child,
                  ),
                );
              },
              child: _buildAlfredCharacter(),
            ),
            const SizedBox(height: 24),
            const Text(
              '알프레드가 열심히 준비 중입니다!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlfredCharacter() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.deepPurple.shade400,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Icon(Icons.person, color: Colors.white, size: 50),
          Positioned(
            top: 20,
            child: Icon(Icons.emoji_objects, color: Colors.white, size: 24), // 모자 느낌
          ),
        ],
      ),
    );
  }
}
