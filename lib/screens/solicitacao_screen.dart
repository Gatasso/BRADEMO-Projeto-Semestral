import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/suporte_provider.dart';

class SolicitacaoScreen extends StatefulWidget {
  const SolicitacaoScreen({super.key});

  @override
  State<SolicitacaoScreen> createState() => _SolicitacaoScreenState();
}

class _SolicitacaoScreenState extends State<SolicitacaoScreen> {
  final _descricaoController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _descricaoController.dispose();
    super.dispose();
  }

  Future<void> _capturarFoto(
    ImageSource source,
    SuporteProvider provider,
  ) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 70,
      );
      if (image != null) {
        final bytes = await File(image.path).readAsBytes();
        provider.setImage(base64Encode(bytes));
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final provider = context.watch<SuporteProvider>();

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
        leading: provider.currentStep > 1
            ? IconButton(
                icon: Icon(Icons.arrow_back, color: theme.colorScheme.primary),
                onPressed: () => provider.backStep(),
              )
            : null,
      ),
      body: SafeArea(
        child: provider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (provider.currentStep == 1)
                      _buildStep1(provider, theme, textTheme),
                    if (provider.currentStep == 2)
                      _buildStep2(provider, theme, textTheme),
                    if (provider.currentStep == 3)
                      _buildStep3(provider, theme, textTheme),
                    if (provider.currentStep == 4)
                      _buildStep4(provider, theme, textTheme),
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

  Widget _buildStep1(
    SuporteProvider provider,
    ThemeData theme,
    TextTheme textTheme,
  ) {
    return Column(
      children: [
        _buildStepHeader(
          'Passo 1',
          'Escolha a Sala ou Laboratório do equipamento com defeito',
          theme,
          textTheme,
        ),
        const SizedBox(height: 40),
        DropdownButtonFormField<String>(
          key: const ValueKey('step1_room_dropdown'),
          value: provider.selectedRoom,
          decoration: _getInputDecoration(Icons.location_on, theme),
          hint: const Text('Selecione a Sala ou Laboratório'),
          items: provider.salas
              .map((sala) => DropdownMenuItem(value: sala, child: Text(sala)))
              .toList(),
          onChanged: (val) => provider.setRoom(val),
        ),
        const SizedBox(height: 50),
        _buildNextButton(() => provider.avancarPasso2(), theme),
      ],
    );
  }

  Widget _buildStep2(
    SuporteProvider provider,
    ThemeData theme,
    TextTheme textTheme,
  ) {
    final isEquip = provider.materialType == 'Equipamento';
    final isMobi = provider.materialType == 'Mobília';

    return Column(
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
                onTap: () => provider.setMaterialType('Equipamento'),
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
                onTap: () => provider.setMaterialType('Mobília'),
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
        _buildNextButton(() => provider.avancarPasso3(), theme),
      ],
    );
  }

  Widget _buildStep3(
    SuporteProvider provider,
    ThemeData theme,
    TextTheme textTheme,
  ) {
    final bool isEquip = provider.materialType == 'Equipamento';

    return Column(
      children: [
        _buildStepHeader('Passo 3', 'Selecione o Material', theme, textTheme),
        const SizedBox(height: 40),
        if (isEquip) ...[
          DropdownButtonFormField<String>(
            key: ValueKey('step3_eq_${provider.equipamentos.length}'),
            value: provider.selectedEquipment,
            decoration: _getInputDecoration(Icons.devices, theme),
            hint: const Text('Selecione o Equipamento'),
            items: provider.equipamentos.map((eq) {
              return DropdownMenuItem(
                value: eq['cod_patrimonio'].toString(),
                child: Text(
                  "${eq['nome']} (${eq['cod_patrimonio']})",
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: (val) => provider.setEquipment(val),
          ),
          const SizedBox(height: 20),
          CheckboxListTile(
            title: const Text(
              'O defeito é em um componente/acessório deste equipamento?',
              style: TextStyle(fontSize: 13),
            ),
            value: provider.isComponent,
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            onChanged: provider.selectedEquipment != null
                ? (val) => provider.alternarComponenteCheckbox(val ?? false)
                : null,
          ),
          if (provider.isComponent && provider.componentes.isNotEmpty) ...[
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              key: ValueKey('step3_comp_${provider.componentes.length}'),
              value: provider.selectedComponent,
              decoration: _getInputDecoration(Icons.cable, theme),
              hint: const Text('Selecione o Componente Afetado'),
              items: provider.componentes
                  .map(
                    (c) => DropdownMenuItem(
                      value: c['id'].toString(),
                      child: Text(c['nome'].toString()),
                    ),
                  )
                  .toList(),
              onChanged: (val) => provider.setComponent(val),
            ),
          ],
        ] else ...[
          DropdownButtonFormField<String>(
            key: ValueKey('step3_mob_${provider.mobiliarios.length}'),
            value: provider.selectedMobiliario,
            decoration: _getInputDecoration(Icons.chair, theme),
            hint: const Text('Selecione a Mobília Afetada'),
            items: provider.mobiliarios
                .map(
                  (m) => DropdownMenuItem(
                    value: m['id'].toString(),
                    child: Text(m['nome'].toString()),
                  ),
                )
                .toList(),
            onChanged: (val) => provider.setMobiliario(val),
          ),
        ],
        const SizedBox(height: 50),
        _buildNextButton(() => provider.avancarPasso4(), theme),
      ],
    );
  }

  Widget _buildStep4(
    SuporteProvider provider,
    ThemeData theme,
    TextTheme textTheme,
  ) {
    final defeitos = provider.defeitosFiltrados;

    return Column(
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
              provider.base64Image != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(
                        base64Decode(provider.base64Image!),
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
                    onPressed: () =>
                        _capturarFoto(ImageSource.camera, provider),
                    icon: const Icon(Icons.photo_camera, size: 14),
                    label: const Text('Câmera', style: TextStyle(fontSize: 12)),
                  ),
                  const SizedBox(width: 10),
                  TextButton.icon(
                    onPressed: () =>
                        _capturarFoto(ImageSource.gallery, provider),
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
            'step4_def_${defeitos.length}_${provider.materialType}',
          ),
          value: provider.selectedDefect,
          decoration: _getInputDecoration(Icons.report_problem, theme),
          hint: const Text('Selecione o Defeito Encontrado'),
          items: defeitos
              .map(
                (def) => DropdownMenuItem(
                  value: def['id'].toString(),
                  child: Text(def['titulo'].toString()),
                ),
              )
              .toList(),
          onChanged: (val) => provider.setDefect(val),
          disabledHint: Text(
            'Nenhum defeito encontrado',
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
            onPressed: provider.isSubmitting
                ? null
                : () async {
                    final status = await provider.dispararSubmissaoServidor(
                      _descricaoController.text,
                    );
                    if (status && mounted) {
                      _descricaoController.clear();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Chamado aberto com sucesso!'),
                        ),
                      );
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: provider.isSubmitting
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

  InputDecoration _getInputDecoration(
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
}
