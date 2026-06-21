import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';
import 'login_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();
    _checkSessionAndNavigate();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkSessionAndNavigate() async {
    // Aguarda o tempo do splash screen (2.5 segundos)
    await Future.delayed(const Duration(milliseconds: 2500));

    // Abre a box de sessão e verifica se existe um usuário logado
    final sessionBox = await Hive.openBox('session');
    final String? userId = sessionBox.get('user_id');

    if (!mounted) return;

    if (userId != null) {
      // Usuário logado: vai direto para a tela principal (HomeScreen) sem exibir a RestScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      // Usuário deslogado: vai para a tela de Login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _animation,
          child: Hero(
            tag: 'logo',
            child: SvgPicture.asset(
              'assets/images/logo.svg',
              width: 180,
              height: 180,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
