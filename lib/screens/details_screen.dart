import 'package:flutter/material.dart';
import '../models/equipment.dart';

class ItemDetailScreen extends StatefulWidget {
  final Equipment equipment;

  const ItemDetailScreen({super.key, required this.equipment});

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  bool isUrgent = false;
  int _activeTabIndex =
      0; // 0: Aba Detalhes, 1: Aba Localização, 2: Aba Histórico

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        height: 350,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(45),
                            bottomRight: Radius.circular(45),
                          ),
                          image: DecorationImage(
                            image: NetworkImage(widget.equipment.imageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 30,
                        right: 20,
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          child: IconButton(
                            icon: Icon(
                              isUrgent
                                  ? Icons.warning
                                  : Icons.warning_amber_rounded,
                              color: isUrgent ? Colors.red : Colors.grey,
                            ),
                            onPressed: () =>
                                setState(() => isUrgent = !isUrgent),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 30,
                        left: 20,
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.black,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -70,
                        left: 20,
                        right: 20,
                        child: _buildInfoCard(),
                      ),
                    ],
                  ),

                  SizedBox(height: 90),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildTabItem("Detalhes", 0),
                        _buildTabItem("Localização", 1),
                        _buildTabItem("Histórico", 2),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(25.0),
                    child: _buildActiveTabContent(),
                  ),
                ],
              ),
            ),
          ),

          _buildActionButton(context),
        ],
      ),
    );
  }

  Widget _buildActiveTabContent() {
    switch (_activeTabIndex) {
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Localização',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.red),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.equipment.location,
                    style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Reportado em ${widget.equipment.formattedReportDate}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A3D9B),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Prioridade ${widget.equipment.priority}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: widget.equipment.priority.toLowerCase() == 'alta'
                    ? Colors.red
                    : widget.equipment.priority.toLowerCase() == 'média'
                    ? Colors.orange
                    : Colors.green,
              ),
            ),
          ],
        );
      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Histórico',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            _buildHistoryItem(
              '${widget.equipment.formattedReportDate} - Reporte criado.',
              true,
            ),
            _buildHistoryItem(
              '${widget.equipment.reports} reportes registrados.',
              false,
            ),
            _buildHistoryItem('Aguardando análise da equipe de TI.', false),
          ],
        );
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                style: TextStyle(
                  color: Colors.grey[800],
                  fontSize: 16,
                  height: 1.6,
                ),
                children: [TextSpan(text: widget.equipment.details)],
              ),
            ),
            const SizedBox(height: 20),
            _buildStatusInfoBox(),
          ],
        );
    }
  }

  Widget _buildHistoryItem(String text, bool isFirst) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: isFirst ? Color(0xFF1A3D9B) : Colors.grey,
            size: 20,
          ),
          SizedBox(width: 10),
          Text(text, style: TextStyle(color: Colors.grey[700])),
        ],
      ),
    );
  }

  Widget _buildStatusInfoBox() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(33, 150, 243, 0.05),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Color(0xFF1A3D9B)),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'O reparo já está agendado pela equipe de TI.',
              style: TextStyle(color: Color(0xFF1A3D9B), fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 8,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.equipment.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.equipment.location,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            Text(
              'Reportado em ${widget.equipment.formattedReportDate}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A3D9B),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.report_problem,
                  color: widget.equipment.priority.toLowerCase() == 'alta'
                      ? Colors.red
                      : widget.equipment.priority.toLowerCase() == 'média'
                      ? Colors.orange
                      : Colors.green,
                  size: 20,
                ),
                const SizedBox(width: 6),
                Text(
                  'Prioridade ${widget.equipment.priority.toLowerCase()}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: widget.equipment.priority.toLowerCase() == 'alta'
                        ? Colors.red
                        : widget.equipment.priority.toLowerCase() == 'média'
                        ? Colors.orange
                        : Colors.green,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.people_alt_outlined,
                  color: Colors.grey,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  '${widget.equipment.reports} reportes',
                  style: TextStyle(color: Colors.grey[700], fontSize: 13),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(String title, int index) {
    bool active = _activeTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _activeTabIndex = index),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: active ? FontWeight.bold : FontWeight.w500,
              color: active ? Color(0xFF1A3D9B) : Colors.grey[400],
            ),
          ),
          if (active)
            Container(
              margin: EdgeInsets.only(top: 8),
              height: 3,
              width: 30,
              decoration: BoxDecoration(
                color: Color(0xFF1A3D9B),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(25, 0, 25, 30),
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF1A3D9B),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          onPressed: () => _showSoonDialog(context),
          child: Text(
            "Acompanhar Chamado",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  void _showSoonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Notificação"),
        content: Text("Você receberá atualizações sobre este chamado."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Entendido"),
          ),
        ],
      ),
    );
  }
}
