import 'package:flutter/material.dart';

/// Widget reutilizável para cards de equipamentos.
class EquipmentCard extends StatelessWidget {
  const EquipmentCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.onTap,
    this.height = 160.0,
    this.fontSize = 14.0,
    this.textPadding = const EdgeInsets.only(bottom: 12, left: 12),
  });

  final String imageUrl;
  final String title;
  final VoidCallback onTap;
  final double height;
  final double fontSize;
  final EdgeInsets textPadding;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Image.network(
              imageUrl,
              width: double.infinity,
              height: height,
              fit: BoxFit.cover,
            ),
            Container(
              width: double.infinity,
              height: height,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                ),
              ),
            ),
            Positioned(
              bottom: textPadding.bottom,
              left: textPadding.left,
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: fontSize,
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
