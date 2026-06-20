import 'package:flutter/material.dart';

class RecuperarSenhaScreen extends StatefulWidget {
  const RecuperarSenhaScreen({super.key});

  @override
  State<RecuperarSenhaScreen> createState() =>
      _RecuperarSenhaScreenState();
}

class _RecuperarSenhaScreenState
    extends State<RecuperarSenhaScreen> {
  final TextEditingController _emailController =
      TextEditingController();

  void _enviarRecuperacao() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Uma nova senha seria enviada para este e-mail.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        title: const Text('Recuperar Senha'),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Recuperação de Senha',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: primaryColor,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Informe seu e-mail para receber uma nova senha.',
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  hintText: 'E-mail',
                  prefixIcon: Icon(Icons.email),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _enviarRecuperacao,
                  child: const Text('Enviar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}