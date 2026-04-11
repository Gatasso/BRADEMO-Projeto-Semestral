import 'package:flutter/material.dart';
import '../widgets/login_form.dart';
import '../services/database_service.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _prontuarioController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();

  static const Color _ifGreen = Color(0xFF1B5E20);

  Future<void> _login() async {
    final prontuario = _prontuarioController.text;
    final senha = _senhaController.text;

    final isValid = await DatabaseService.validateLogin(prontuario, senha);
    if (isValid) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Prontuário ou senha inválidos')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _ifGreen,
      body: Center(
        child: SingleChildScrollView(
          child: LoginForm(
            prontuarioController: _prontuarioController,
            senhaController: _senhaController,
            onLoginPressed: _login,
          ),
        ),
      ),
    );
  }
}
