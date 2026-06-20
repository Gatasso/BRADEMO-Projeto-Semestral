import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';

class RecuperarSenhaScreen extends StatefulWidget {
  const RecuperarSenhaScreen({super.key});

  @override
  State<RecuperarSenhaScreen> createState() => _RecuperarSenhaScreenState();
}

class _RecuperarSenhaScreenState extends State<RecuperarSenhaScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  Future<void> _enviarSolicitacaoReset() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, insira seu e-mail.')),
      );
      return;
    }

    // Fecha o teclado virtual assim que o usuário clica em enviar
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    final String mensagemRetorno = await AuthService.resetPassword(email);

    // Dispara a Push Notification Local com o retorno exato do JSON
    await NotificationService.showNotification(
      title: 'Recuperação de Senha',
      body: mensagemRetorno,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    // Feedback visual na tela
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensagemRetorno)));

    // Se a requisição terminou com sucesso, volta para a tela de Login
    Navigator.pop(context);
  }

  @override
  void dispose() {
    // Sempre dê dispose nos seus controllers para evitar vazamento de memória (Memory Leak)
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: primaryColor,
      // Dica: Adicione uma AppBar transparente ou combinando com o fundo se quiser um botão de voltar sutil
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: SingleChildScrollView(
          // Evita erros de overflow caso o teclado suba em telas muito pequenas
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
                    fontWeight: FontWeight.bold,
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
                  keyboardType: TextInputType
                      .emailAddress, // Otimiza o teclado para incluir o caractere '@'
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
                    // Se estiver carregando, passa null para desabilitar o botão completamente
                    onPressed: _isLoading ? null : _enviarSolicitacaoReset,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Enviar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
