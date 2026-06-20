import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/equipment.dart';
import '../widgets/equipment_card.dart';
import '../services/solicitacao_service.dart';
import 'details_screen.dart';
import '../models/solicitacao_model.dart';
import 'profile_screen.dart';

/// Tela inicial: cadastro de equipamentos defeituosos nas salas do IF.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 2; // Home é o índice padrão
  List<Solicitacao> _solicitacoes = [];
  bool _isLoading = true;
  String _userType = 'Aluno';

  @override
  void initState() {
    super.initState();
    _recuperarDadosUsuario();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    setState(() {
      _isLoading = true;
    });

    final dados = await buscarSolicitacoesUsuario();
    setState(() {
      _solicitacoes = dados;
      _isLoading = false;
    });
  }

  void _recuperarDadosUsuario() {
    try {
      final userBox = Hive.box('authBox');

      final userData = userBox.get('currentUser');
      if (userData != null) {
        setState(() {
          _userType = userData['tipo'] ?? 'Aluno';

          _selectedIndex = (_userType == 'Admin' || _userType == 'TI') ? 2 : 2;
        });
      }
    } catch (e) {
      debugPrint('Erro ao ler usuário do Hive: $e');
    }
  }

  List<BottomNavigationBarItem> _getNavbarItems() {
    if (_userType == 'Admin' || _userType == 'TI') {
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

    // Navbar original completa para usuários normais
    return const [
      BottomNavigationBarItem(
        icon: Icon(Icons.error_outline),
        label: 'Reportar Defeito',
      ),
      BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
    ];
  }

  /// Gerencia a navegação com base nos índices dinâmicos de cada perfil
  void _onNavbarItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    bool isAdminOrTi = (_userType == 'Admin' || _userType == 'TI');

    // Mapeamento das ações baseadas na estrutura de tamanho da lista
    if (isAdminOrTi) {
      switch (index) {
        case 0: // Reportar Defeito
          // Navigator.pushNamed(context, '/reportar');
          break;
        case 1: // Cadastrar
          // Navigator.pushNamed(context, '/cadastrar');
          break;
        case 2: // Home (Mantém na tela atual)
          break;
        case 3: // Perfil redireciona para a ProfileScreen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProfileScreen()),
          );
          break;
      }
    } else {
      switch (index) {
        case 0:
          // Ações comuns...
          break;
        case 1:
          break;
        case 2: // Home
          break;
        case 3: // Configurações
          break;
        case 4: // Perfil do usuário comum
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProfileScreen()),
          );
          break;
      }
    }
  }

  void _showCreateSolicitacaoSheet(BuildContext context) async {
    final sessionBox = await Hive.openBox('session');
    final userId = sessionBox.get('user_id') as String?;

    if (userId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Erro: Usuário não identificado. Faça login novamente.',
          ),
        ),
      );
      return;
    }

    if (_equipments.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nenhum equipamento carregado para reportar defeito.'),
        ),
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
                        hintText:
                            'Descreva em detalhes o que está acontecendo...',
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

                                final success =
                                    await DatabaseService.createSolicitacao(
                                      usuarioId: userId,
                                      codSala: selectedEquipment!.room,
                                      idDefeito: selectedDefeitoId,
                                      codPatrimonio:
                                          selectedEquipment!.codPatrimonio!,
                                      descricaoDefeito:
                                          descricaoController.text,
                                    );

                                if (success) {
                                  if (context.mounted) Navigator.pop(context);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Chamado aberto com sucesso!',
                                        ),
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
                                        content: Text(
                                          'Erro ao enviar chamado para a API.',
                                        ),
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
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
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
                onPressed: () {
                  // Ação para abrir a busca no futuro
                },
                icon: const Icon(Icons.search, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _solicitacoes.isEmpty
            ? _buildEmptyState(textTheme, theme)
            : LayoutBuilder(
                builder: (context, constraints) {
                  final horizontalPadding = constraints.maxWidth > 900
                      ? 40.0
                      : 20.0;

                  return SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Minhas Solicitações',
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Acompanhe os reparos solicitados por você',
                          style: textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Lista vertical de cards dinâmicos resolvendo o problema de index quebrado
                        ListView.builder(
                          shrinkWrap: true,
                          physics:
                              const NeverScrollableScrollPhysics(), // Deixa o scroll pro SingleChildScrollView pai
                          itemCount: _solicitacoes.length,
                          itemBuilder: (context, index) {
                            final item = _solicitacoes[index];

                            // CONCATENAÇÃO DO NOME DO EQUIPAMENTO/MOBÍLIA COM O TÍTULO DO DEFEITO
                            final String tituloConcatenado =
                                "${item.material} - ${item.defeitoTitulo}";

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Status: ${item.status}",
                                    style: textTheme.labelSmall?.copyWith(
                                      color: item.status == 'Concluída'
                                          ? Colors.green
                                          : Colors.orange,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  EquipmentCard(
                                    imageUrl: item.imageUrl.startsWith('http')
                                        ? item.imageUrl
                                        : 'assets/images/computador.png',
                                    title:
                                        tituloConcatenado, // Título concatenado aplicado aqui!
                                    height: 180,
                                    fontSize: 16,
                                    onTap: () {
                                      // Envia o objeto dinâmico completo para a tela de detalhes
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ItemDetailScreen(
                                                solicitacao: item,
                                              ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: theme.colorScheme.primary,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        items: _getNavbarItems(), // Carrega os botões dinamicamente filtrados
        onTap: _onNavbarItemTapped,
      ),
    );
  }

  Widget _buildEmptyState(TextTheme textTheme, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.build_circle_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Nenhum chamado encontrado',
            style: textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
