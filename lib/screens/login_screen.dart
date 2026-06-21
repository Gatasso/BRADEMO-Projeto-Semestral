import 'package:brademo_projeto_final/screens/rest_screen.dart';
import 'package:brademo_projeto_final/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:brademo_projeto_final/screens/recuperar_senha_screen.dart';
import '../widgets/login_form.dart';
import '../services/database_service.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _prontuarioController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    final prontuario = _prontuarioController.text.trim();
    final senha = _senhaController.text.trim();

    if (prontuario.isEmpty || senha.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, preencha todos os campos.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final isSucess = await AuthService.login(prontuario, senha);

    if (!mounted) return;

    context.read<UserProvider>().atualizarEstadoAposLogin();

    setState(() => _isLoading = false);

    if (isSucess) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const RestScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Prontuário ou senha inválidos ou erro de conexão'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding = constraints.maxWidth > 700 ? 40.0 : 24.0;
          final maxFormWidth = constraints.maxWidth > 600
              ? 520.0
              : constraints.maxWidth - horizontalPadding * 2;
          return Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 24,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxFormWidth),
                child: LoginForm(
                  prontuarioController: _prontuarioController,
                  senhaController: _senhaController,
                  onLoginPressed: _login,
                  onForgotPasswordPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RecuperarSenhaScreen(),
                      ), // Substitua pelo nome correto da sua classe
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
