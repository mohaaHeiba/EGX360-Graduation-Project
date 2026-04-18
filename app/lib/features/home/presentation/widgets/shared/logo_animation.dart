import 'package:flutter/material.dart';

class EGXLogoStackLoop extends StatefulWidget {
  const EGXLogoStackLoop({super.key});
  @override
  State<EGXLogoStackLoop> createState() => _EGXLogoStackLoopState();
}

class _EGXLogoStackLoopState extends State<EGXLogoStackLoop>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _morphAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 17),
    );

    _morphAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: ConstantTween<double>(0.0),
        weight: 10,
      ), // نص 10ث
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeInOutQuart)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(1.0),
        weight: 5,
      ), // أيقونة 5ث
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeInOutQuart)),
        weight: 1,
      ),
    ]).animate(_controller);

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _morphAnimation,
      builder: (context, child) {
        return SizedBox(
          height: 40,
          width: 150,
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Positioned(
                left: -10,
                child: Opacity(
                  opacity: _morphAnimation.value,
                  child: Transform.scale(
                    scale: 0.7 + (0.3 * _morphAnimation.value),
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 45,
                      height: 45,
                    ),
                  ),
                ),
              ),
              _buildStackingLetters(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStackingLetters() {
    const String text = "EGX360";
    final List<double> startOffsets = [0, 18, 38, 55, 71, 88];
    return Stack(
      children: List.generate(text.length, (index) {
        return Transform.translate(
          offset: Offset(startOffsets[index] * (1 - _morphAnimation.value), 0),
          child: Opacity(
            opacity: (1.0 - _morphAnimation.value).clamp(0.0, 1.0),
            child: Text(
              text[index],
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
            ),
          ),
        );
      }),
    );
  }
}
