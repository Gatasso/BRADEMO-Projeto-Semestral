import 'package:flutter/material.dart';

class LoginForm extends StatelessWidget {
  final TextEditingController prontuarioController;
  final TextEditingController senhaController;
  final Future<void> Function() onLoginPressed;
  final VoidCallback onForgotPasswordPressed;

  const LoginForm({
    super.key,
    required this.prontuarioController,
    required this.senhaController,
    required this.onLoginPressed,
    required this.onForgotPasswordPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Image.asset('assets/images/IFSP-BRA.png', height: 60),

          const SizedBox(height: 20),

          Text(
            'Bem-vindo de volta!',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontSize: 22,
              color: primaryColor,
            ),
          ),

          const SizedBox(height: 20),

          // Prontuário
          TextField(
            controller: prontuarioController,
            decoration: InputDecoration(
              hintText: 'Prontuário',
              prefixIcon: Icon(Icons.email, color: primaryColor),
            ),
          ),

          const SizedBox(height: 16),

          // Senha
          TextField(
            controller: senhaController,
            obscureText: true,
            decoration: InputDecoration(
              hintText: 'Senha',
              prefixIcon: Icon(Icons.lock, color: primaryColor),
            ),
          ),
          const SizedBox(height: 10),
          // BOTÃO ESQUECI MINHA SENHA
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: onForgotPasswordPressed,
              style: TextButton.styleFrom(
                padding: EdgeInsets
                    .zero, // Remove o padding padrão do botão para colar no canto
                minimumSize: const Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Esqueceu sua senha?',
                style: TextStyle(
                  color: Colors.blue, // Ou a cor secundária do seu tema
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // BOTÃO ENTRAR
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: onLoginPressed,
              child: const Text('Entrar'),
            ),
          ),
        ],
      ),
    );
  }
}
