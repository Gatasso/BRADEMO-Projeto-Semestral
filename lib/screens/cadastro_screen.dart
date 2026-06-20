import 'package:flutter/material.dart';
import '../models/equipment.dart';
import '../services/database_service.dart';

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _roomController = TextEditingController();
  final _detailsController = TextEditingController();
  String _selectedPriority = 'Média';

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        final equipment = Equipment(
          name: _nameController.text,
          room: _roomController.text,
          campus: 'IFSP Bragança Paulista',
          reportDate: DateTime.now(),
          priority: _selectedPriority,
          reports: 1,
          details: _detailsController.text,
          imageUrl: 'assets/images/equipment.png',
        );

        await DatabaseService.addEquipment(equipment);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Equipamento cadastrado com sucesso!')),
          );
          _formKey.currentState!.reset();
          _nameController.clear();
          _roomController.clear();
          _detailsController.clear();
          setState(() => _selectedPriority = 'Média');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao cadastrar: $e')),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _roomController.dispose();
    _detailsController.dispose();
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
          'Cadastrar Equipamento',
          style: TextStyle(
            color: theme.colorScheme.primary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Informações do Equipamento',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Nome do Equipamento',
                    labelStyle: TextStyle(
                      color: theme.colorScheme.primary,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF1F3F6),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: Icon(
                      Icons.devices,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o nome do equipamento';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _roomController,
                  decoration: InputDecoration(
                    labelText: 'Sala/Localização',
                    labelStyle: TextStyle(
                      color: theme.colorScheme.primary,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF1F3F6),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: Icon(
                      Icons.location_on,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira a sala/localização';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  // ignore: deprecated_member_use
                  value: _selectedPriority,
                  decoration: InputDecoration(
                    labelText: 'Prioridade',
                    labelStyle: TextStyle(
                      color: theme.colorScheme.primary,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF1F3F6),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: Icon(
                      Icons.priority_high,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Baixa', child: Text('Baixa')),
                    DropdownMenuItem(value: 'Média', child: Text('Média')),
                    DropdownMenuItem(value: 'Alta', child: Text('Alta')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedPriority = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _detailsController,
                  decoration: InputDecoration(
                    labelText: 'Descrição do Problema',
                    labelStyle: TextStyle(
                      color: theme.colorScheme.primary,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF1F3F6),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: Icon(
                      Icons.description,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira uma descrição';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Cadastrar Equipamento',
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
        ),
      ),
    );
  }
}
