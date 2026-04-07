import 'package:flutter/material.dart';
import '../models/equipment.dart';
import '../widgets/equipment_card.dart';
import 'details_screen.dart';

/// Tela inicial: cadastro de equipamentos defeituosos nas salas do IF.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 2; // Home é o índice padrão

  static const Color _ifGreen = Color(0xFF1B5E20);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final featuredEquipment = Equipment(
      name: 'Projetor Quebrado',
      room: 'Sala B101',
      campus: 'IFSP Bragança Paulista',
      reportDate: DateTime(2026, 4, 6),
      priority: 'Alta',
      reports: 5,
      details:
          'O projetor não liga de forma consistente e a imagem fica com falhas, impactando as aulas de apresentação.',
      imageUrl:
          'https://images.pexels.com/photos/31261076/pexels-photo-31261076.jpeg',
    );

    final otherEquipments = [
      Equipment(
        name: 'Computador com Problema',
        room: 'Sala A402',
        campus: 'IFSP Bragança Paulista',
        reportDate: DateTime(2026, 4, 4),
        priority: 'Média',
        reports: 3,
        details:
            'O computador trava frequentemente e apresenta lentidão no carregamento de programas.',
        imageUrl:
            'https://images.pexels.com/photos/3747481/pexels-photo-3747482.jpeg',
      ),
      Equipment(
        name: 'Ventilador Quebrado',
        room: 'Sala C203',
        campus: 'IFSP Bragança Paulista',
        reportDate: DateTime(2026, 4, 5),
        priority: 'Baixa',
        reports: 1,
        details:
            'O ventilador não gira corretamente e faz barulho alto ao ser ligado.',
        imageUrl:
            'https://images.pexels.com/photos/42220/air-blade-blowing-chrome-42220.jpeg',
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: null,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.search, color: _ifGreen),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
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
                      imageUrl: featuredEquipment.imageUrl,
                      title: featuredEquipment.name,
                      height: 220,
                      fontSize: 18,
                      textPadding: const EdgeInsets.only(bottom: 16, left: 16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ItemDetailScreen(equipment: featuredEquipment),
                          ),
                        );
                      },
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
                            imageUrl: otherEquipments[0].imageUrl,
                            title: otherEquipments[0].name,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ItemDetailScreen(
                                    equipment: otherEquipments[0],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: EquipmentCard(
                            imageUrl: otherEquipments[1].imageUrl,
                            title: otherEquipments[1].name,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ItemDetailScreen(
                                    equipment: otherEquipments[1],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: _ifGreen,
        unselectedItemColor: Colors.grey[400],
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.error_outline),
            label: 'Reportar Defeito',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Cadastrar',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Configuração',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }

  Widget _buildLargeCard(
    String imageUrl,
    String title, {
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Image.network(
              imageUrl,
              width: double.infinity,
              height: 220,
              fit: BoxFit.cover,
            ),
            Container(
              width: double.infinity,
              height: 220,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediumCard(
    String imageUrl,
    String title, {
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Image.network(
              imageUrl,
              width: double.infinity,
              height: 160,
              fit: BoxFit.cover,
            ),
            Container(
              width: double.infinity,
              height: 160,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                ),
              ),
            ),
            Positioned(
              bottom: 12,
              left: 12,
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
