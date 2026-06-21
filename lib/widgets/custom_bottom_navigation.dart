import 'package:flutter/material.dart';

class CustomBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final String userType;
  final ValueChanged<int> onTap;

  const CustomBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.userType,
    required this.onTap,
  });

  List<BottomNavigationBarItem> _getNavbarItems() {
    if (userType == 'Admin' || userType == 'TI') {
      return const [
        BottomNavigationBarItem(
          icon: Icon(Icons.error_outline),
          label: 'Reportar Defeito',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_circle_outline),
          label: 'Cadastrar',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
      ];
    }

    return const [
      BottomNavigationBarItem(
        icon: Icon(Icons.error_outline),
        label: 'Reportar Defeito',
      ),
      BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      backgroundColor: theme.colorScheme.primary,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white70,
      items: _getNavbarItems(),
      onTap: onTap,
    );
  }
}
