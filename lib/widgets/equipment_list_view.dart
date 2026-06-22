import 'package:flutter/material.dart';
import '../models/equipment.dart';
import '../models/solicitacao_model.dart';
import '../screens/details_screen.dart';
import 'equipment_image.dart';

class EquipmentListView extends StatelessWidget {
  final List<Equipment> equipments;

  const EquipmentListView({super.key, required this.equipments});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: equipments.length,
      itemBuilder: (context, index) {
        final equipment = equipments[index];
        return ListTile(
          leading: buildEquipmentImage(
            equipment.imageUrl,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
          ),
          title: Text(equipment.name),
          subtitle: Text('${equipment.location} - ${equipment.priority}'),
          trailing: Text('${equipment.reports} reports'),
          onTap: () {
            final solicitacao = Solicitacao(
              id: equipment.codPatrimonio ?? '',
              codSala: equipment.room,
              material: equipment.name,
              idDefeito: 1,
              defeitoTitulo: equipment.details,
              status: equipment.priority,
              criadoEm: equipment.reportDate,
              imageUrl: equipment.imageUrl,
            );
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ItemDetailScreen(solicitacao: solicitacao),
              ),
            );
          },
        );
      },
    );
  }
}
