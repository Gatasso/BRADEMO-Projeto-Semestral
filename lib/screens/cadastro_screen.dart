import 'package:flutter/material.dart';
import '../services/cadastros_service.dart';

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _patrimonioController = TextEditingController();
  final _tituloController = TextEditingController();

  String _selectedItemType = 'Equipamento';
  String _currentEndpoint = '/api/equipamentos/';

  List<String> _salas = [];
  String? _selectedRoom;
  List<String> _equipamentosPai = [];
  String? _selectedParentEquipment;

  String _tipoLocal = 'Sala';
  String _categoriaDefeitoSolucao = 'Equipamento';

  bool _isLoadingData = true;
  bool _isSubmitting = false;

  final List<Map<String, dynamic>> _menuOptions = [
    {
      'label': 'Equipamento',
      'icon': Icons.devices,
      'endpoint': '/api/equipamentos/',
    },
    {
      'label': 'Componente',
      'icon': Icons.cable,
      'endpoint': '/api/componentes/',
    },
    {
      'label': 'Mobiliário',
      'icon': Icons.chair,
      'endpoint': '/api/mobiliarios/',
    },
    {'label': 'Local', 'icon': Icons.meeting_room, 'endpoint': '/api/locais/'},
    {
      'label': 'Defeito',
      'icon': Icons.report_problem,
      'endpoint': '/api/defeitos/',
    },
    {'label': 'Solução', 'icon': Icons.gavel, 'endpoint': '/api/solucoes/'},
  ];

  @override
  void initState() {
    super.initState();
    _carregarDadosIniciais();
  }

  Future<void> _carregarDadosIniciais() async {
    setState(() => _isLoadingData = true);
    final salasCarregadas = await CadastroService.buscarSalas();
    final equipsCarregados = await CadastroService.buscarEquipamentos();

    setState(() {
      _salas = salasCarregadas;
      if (_salas.isNotEmpty) _selectedRoom = _salas.first;

      _equipamentosPai = equipsCarregados;
      if (_equipamentosPai.isNotEmpty)
        _selectedParentEquipment = _equipamentosPai.first;

      _isLoadingData = false;
    });
  }

  void _onOptionSelected(String label, String endpoint) {
    setState(() {
      _selectedItemType = label;
      _currentEndpoint = endpoint;
      _nomeController.clear();
      _descricaoController.clear();
      _patrimonioController.clear();
      _tituloController.clear();
    });
  }

  Map<String, dynamic> _montarPayload() {
    switch (_selectedItemType) {
      case 'Equipamento':
        return {
          'cod_patrimonio': _patrimonioController.text.trim(),
          'nome': _nomeController.text.trim(),
          'descricao': _descricaoController.text.trim(),
          'cod_sala': _selectedRoom,
        };
      case 'Componente':
        return {
          'cod_patrimonio_equipamento': _selectedParentEquipment,
          'nome': _nomeController.text.trim(),
          'descricao': _descricaoController.text.trim(),
        };
      case 'Mobiliário':
        return {
          'nome': _nomeController.text.trim(),
          'descricao': _descricaoController.text.trim(),
        };
      case 'Local':
        return {
          'cod_sala': _patrimonioController.text.trim(),
          'descricao': _descricaoController.text.trim(),
          'tipo_local': _tipoLocal,
        };
      case 'Defeito':
      case 'Solução':
        return {
          'titulo': _tituloController.text.trim(),
          'descricao': _descricaoController.text.trim(),
          'categoria': _categoriaDefeitoSolucao,
        };
      default:
        return {};
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    final payload = _montarPayload();

    final sucesso = await CadastroService.enviarCadastro(
      _currentEndpoint,
      payload,
    );

    setState(() => _isSubmitting = false);

    if (mounted) {
      if (sucesso) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$_selectedItemType cadastrado com sucesso!')),
        );
        _nomeController.clear();
        _descricaoController.clear();
        _patrimonioController.clear();
        _tituloController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao processar cadastro no servidor.'),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    _patrimonioController.dispose();
    _tituloController.dispose();
    super.dispose();
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
        title: Text(
          'Painel de Controle Administrativo',
          style: TextStyle(
            color: theme.colorScheme.primary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: _isLoadingData
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'O que você deseja cadastrar?',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 1.0,
                            ),
                        itemCount: _menuOptions.length,
                        itemBuilder: (context, index) {
                          final option = _menuOptions[index];
                          final isSelected =
                              _selectedItemType == option['label'];

                          return GestureDetector(
                            onTap: () => _onOptionSelected(
                              option['label'],
                              option['endpoint'],
                            ),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: theme.colorScheme.primary.withOpacity(
                                    0.2,
                                  ),
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    option['icon'],
                                    size: 32,
                                    color: isSelected
                                        ? Colors.white
                                        : theme.colorScheme.primary,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    option['label'],
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Formulário de Cadastro: $_selectedItemType',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildDynamicFields(theme),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isSubmitting
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : Text(
                                  'Salvar $_selectedItemType',
                                  style: const TextStyle(
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
              ),
      ),
    );
  }

  Widget _buildDynamicFields(ThemeData theme) {
    List<Widget> fields = [];

    if (_selectedItemType == 'Equipamento') {
      fields.add(
        _buildDropdownField(
          'Sala / Localização Vincular',
          _selectedRoom,
          _salas,
          (val) {
            setState(() => _selectedRoom = val);
          },
          theme,
        ),
      );
      fields.add(const SizedBox(height: 16));
      fields.add(
        _buildTextField(
          _patrimonioController,
          'Código do Patrimônio',
          Icons.qr_code,
          theme,
        ),
      );
      fields.add(const SizedBox(height: 16));
      fields.add(
        _buildTextField(
          _nomeController,
          'Nome do Equipamento',
          Icons.devices,
          theme,
        ),
      );
    } else if (_selectedItemType == 'Componente') {
      fields.add(
        _buildDropdownField(
          'Equipamento Pai (Patrimônio)',
          _selectedParentEquipment,
          _equipamentosPai,
          (val) {
            setState(() => _selectedParentEquipment = val);
          },
          theme,
        ),
      );
      fields.add(const SizedBox(height: 16));
      fields.add(
        _buildTextField(
          _nomeController,
          'Nome do Componente',
          Icons.cable,
          theme,
        ),
      );
    } else if (_selectedItemType == 'Mobiliário') {
      fields.add(
        _buildTextField(
          _nomeController,
          'Nome do Mobiliário',
          Icons.chair,
          theme,
        ),
      );
    } else if (_selectedItemType == 'Local') {
      fields.add(
        _buildTextField(
          _patrimonioController,
          'Código da Sala (Ex: LAB4)',
          Icons.meeting_room,
          theme,
        ),
      );
      fields.add(const SizedBox(height: 16));
      fields.add(
        DropdownButtonFormField<String>(
          value: _tipoLocal,
          decoration: _getInputDecoration('Tipo de Local', Icons.layers, theme),
          items: const [
            DropdownMenuItem(value: 'Sala', child: Text('Sala')),
            DropdownMenuItem(value: 'Laboratorio', child: Text('Laboratório')),
          ],
          onChanged: (val) {
            if (val != null) setState(() => _tipoLocal = val);
          },
        ),
      );
    } else if (_selectedItemType == 'Defeito' ||
        _selectedItemType == 'Solução') {
      fields.add(
        _buildTextField(
          _tituloController,
          'Título do Registro',
          Icons.title,
          theme,
        ),
      );
      fields.add(const SizedBox(height: 16));
      fields.add(
        DropdownButtonFormField<String>(
          value: _categoriaDefeitoSolucao,
          decoration: _getInputDecoration(
            'Categoria Aplicável',
            Icons.category,
            theme,
          ),
          items: const [
            DropdownMenuItem(value: 'Equipamento', child: Text('Equipamento')),
            DropdownMenuItem(value: 'Mobiliário', child: Text('Mobiliário')),
          ],
          onChanged: (val) {
            if (val != null) setState(() => _categoriaDefeitoSolucao = val);
          },
        ),
      );
    }

    fields.add(const SizedBox(height: 16));
    fields.add(
      TextFormField(
        controller: _descricaoController,
        maxLines: 4,
        decoration: _getInputDecoration(
          'Descrição / Detalhes',
          Icons.description,
          theme,
        ),
        validator: (value) => (value == null || value.isEmpty)
            ? 'Por favor, insira a descrição'
            : null,
      ),
    );

    return Column(children: fields);
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon,
    ThemeData theme,
  ) {
    return TextFormField(
      controller: controller,
      decoration: _getInputDecoration(label, icon, theme),
      validator: (value) =>
          (value == null || value.isEmpty) ? 'Campo obrigatório' : null,
    );
  }

  Widget _buildDropdownField(
    String label,
    String? value,
    List<String> items,
    ValueChanged<String?> onChanged,
    ThemeData theme,
  ) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: _getInputDecoration(label, Icons.list, theme),
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: onChanged,
      validator: (val) => val == null ? 'Por favor, selecione uma opção' : null,
    );
  }

  InputDecoration _getInputDecoration(
    String label,
    IconData icon,
    ThemeData theme,
  ) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: theme.colorScheme.primary),
      filled: true,
      fillColor: const Color(0xFFF1F3F6),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      prefixIcon: Icon(icon, color: theme.colorScheme.primary),
    );
  }
}
