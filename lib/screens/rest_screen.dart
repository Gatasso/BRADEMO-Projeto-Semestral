import 'package:flutter/material.dart';

class RestScreen extends StatelessWidget {
  const RestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🔥 IMAGEM DE FUNDO
          SizedBox.expand(
            child: Image.network(
              'https://images.unsplash.com/photo-1501785888041-af3ef285b470',
              fit: BoxFit.cover,
            ),
          ),

          // 🔥 OVERLAY ESCURO (pra dar contraste)
          Container(
            color: Colors.black.withOpacity(0.3),
          ),

          // 🔥 CONTEÚDO
          Column(
            children: [
              const Spacer(),

              // CARD TRANSPARENTE
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Welcome to GlobeGlider',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      'Discover the world’s most beautiful places and start your unforgettable journey.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 🔵 BOTÃO REDONDO
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue,
                      ),
                      child: IconButton(
                        onPressed: () {
                          // depois você pode ir pra próxima tela
                        },
                        icon: const Icon(Icons.arrow_forward),
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ],
      ),
    );
  }
}