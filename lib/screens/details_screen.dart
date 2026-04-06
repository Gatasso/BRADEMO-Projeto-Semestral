import 'package:flutter/material.dart';

class ItemDetailScreen extends StatefulWidget {
  @override
  _ItemDetailScreenState createState() => _ItemDetailScreenState();
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
                            image: AssetImage('assets/images/broken.jpg'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 50,
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
      case 1: // ABA LOCALIZAÇÃO
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Endereço do Item",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.red),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Prédio IFSP Bragança Paulista. Bloco A, sala A402.",
                    style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                  ),
                ),
              ],
            ),
          ],
        );
      case 2: // ABA HISTÓRICO
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Linha do Tempo",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 15),
            _buildHistoryItem("02/04 - Reporte criado pelo aluno.", true),
            _buildHistoryItem("03/04 - TI validou o problema.", false),
            _buildHistoryItem("05/04 - Peça de reposição solicitada.", false),
          ],
        );
      default: // ABA DETALHES (Default)
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
                children: [
                  TextSpan(
                    text:
                        "O dispositivo apresenta falhas nas teclas 'Enter' e 'Espaço', impossibilitando o uso para as aulas de programação.",
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
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
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Color(0xFF1A3D9B)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "O reparo já está agendado pela equipe de TI.",
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
              "Teclado Quebrado",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              "Sala A402 - IFSP Bragança Paulista",
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 12),
            Text(
              "Reportado em 02/04/2026",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A3D9B),
              ),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.report_problem, color: Colors.orange, size: 20),
                SizedBox(width: 6),
                Text(
                  "Prioridade alta",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                Spacer(),
                Icon(Icons.people_alt_outlined, color: Colors.grey, size: 18),
                SizedBox(width: 4),
                Text(
                  "5 pessoas",
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
