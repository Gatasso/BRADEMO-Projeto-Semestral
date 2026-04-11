import 'package:flutter/material.dart';

class LoginForm extends StatelessWidget {
  final TextEditingController prontuarioController;
  final TextEditingController senhaController;
  final Future<void> Function() onLoginPressed;

  const LoginForm({
    super.key,
    required this.prontuarioController,
    required this.senhaController,
    required this.onLoginPressed,
  });

  static const Color _ifGreen = Color(0xFF1B5E20);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24),
      margin: EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Image.asset('assets/images/IFSP-BRA.png', height: 60),

          SizedBox(height: 20),

          Text(
            "Bem-vindo de volta!",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: _ifGreen,
            ),
          ),

          SizedBox(height: 20),

          // Prontuário
          TextField(
            controller: prontuarioController,
            decoration: InputDecoration(
              hintText: "Prontuário",
              hintStyle: TextStyle(color: _ifGreen),
              prefixIcon: Icon(Icons.email, color: _ifGreen),
              filled: true,
              fillColor: Color(0xFFF1F3F6),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          SizedBox(height: 16),

          // Senha
          TextField(
            controller: senhaController,
            obscureText: true,
            decoration: InputDecoration(
              hintText: "Senha",
              hintStyle: TextStyle(color: _ifGreen),
              prefixIcon: Icon(Icons.lock, color: _ifGreen),
              filled: true,
              fillColor: Color(0xFFF1F3F6),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          SizedBox(height: 20),

          // BOTÃO ENTRAR
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: onLoginPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: _ifGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text("Entrar", style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
