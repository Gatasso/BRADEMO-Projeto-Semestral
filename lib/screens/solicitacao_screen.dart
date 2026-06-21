import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import '../services/cadastro_service.dart';
import '../services/solicitacao_service.dart';

class SolicitacaoScreen extends StatefulWidget {
  const SolicitacaoScreen({super.key});

  @override
  State<SolicitacaoScreen> createState() => _SolicitacaoScreenState();
}

class _SolicitacaoScreenState extends State<SolicitacaoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descricaoController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  int _currentStep = 1;
  bool _isLoading = true;
  bool _isSubmitting = false;

  List<String> _salas = [];
  List<Map<String, dynamic>> _equipamentos = [];
  List<Map<String, dynamic>> _componentes = [];
  List<Map<String, dynamic>> _mobiliarios = [];
  List<Map<String, dynamic>> _defeitos = [];

  String? _selectedRoom;
  String _materialType = 'Equipamento';
  String? _selectedEquipment;
  bool _isComponent = false;
  String? _selectedComponent;
  String? _selectedMobiliario;
  String? _selectedDefect;
  String? _base64Image;

  @override
  void initState() {
    super.initState();
    _carregarSalas();
  }

  Future<void> _carregarSalas() async {
    try {
      final salasCarregadas = await CadastroService.buscarSalas();
      setState(() {
        _salas = salasCarregadas;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _avancarParaPasso2() async {
    if (_selectedRoom == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecione uma sala para continuar.'),
        ),
      );
      return;
    }
    setState(() => _currentStep = 2);
  }

  Future<void> _avancarParaPasso3() async {
    setState(() => _isLoading = true);
    try {
      if (_materialType == 'Equipamento') {
        final equips = await SolicitacaoService.buscarEquipamentosPorSala(
          _selectedRoom!,
        );
        setState(() {
          _equipamentos = equips;
          _selectedEquipment = null;
        });
      } else {
        final mobis = await SolicitacaoService.buscarMobiliarios();
        setState(() {
          _mobiliarios = mobis;
          _selectedMobiliario = null;
        });
      }
    } catch (_) {}
    setState(() {
      _isLoading = false;
      _currentStep = 3;
    });
  }

  Future<void> _avancarParaPasso4() async {
    if (_materialType == 'Equipamento' && _selectedEquipment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecione um equipamento.')),
      );
      return;
    }
    if (_materialType == 'Equipamento' &&
        _isComponent &&
        _selectedComponent == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecione o componente.')),
      );
      return;
    }
    if (_materialType == 'Mobília' && _selectedMobiliario == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecione uma mobília.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final categoria = _materialType == 'Mobília'
          ? 'Mobiliário'
          : 'Equipamento';
      final listaDefeitos = await SolicitacaoService.buscarDefeitosPorCategoria(
        categoria,
      );

      final seenIds = <String>{};
      final uniqueDefects = listaDefeitos
          .where((def) => seenIds.add(def['id'].toString()))
          .toList();

      setState(() {
        _defeitos = uniqueDefects;
        _selectedDefect = null;
        _isLoading = false;
        _currentStep = 4;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _onComponentCheckboxChanged(bool? checked) async {
    setState(() {
      _isComponent = checked ?? false;
      _selectedComponent = null;
      _componentes = [];
    });

    if (_isComponent) {
      final comps = await SolicitacaoService.buscarComponentes();
      setState(() => _componentes = comps);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 70,
      );
      if (image != null) {
        final bytes = await File(image.path).readAsBytes();
        setState(() {
          _base64Image = base64Encode(bytes);
        });
      }
    } catch (e) {
      debugPrint('Erro ao selecionar imagem: $e');
    }
  }

  Future<void> _enviarSolicitacao() async {
    if (_selectedDefect == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecione o defeito.')),
      );
      return;
    }

    final authBox = Hive.box('authBox');
    final String? usuarioId = authBox.get('usuario_id');
    if (usuarioId == null) return;

    setState(() => _isSubmitting = true);

    final Map<String, dynamic> payload = {
      'usuario_id': usuarioId,
      'cod_sala': _selectedRoom,
      'id_defeito': _selectedDefect,
      'descricao_defeito': _descricaoController.text.trim().isEmpty
          ? null
          : _descricaoController.text.trim(),
      'url_foto_anexo': _base64Image,
      'cod_patrimonio': null,
      'mobiliario_id': null,
      'componente_id': null,
    };

    if (_materialType == 'Mobília') {
      payload['mobiliario_id'] = _selectedMobiliario;
    } else {
      if (_isComponent) {
        payload['componente_id'] = _selectedComponent;
      } else {
        payload['cod_patrimonio'] = _selectedEquipment;
      }
    }

    final sucesso = await SolicitacaoService.registrarSolicitacao(payload);

    setState(() => _isSubmitting = false);

    if (mounted) {
      if (sucesso) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chamado aberto com sucesso!')),
        );
        _descricaoController.clear();
        setState(() {
          _currentStep = 1;
          _selectedRoom = null;
          _selectedEquipment = null;
          _selectedComponent = null;
          _selectedMobiliario = null;
          _selectedDefect = null;
          _base64Image = null;
          _isComponent = false;
          _equipamentos = [];
          _mobiliarios = [];
          _componentes = [];
          _defeitos = [];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao registrar chamado no servidor.'),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _descricaoController.dispose();
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
          'Reportar Novo Defeito',
          style: TextStyle(
            color: theme.colorScheme.primary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: _currentStep > 1
            ? IconButton(
                icon: Icon(Icons.arrow_back, color: theme.colorScheme.primary),
                onPressed: () => setState(() => _currentStep--),
              )
            : null,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_currentStep == 1) _buildStep1(theme, textTheme),
                    if (_currentStep == 2) _buildStep2(theme, textTheme),
                    if (_currentStep == 3) _buildStep3(theme, textTheme),
                    if (_currentStep == 4) _buildStep4(theme, textTheme),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildStepHeader(
    String stepTitle,
    String stepDescription,
    ThemeData theme,
    TextTheme textTheme,
  ) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 10),
          Text(
            stepTitle,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          Text(
            stepDescription,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black54,
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStep1(ThemeData theme, TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader(
          'Passo 1',
          'Escolha a Sala ou Laboratório do equipamento com defeito',
          theme,
          textTheme,
        ),
        const SizedBox(height: 40),
        DropdownButtonFormField<String>(
          key: const ValueKey('step1_room_dropdown_field'),
          value: _selectedRoom,
          decoration: _getInputDecoration(Icons.location_on, theme),
          hint: const Text('Selecione a Sala ou Laboratório'),
          items: _salas
              .map((sala) => DropdownMenuItem(value: sala, child: Text(sala)))
              .toList(),
          onChanged: (val) => setState(() => _selectedRoom = val),
        ),
        const SizedBox(height: 50),
        _buildNextButton(_avancarParaPasso2, theme),
      ],
    );
  }

  Widget _buildStep2(ThemeData theme, TextTheme textTheme) {
    final isEquip = _materialType == 'Equipamento';
    final isMobi = _materialType == 'Mobília';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader(
          'Passo 2',
          'Defina a Categoria do Material com Defeito',
          theme,
          textTheme,
        ),
        const SizedBox(height: 40),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _materialType = 'Equipamento'),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  height: 120,
                  decoration: BoxDecoration(
                    color: isEquip ? theme.colorScheme.primary : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.devices,
                        color: isEquip
                            ? Colors.white
                            : theme.colorScheme.primary,
                        size: 38,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Equipamento',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isEquip ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _materialType = 'Mobília'),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  height: 120,
                  decoration: BoxDecoration(
                    color: isMobi ? theme.colorScheme.primary : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chair,
                        color: isMobi
                            ? Colors.white
                            : theme.colorScheme.primary,
                        size: 38,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Mobília',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isMobi ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 50),
        _buildNextButton(_avancarParaPasso3, theme),
      ],
    );
  }

  Widget _buildStep3(ThemeData theme, TextTheme textTheme) {
    final bool isEquip = _materialType == 'Equipamento';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader('Passo 3', 'Selecione o Material', theme, textTheme),
        const SizedBox(height: 40),
        if (isEquip) ...[
          DropdownButtonFormField<String>(
            key: ValueKey('step3_equip_dropdown_${_equipamentos.length}'),
            value: _selectedEquipment,
            decoration: _getInputDecoration(Icons.devices, theme),
            hint: const Text('Selecione o Equipamento'),
            items: _equipamentos.isNotEmpty
                ? _equipamentos.map((eq) {
                    return DropdownMenuItem(
                      value: eq['cod_patrimonio'].toString(),
                      child: Text(
                        "${eq['nome']} (${eq['cod_patrimonio']})",
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList()
                : null,
            onChanged: _equipamentos.isNotEmpty
                ? (val) => setState(() => _selectedEquipment = val)
                : null,
            disabledHint: Text(
              'Nenhum equipamento nesta sala',
              style: TextStyle(color: Colors.grey[400]),
            ),
          ),
          const SizedBox(height: 20),
          CheckboxListTile(
            title: const Text(
              'O defeito é em um componente/acessório deste equipamento?',
              style: TextStyle(fontSize: 13),
            ),
            value: _isComponent,
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            onChanged: _selectedEquipment != null
                ? _onComponentCheckboxChanged
                : null,
          ),
          if (_isComponent && _componentes.isNotEmpty) ...[
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              key: ValueKey('step3_comp_dropdown_${_componentes.length}'),
              value: _selectedComponent,
              decoration: _getInputDecoration(Icons.cable, theme),
              hint: const Text('Selecione o Componente Afetado'),
              items: _componentes
                  .map(
                    (comp) => DropdownMenuItem(
                      value: comp['id'].toString(),
                      child: Text(comp['nome'].toString()),
                    ),
                  )
                  .toList(),
              onChanged: (val) => setState(() => _selectedComponent = val),
            ),
          ],
        ] else ...[
          DropdownButtonFormField<String>(
            key: ValueKey('step3_mobi_dropdown_${_mobiliarios.length}'),
            value: _selectedMobiliario,
            decoration: _getInputDecoration(Icons.chair, theme),
            hint: const Text('Selecione a Mobília Afetada'),
            items: _mobiliarios.isNotEmpty
                ? _mobiliarios
                      .map(
                        (mobi) => DropdownMenuItem(
                          value: mobi['id'].toString(),
                          child: Text(mobi['nome'].toString()),
                        ),
                      )
                      .toList()
                : null,
            onChanged: _mobiliarios.isNotEmpty
                ? (val) => setState(() => _selectedMobiliario = val)
                : null,
            disabledHint: Text(
              'Nenhuma mobília cadastrada',
              style: TextStyle(color: Colors.grey[400]),
            ),
          ),
        ],
        const SizedBox(height: 50),
        _buildNextButton(_avancarParaPasso4, theme),
      ],
    );
  }

  Widget _buildStep4(ThemeData theme, TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader(
          'Passo 4',
          'Selecione o defeito, forneça detalhes e anexe Evidências',
          theme,
          textTheme,
        ),
        const SizedBox(height: 40),
        Center(
          child: Column(
            children: [
              _base64Image != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(
                        base64Decode(_base64Image!),
                        height: 120,
                        width: 120,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Container(
                      height: 120,
                      width: 120,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F3F6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.add_a_photo,
                        size: 38,
                        color: theme.colorScheme.primary,
                      ),
                    ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.photo_camera, size: 14),
                    label: const Text('Câmera', style: TextStyle(fontSize: 12)),
                  ),
                  const SizedBox(width: 10),
                  TextButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo, size: 14),
                    label: const Text(
                      'Galeria',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        DropdownButtonFormField<String>(
          key: ValueKey(
            'step4_defect_dropdown_${_materialType}_${_defeitos.hashCode}',
          ),
          value: _selectedDefect,
          decoration: _getInputDecoration(Icons.report_problem, theme),
          hint: const Text('Selecione o Defeito Encontrado'),
          items: _defeitos.isNotEmpty
              ? _defeitos
                    .map(
                      (def) => DropdownMenuItem(
                        value: def['id'].toString(),
                        child: Text(def['titulo'].toString()),
                      ),
                    )
                    .toList()
              : null,
          onChanged: _defeitos.isNotEmpty
              ? (val) => setState(() => _selectedDefect = val)
              : null,
          disabledHint: Text(
            'Carregando defeitos...',
            style: TextStyle(color: Colors.grey[400]),
          ),
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _descricaoController,
          maxLines: 3,
          decoration: _getInputDecoration(
            Icons.description,
            theme,
            placeholder: 'Descrição complementar do problema (Opcional)',
          ),
        ),
        const SizedBox(height: 45),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _enviarSolicitacao,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isSubmitting
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    'Registrar Chamado',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildNextButton(VoidCallback onPressed, ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Avançar',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  InputDecoration _createInputDecoration(
    IconData icon,
    ThemeData theme, {
    String? placeholder,
  }) {
    return InputDecoration(
      hintText: placeholder,
      hintStyle: TextStyle(color: theme.colorScheme.primary.withOpacity(0.4)),
      filled: true,
      fillColor: const Color(0xFFF1F3F6),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      prefixIcon: Icon(icon, color: theme.colorScheme.primary),
    );
  }

  InputDecoration _getInputDecoration(
    IconData icon,
    ThemeData theme, {
    String? placeholder,
  }) {
    return _createInputDecoration(icon, theme, placeholder: placeholder);
  }
}
