import 'package:flutter/material.dart';

class ButlerCharacter extends StatelessWidget {
  final double size;
  final Color? color;

  const ButlerCharacter({
    super.key,
    this.size = 100,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: ButlerPainter(color: color ?? Theme.of(context).primaryColor),
    );
  }
}

class ButlerPainter extends CustomPainter {
  final Color color;

  ButlerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // 머리 그리기
    final headRadius = size.width * 0.3;
    canvas.drawCircle(
      Offset(size.width / 2, size.height * 0.3),
      headRadius,
      paint,
    );

    // 몸통 그리기
    final bodyPath = Path()
      ..moveTo(size.width * 0.3, size.height * 0.4)
      ..lineTo(size.width * 0.7, size.height * 0.4)
      ..lineTo(size.width * 0.8, size.height * 0.8)
      ..lineTo(size.width * 0.2, size.height * 0.8)
      ..close();
    canvas.drawPath(bodyPath, paint);

    // 넥타이 그리기
    final tiePath = Path()
      ..moveTo(size.width * 0.45, size.height * 0.4)
      ..lineTo(size.width * 0.55, size.height * 0.4)
      ..lineTo(size.width * 0.5, size.height * 0.6)
      ..close();
    canvas.drawPath(tiePath, paint);

    // 눈 그리기
    final eyePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(
      Offset(size.width * 0.4, size.height * 0.25),
      size.width * 0.05,
      eyePaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.6, size.height * 0.25),
      size.width * 0.05,
      eyePaint,
    );

    // 눈동자 그리기
    final pupilPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(
      Offset(size.width * 0.4, size.height * 0.25),
      size.width * 0.02,
      pupilPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.6, size.height * 0.25),
      size.width * 0.02,
      pupilPaint,
    );

    // 입 그리기
    final mouthPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.35),
        width: size.width * 0.2,
        height: size.height * 0.1,
      ),
      0,
      3.14,
      false,
      mouthPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 