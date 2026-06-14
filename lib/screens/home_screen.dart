import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/equipment.dart';
import '../widgets/equipment_card.dart';
import '../services/database_service.dart';
import 'details_screen.dart';

/// Tela inicial: cadastro de equipamentos defeituosos nas salas do IF.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 2; // Home é o índice padrão

  List<Equipment> _equipments = [];

  @override
  void initState() {
    super.initState();
    _loadEquipments();
  }

  Future<void> _loadEquipments() async {
    final equipments = await DatabaseService.loadEquipments();
    setState(() {
      _equipments = equipments;
    });
  }

  Future<void> _navigateToDetails(Equipment equipment) async {
    final index = _equipments.indexOf(equipment);
    if (index == -1) return;

    final updated = await Navigator.push<Equipment>(
      context,
      MaterialPageRoute(
        builder: (context) => ItemDetailScreen(
          equipment: equipment,
          index: index,
        ),
      ),
    );
    if (updated != null && mounted) {
      _loadEquipments();
    }
  }

  void _showCreateSolicitacaoSheet(BuildContext context) async {
    final sessionBox = await Hive.openBox('session');
    final userId = sessionBox.get('user_id') as String?;

    if (userId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro: Usuário não identificado. Faça login novamente.')),
      );
      return;
    }

    if (_equipments.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhum equipamento carregado para reportar defeito.')),
      );
      return;
    }

    Equipment? selectedEquipment = _equipments.first;
    int selectedDefeitoId = 1;
    final TextEditingController descricaoController = TextEditingController();
    bool isSubmitting = false;

    final defectMap = {
      1: "Não Liga",
      2: "Sem Sinal de Vídeo",
      3: "Ar Condicionado não Gela",
      4: "Mesa Quebrada/Solta",
    };

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final theme = Theme.of(context);
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                top: 24,
                left: 24,
                right: 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 50,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Reportar Novo Defeito',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Informe qual equipamento está com problema.',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 20),

                    // Dropdown Equipamentos
                    DropdownButtonFormField<Equipment>(
                      value: selectedEquipment,
                      decoration: const InputDecoration(
                        labelText: 'Selecione o Equipamento',
                        prefixIcon: Icon(Icons.build),
                      ),
                      items: _equipments.map((eq) {
                        return DropdownMenuItem<Equipment>(
                          value: eq,
                          child: Text(
                            '${eq.codPatrimonio ?? "Sem Pat."} - ${eq.name}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setModalState(() {
                          selectedEquipment = val;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Dropdown Defeitos
                    DropdownButtonFormField<int>(
                      value: selectedDefeitoId,
                      decoration: const InputDecoration(
                        labelText: 'Tipo de Defeito',
                        prefixIcon: Icon(Icons.warning_amber),
                      ),
                      items: defectMap.entries.map((entry) {
                        return DropdownMenuItem<int>(
                          value: entry.key,
                          child: Text(entry.value),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() {
                            selectedDefeitoId = val;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Descrição detalhada
                    TextFormField(
                      controller: descricaoController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Descrição do Defeito (Opcional)',
                        hintText: 'Descreva em detalhes o que está acontecendo...',
                        prefixIcon: Icon(Icons.description),
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Botão Confirmar
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                if (selectedEquipment == null ||
                                    selectedEquipment!.codPatrimonio == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Equipamento inválido.'),
                                    ),
                                  );
                                  return;
                                }

                                setModalState(() {
                                  isSubmitting = true;
                                });

                                final success = await DatabaseService.createSolicitacao(
                                  usuarioId: userId,
                                  codSala: selectedEquipment!.room,
                                  idDefeito: selectedDefeitoId,
                                  codPatrimonio: selectedEquipment!.codPatrimonio!,
                                  descricaoDefeito: descricaoController.text,
                                );

                                if (success) {
                                  if (context.mounted) Navigator.pop(context);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Chamado aberto com sucesso!'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                } else {
                                  setModalState(() {
                                    isSubmitting = false;
                                  });
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Erro ao enviar chamado para a API.'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              },
                        child: isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                'Reportar Defeito',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    if (_equipments.isEmpty) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final featuredEquipment = _equipments[0];
    final otherEquipments = _equipments.sublist(1);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: null,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.search, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth > 900 ? 40.0 : 20.0;
            final featuredHeight = constraints.maxWidth > 900 ? 280.0 : 220.0;
            final otherHeight = constraints.maxWidth > 900 ? 220.0 : 160.0;
            final cardSpacing = constraints.maxWidth > 900 ? 16.0 : 12.0;

            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bem-vindo!',
                            style: textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
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
                      padding: EdgeInsets.zero,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            featuredEquipment.name,
                            style: textTheme.labelMedium?.copyWith(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          EquipmentCard(
                            imageUrl: featuredEquipment.imageUrl,
                            title: featuredEquipment.name,
                            height: featuredHeight,
                            fontSize: 18,
                            textPadding: EdgeInsets.only(bottom: 16, left: 16),
                            onTap: () => _navigateToDetails(featuredEquipment),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Dois cards lado a lado ou empilhados
                    Padding(
                      padding: EdgeInsets.zero,
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: EquipmentCard(
                                  imageUrl: otherEquipments[0].imageUrl,
                                  title: otherEquipments[0].name,
                                  height: otherHeight,
                                  onTap: () => _navigateToDetails(otherEquipments[0]),
                                ),
                              ),
                              SizedBox(width: cardSpacing),
                              Expanded(
                                child: EquipmentCard(
                                  imageUrl: otherEquipments[1].imageUrl,
                                  title: otherEquipments[1].name,
                                  height: otherHeight,
                                  onTap: () => _navigateToDetails(otherEquipments[1]),
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
            );
          },
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
        backgroundColor: theme.colorScheme.primary,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateSolicitacaoSheet(context),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
