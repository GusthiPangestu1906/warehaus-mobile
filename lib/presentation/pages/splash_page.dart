import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/presentation/pages/main_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  static const _versionLabel = 'Version 1.0.0+4';

  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _isVisible = true);
    });
    _openMainPage();
  }

  Future<void> _openMainPage() async {
    await Future<void>.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        pageBuilder: (_, __, ___) => const MainPage(),
        transitionDuration: const Duration(milliseconds: 260),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: WHColors.surface,
        systemNavigationBarColor: WHColors.surface,
      ),
      child: Scaffold(
        backgroundColor: WHColors.surface,
        body: SafeArea(
          child: Stack(
            fit: StackFit.expand,
            children: [
              Center(
                child: AnimatedOpacity(
                  opacity: _isVisible ? 1 : 0,
                  duration: const Duration(milliseconds: 420),
                  curve: Curves.easeOutCubic,
                  child: Image.asset(
                    'assets/icon/app_icon.png',
                    width: 136,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Positioned(
                left: 24,
                right: 24,
                bottom: 28,
                child: AnimatedOpacity(
                  opacity: _isVisible ? 1 : 0,
                  duration: const Duration(milliseconds: 520),
                  curve: Curves.easeOutCubic,
                  child: Text(
                    _versionLabel,
                    textAlign: TextAlign.center,
                    style: WHTypography.caption.copyWith(
                      color: WHColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
