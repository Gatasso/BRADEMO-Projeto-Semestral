import 'package:flutter/material.dart';

class RestScreen extends StatelessWidget {
  const RestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 700;
          final cardPadding = isWide ? 30.0 : 20.0;
          final cardMargin = isWide ? 30.0 : 20.0;
          final titleSize = isWide ? 28.0 : 22.0;
          final bodySize = isWide ? 18.0 : 16.0;
          return Stack(
            children: [
              Container(
                color: theme.colorScheme.primary,
                child: Center(
                  child: Image.asset(
                    'assets/images/IFSP-BRA.png',
                    width: isWide ? 260 : 200,
                    height: isWide ? 260 : 200,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Container(color: Colors.black.withValues(alpha: 0.3)),

              Column(
                children: [
                  const Spacer(),
                  Container(
                    margin: EdgeInsets.all(cardMargin),
                    padding: EdgeInsets.all(cardPadding),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Sistema de Gestão de Equipamentos',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: titleSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),

                        SizedBox(height: isWide ? 16 : 10),

                        Text(
                          'Instituto Federal de Educação, Ciência e Tecnologia de São Paulo\n\nGerencie e monitore os equipamentos das salas do IFSP Bragança Paulista.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: bodySize,
                          ),
                        ),

                        SizedBox(height: isWide ? 24 : 20),
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: theme.colorScheme.primary,
                          ),
                          child: IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.arrow_back),
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: isWide ? 40 : 30),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
