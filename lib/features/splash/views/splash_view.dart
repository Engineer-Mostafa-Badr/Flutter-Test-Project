import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/scheduler.dart';

class SplashScreen extends StatefulWidget {
  final String svgAssetPath;
  final Duration duration;

  const SplashScreen({
    super.key,
    required this.svgAssetPath,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: widget.duration);

    _scaleAnim = Tween<double>(
      begin: 0.30,
      end: 1.70,
    ).chain(CurveTween(curve: Curves.easeOutCubic)).animate(_controller);

    SchedulerBinding.instance.addPostFrameCallback((_) {
      _controller.forward();

      Future.delayed(widget.duration + const Duration(milliseconds: 300), () {
        _goNext();
      });
    });
  }

  Future<void> _goNext() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

      if (!mounted) return;
      if (isLoggedIn) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        Navigator.pushReplacementNamed(context, '/signUp');
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/signUp');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ScaleTransition(
            scale: _scaleAnim,
            child: SvgPicture.asset(
              widget.svgAssetPath,

              width: MediaQuery.of(context).size.width * 0.5,
              semanticsLabel: 'App Logo',
            ),
          ),
        ),
      ),
    );
  }
}
