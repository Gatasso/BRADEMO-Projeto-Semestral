import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../widgets/solicitacao_card.dart';
import '../services/solicitacao_service.dart';
import 'details_screen.dart';
import '../models/solicitacao_model.dart';
import 'profile_screen.dart';
import 'cadastro_screen.dart';
import '../widgets/custom_bottom_navigation.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 1;
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
    try {
      final dados = await buscarSolicitacoesUsuario();
      setState(() {
        _solicitacoes = dados;
        _isLoading = false;
      });
    } catch (e, stacktrace) {
      debugPrint('Erro ao carregar dados da API: $e');
      print(stacktrace);
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _recuperarDadosUsuario() {
    try {
      final userBox = Hive.box('authBox');
      final String? tipoUsuario = userBox.get('usuario_tipo')?.toString();

      if (tipoUsuario != null) {
        setState(() {
          _userType = tipoUsuario;
          _selectedIndex = (_userType == 'Admin' || _userType == 'TI') ? 2 : 1;
        });
      }
    } catch (e) {
      debugPrint('Erro ao ler usuário do Hive: $e');
    }
  }

  Widget _buildBody() {
    bool isAdminOrTi = (_userType == 'Admin' || _userType == 'TI');

    if (isAdminOrTi) {
      switch (_selectedIndex) {
        case 0:
          return const Center(child: Text('Tela Reportar Defeito'));
        case 1:
          return const CadastroScreen();
        case 2:
          return _buildHomeContent();
        case 3:
          return const ProfileScreen();
        default:
          return _buildHomeContent();
      }
    } else {
      switch (_selectedIndex) {
        case 0:
          return const Center(child: Text('Tela Reportar Defeito'));
        case 1:
          return _buildHomeContent();
        case 2:
          return const ProfileScreen();
        default:
          return _buildHomeContent();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    bool isAdminOrTi = (_userType == 'Admin' || _userType == 'TI');
    bool hideAppBar = false;

    if (isAdminOrTi) {
      if (_selectedIndex == 1 || _selectedIndex == 3) {
        hideAppBar = true;
      }
    } else {
      if (_selectedIndex == 2) {
        hideAppBar = true;
      }
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: hideAppBar
          ? null
          : AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              title: const Text("arrumaÍF"),
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
      body: SafeArea(child: _buildBody()),
      bottomNavigationBar: CustomBottomNavigation(
        currentIndex: _selectedIndex,
        userType: _userType,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildHomeContent() {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_solicitacoes.isEmpty) {
      return _buildEmptyState(textTheme, theme);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = constraints.maxWidth > 900 ? 40.0 : 20.0;
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
                style: textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _solicitacoes.length,
                itemBuilder: (context, index) {
                  final item = _solicitacoes[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: SolicitacaoCard(
                      solicitacao: item,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ItemDetailScreen(solicitacao: item),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
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
