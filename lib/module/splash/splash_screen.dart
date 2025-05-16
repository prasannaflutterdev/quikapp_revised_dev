import 'dart:async';
import 'package:flutter/material.dart';
import '../home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    final splashDuration = int.tryParse(const String.fromEnvironment(
            'SPLASH_DURATION',
            defaultValue: '3')) ??
        3;

    final animationType =
        const String.fromEnvironment('SPLASH_ANIMATION', defaultValue: 'rotate')
            .toLowerCase();

    _controller = AnimationController(
      duration: Duration(seconds: splashDuration),
      vsync: this,
    );

    switch (animationType) {
      case 'rotate':
        _animation = Tween<double>(begin: 0, end: 2).animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
        break;
      case 'zoom':
        _animation = Tween<double>(begin: 1, end: 1.2).animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
        break;
      case 'scale':
        _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
        break;
      case 'fade':
        _animation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
        break;
        default:
        _animation = Tween<double>(begin: 0, end: 1).animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    }

    _controller.forward();

    Timer(Duration(seconds: splashDuration), () {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()));
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _parseHexColor(String hexColor) {
    try {
      hexColor = hexColor.replaceAll('#', '');
      if (hexColor.length == 6) {
        hexColor = 'FF$hexColor';
      }
      return Color(int.parse(hexColor, radix: 16));
    } catch (e) {
      return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    final splashBgColor = _parseHexColor(const String.fromEnvironment(
        'SPLASH_BG_COLOR',
        defaultValue: '#FFFFFF'));

    final splashTagline =
        const String.fromEnvironment('SPLASH_TAGLINE', defaultValue: 'Welcome');

    final splashTaglineColor = _parseHexColor(const String.fromEnvironment(
        'SPLASH_TAGLINE_COLOR',
        defaultValue: '#000000'));

    return Scaffold(
      backgroundColor: splashBgColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _animation.value,
                  child: Transform.rotate(
                    angle: _animation.value * 2 * 3.14159,
                    child: Image.network(
                      const String.fromEnvironment('SPLASH', defaultValue: ''),
                      width: 200,
                      height: 200,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.image, size: 200);
                      },
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            Text(
              splashTagline,
              style: TextStyle(
                color: splashTaglineColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
