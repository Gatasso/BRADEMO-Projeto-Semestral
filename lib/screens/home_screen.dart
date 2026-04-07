import 'package:flutter/material.dart';
import '../widgets/equipment_card.dart';

/// Tela inicial: cadastro de equipamentos defeituosos nas salas do IF.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const Color _ifGreen = Color(0xFF1B5E20);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bem-vindo!',
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _ifGreen,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Cadastre aqui os equipamentos com defeitos',
                      style: textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Projetor Quebrado - Card grande
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Projetor Quebrado',
                      style: textTheme.labelMedium?.copyWith(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    EquipmentCard(
                      imageUrl:
                          'https://images.pexels.com/photos/31261076/pexels-photo-31261076.jpeg',
                      title: 'Projetor\nQuebrado',
                      height: 220,
                      fontSize: 18,
                      textPadding: const EdgeInsets.only(bottom: 16, left: 16),
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Dois cards lado a lado
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Outros Equipamentos',
                      style: textTheme.labelMedium?.copyWith(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: EquipmentCard(
                            imageUrl:
                                'https://images.pexels.com/photos/3747481/pexels-photo-3747482.jpeg',
                            title: 'Computador\ncom Problema',
                            onTap: () {},
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: EquipmentCard(
                            imageUrl:
                                'https://images.pexels.com/photos/42220/air-blade-blowing-chrome-42220.jpeg',
                            title: 'Ventilador\nQuebrado',
                            onTap: () {},
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Botão Cadastrar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: _ifGreen,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {},
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Cadastrar Equipamento'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
