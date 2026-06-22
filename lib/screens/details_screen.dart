import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:hive/hive.dart';
import '../models/equipment.dart';
import '../widgets/equipment_image.dart';
import '../services/database_service.dart';
import '../models/solicitacao_model.dart';

class ItemDetailScreen extends StatefulWidget {
  // final Equipment equipment;
  final Solicitacao solicitacao;
  // final int index;

  const ItemDetailScreen({super.key, required this.solicitacao});

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  late Equipment _currentEquipment;
  bool isUrgent = false;
  bool _isEditing = false;
  int _activeTabIndex =
      0; // 0: Aba Detalhes, 1: Aba Localização, 2: Aba Histórico

  late TextEditingController _nameController;
  late TextEditingController _roomController;
  late TextEditingController _campusController;
  late TextEditingController _detailsController;
  late String _selectedPriority;
  late ImageProvider _imageProvider;

  String? _selectedLocalImagePath;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _currentEquipment = Equipment(
      name: widget.solicitacao.material,
      room: widget.solicitacao.codSala,
      campus: "IFSP",
      details: widget.solicitacao.defeitoTitulo,
      priority: widget.solicitacao.status == 'Alta' ? 'Alta' : 'Média',
      imageUrl: widget.solicitacao.imageUrl,
      reports: 1,
      reportDate: widget.solicitacao.criadoEm,
    );
    _nameController = TextEditingController(text: _currentEquipment.name);
    _roomController = TextEditingController(text: _currentEquipment.room);
    _campusController = TextEditingController(text: _currentEquipment.campus);
    _detailsController = TextEditingController(text: _currentEquipment.details);
    _selectedPriority = _currentEquipment.priority;
    _imageProvider = getEquipmentImageProvider(_currentEquipment.imageUrl);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _roomController.dispose();
    _campusController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  void _cancelEdit() {
    setState(() {
      _nameController.text = _currentEquipment.name;
      _roomController.text = _currentEquipment.room;
      _campusController.text = _currentEquipment.campus;
      _detailsController.text = _currentEquipment.details;
      _selectedPriority = _currentEquipment.priority;
      _selectedLocalImagePath = null;
      _imageProvider = getEquipmentImageProvider(_currentEquipment.imageUrl);
      _isEditing = false;
    });
  }

  Future<void> _saveEdit() async {
    String finalImagePath = _currentEquipment.imageUrl;
    if (_selectedLocalImagePath != null) {
      try {
        final appDir = await getApplicationDocumentsDirectory();
        final extension = p.extension(_selectedLocalImagePath!);
        final fileName =
            'equipamento_${DateTime.now().millisecondsSinceEpoch}$extension';
        final permanentPath = p.join(appDir.path, fileName);

        await File(_selectedLocalImagePath!).copy(permanentPath);
        finalImagePath = permanentPath;
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao salvar imagem permanentemente: $e'),
            ),
          );
        }
      }
    }

    final updatedEquipment = _currentEquipment.copyWith(
      name: _nameController.text,
      room: _roomController.text,
      campus: _campusController.text,
      details: _detailsController.text,
      priority: _selectedPriority,
      imageUrl: finalImagePath,
    );

    await DatabaseService.updateEquipment(updatedEquipment);

    try {
      final solicitationsBox = Hive.box('solicitations');
      await solicitationsBox.put(widget.solicitacao.id, {
        'imageUrl': finalImagePath,
        'material': _nameController.text,
        'cod_sala': _roomController.text,
        'defeito_titulo': _detailsController.text,
        'status': widget.solicitacao.status, // mantém o status original
      });
    } catch (e) {
      debugPrint('Erro ao salvar alteração no Hive: $e');
    }

    setState(() {
      _currentEquipment = updatedEquipment;
      _selectedLocalImagePath = null;
      _imageProvider = getEquipmentImageProvider(updatedEquipment.imageUrl);
      _isEditing = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Alterações salvas com sucesso!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() {
          _selectedLocalImagePath = pickedFile.path;
          _imageProvider = getEquipmentImageProvider(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao selecionar imagem: $e')),
        );
      }
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final theme = Theme.of(context);
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  'Alterar Foto do Equipamento',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFF1B5E20)),
                title: const Text('Tirar Foto (Câmera)'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: Color(0xFF1B5E20),
                ),
                title: const Text('Escolher da Galeria (Armazenamento)'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pop(context, _currentEquipment);
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 900;
            final imageHeight = isWide ? 420.0 : 350.0;
            final horizontalPadding = isWide ? 40.0 : 25.0;
            final contentPadding = EdgeInsets.symmetric(
              horizontal: horizontalPadding,
            );

            if (!isWide) {
              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              GestureDetector(
                                onTap: _isEditing
                                    ? _showImagePickerOptions
                                    : null,
                                child: Container(
                                  height: imageHeight,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(45),
                                      bottomRight: Radius.circular(45),
                                    ),
                                    image: DecorationImage(
                                      image: _imageProvider,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  child: _isEditing
                                      ? Container(
                                          decoration: BoxDecoration(
                                            color: Colors.black.withValues(
                                              alpha: 0.4,
                                            ),
                                            borderRadius:
                                                const BorderRadius.only(
                                                  bottomLeft: Radius.circular(
                                                    45,
                                                  ),
                                                  bottomRight: Radius.circular(
                                                    45,
                                                  ),
                                                ),
                                          ),
                                          child: const Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.camera_alt,
                                                  color: Colors.white,
                                                  size: 50,
                                                ),
                                                SizedBox(height: 8),
                                                Text(
                                                  'Alterar Foto',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      : null,
                                ),
                              ),
                              if (!_isEditing)
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
                                        color: isUrgent
                                            ? Colors.red
                                            : Colors.grey,
                                      ),
                                      onPressed: () =>
                                          setState(() => isUrgent = !isUrgent),
                                    ),
                                  ),
                                ),
                              Positioned(
                                top: 30,
                                right: _isEditing ? 20 : 75,
                                child: CircleAvatar(
                                  backgroundColor: Colors.white,
                                  child: IconButton(
                                    icon: Icon(
                                      _isEditing ? Icons.close : Icons.edit,
                                      color: const Color(0xFF1B5E20),
                                    ),
                                    onPressed: () {
                                      if (_isEditing) {
                                        _cancelEdit();
                                      } else {
                                        setState(() {
                                          _isEditing = true;
                                        });
                                      }
                                    },
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
                                    onPressed: () => Navigator.pop(
                                      context,
                                      _currentEquipment,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: _isEditing ? -20 : -70,
                                left: 20,
                                right: 20,
                                child: _isEditing
                                    ? Card(
                                        elevation: 4,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                        ),
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(
                                            vertical: 12,
                                            horizontal: 20,
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.edit,
                                                color: Color(0xFF1B5E20),
                                              ),
                                              SizedBox(width: 10),
                                              Text(
                                                'Modo de Edição Ativo',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF1B5E20),
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    : _buildInfoCard(context),
                              ),
                            ],
                          ),

                          SizedBox(height: _isEditing ? 40 : 90),

                          if (_isEditing)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 25.0,
                              ),
                              child: _buildEditForm(context),
                            )
                          else ...[
                            Padding(
                              padding: contentPadding,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildTabItem(context, "Detalhes", 0),
                                  _buildTabItem(context, "Localização", 1),
                                  _buildTabItem(context, "Histórico", 2),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(25.0),
                              child: _buildActiveTabContent(context),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  _buildActionButton(context),
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            GestureDetector(
                              onTap: _isEditing
                                  ? _showImagePickerOptions
                                  : null,
                              child: Container(
                                height: imageHeight,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(45),
                                    bottomRight: Radius.circular(45),
                                  ),
                                  image: DecorationImage(
                                    image: _imageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                child: _isEditing
                                    ? Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(
                                            alpha: 0.4,
                                          ),
                                          borderRadius: const BorderRadius.only(
                                            bottomLeft: Radius.circular(45),
                                            bottomRight: Radius.circular(45),
                                          ),
                                        ),
                                        child: const Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.camera_alt,
                                                color: Colors.white,
                                                size: 50,
                                              ),
                                              SizedBox(height: 8),
                                              Text(
                                                'Alterar Foto',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    : null,
                              ),
                            ),
                            if (!_isEditing)
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
                                      color: isUrgent
                                          ? Colors.red
                                          : Colors.grey,
                                    ),
                                    onPressed: () =>
                                        setState(() => isUrgent = !isUrgent),
                                  ),
                                ),
                              ),
                            Positioned(
                              top: 30,
                              right: _isEditing ? 20 : 75,
                              child: CircleAvatar(
                                backgroundColor: Colors.white,
                                child: IconButton(
                                  icon: Icon(
                                    _isEditing ? Icons.close : Icons.edit,
                                    color: const Color(0xFF1B5E20),
                                  ),
                                  onPressed: () {
                                    if (_isEditing) {
                                      _cancelEdit();
                                    } else {
                                      setState(() {
                                        _isEditing = true;
                                      });
                                    }
                                  },
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
                                  onPressed: () =>
                                      Navigator.pop(context, _currentEquipment),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: _isEditing ? -20 : -70,
                              left: 20,
                              right: 20,
                              child: _isEditing
                                  ? Card(
                                      elevation: 4,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 12,
                                          horizontal: 20,
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.edit,
                                              color: Color(0xFF1B5E20),
                                            ),
                                            SizedBox(width: 10),
                                            Text(
                                              'Modo de Edição Ativo',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF1B5E20),
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : _buildInfoCard(context),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: 30,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_isEditing)
                          Expanded(
                            child: SingleChildScrollView(
                              child: _buildEditForm(context),
                            ),
                          )
                        else ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildTabItem(context, "Detalhes", 0),
                              _buildTabItem(context, "Localização", 1),
                              _buildTabItem(context, "Histórico", 2),
                            ],
                          ),
                          const SizedBox(height: 25),
                          Expanded(child: _buildActiveTabContent(context)),
                        ],
                        _buildActionButton(context),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildEditForm(BuildContext context) {
    return Form(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informações do Equipamento',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Nome do Equipamento',
              prefixIcon: Icon(Icons.build),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _roomController,
            decoration: const InputDecoration(
              labelText: 'Sala',
              prefixIcon: Icon(Icons.room),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _campusController,
            decoration: const InputDecoration(
              labelText: 'Campus',
              prefixIcon: Icon(Icons.school),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _selectedPriority,
            decoration: const InputDecoration(
              labelText: 'Prioridade',
              prefixIcon: Icon(Icons.priority_high),
            ),
            items: const [
              DropdownMenuItem(value: 'Alta', child: Text('Alta')),
              DropdownMenuItem(value: 'Média', child: Text('Média')),
              DropdownMenuItem(value: 'Baixa', child: Text('Baixa')),
            ],
            onChanged: (val) {
              if (val != null) {
                setState(() {
                  _selectedPriority = val;
                });
              }
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _detailsController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Detalhes do Defeito',
              prefixIcon: Icon(Icons.description),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildActiveTabContent(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
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
                    _currentEquipment.location,
                    style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Reportado em ${_currentEquipment.formattedReportDate}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Prioridade ${_currentEquipment.priority}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _currentEquipment.priority.toLowerCase() == 'alta'
                    ? Colors.red
                    : _currentEquipment.priority.toLowerCase() == 'média'
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
              context,
              '${_currentEquipment.formattedReportDate} - Reporte criado.',
              true,
            ),
            _buildHistoryItem(
              context,
              '${_currentEquipment.reports} reportes registrados.',
              false,
            ),
            _buildHistoryItem(
              context,
              'Aguardando análise da equipe de TI.',
              false,
            ),
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
                children: [TextSpan(text: _currentEquipment.details)],
              ),
            ),
            const SizedBox(height: 20),
            _buildStatusInfoBox(context),
          ],
        );
    }
  }

  Widget _buildHistoryItem(BuildContext context, String text, bool isFirst) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: isFirst ? primaryColor : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 10),
          Text(text, style: TextStyle(color: Colors.grey[700])),
        ],
      ),
    );
  }

  Widget _buildStatusInfoBox(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: theme.colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'O reparo já está agendado pela equipe de TI.',
              style: TextStyle(color: theme.colorScheme.primary, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    final theme = Theme.of(context);
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
              _currentEquipment.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              _currentEquipment.location,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            Text(
              'Reportado em ${_currentEquipment.formattedReportDate}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.report_problem,
                  color: _currentEquipment.priority.toLowerCase() == 'alta'
                      ? Colors.red
                      : _currentEquipment.priority.toLowerCase() == 'média'
                      ? Colors.orange
                      : theme.colorScheme.secondary,
                  size: 20,
                ),
                const SizedBox(width: 6),
                Text(
                  'Prioridade ${_currentEquipment.priority.toLowerCase()}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _currentEquipment.priority.toLowerCase() == 'alta'
                        ? Colors.red
                        : _currentEquipment.priority.toLowerCase() == 'média'
                        ? Colors.orange
                        : theme.colorScheme.secondary,
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
                  '${_currentEquipment.reports} reportes',
                  style: TextStyle(color: Colors.grey[700], fontSize: 13),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(BuildContext context, String title, int index) {
    final primaryColor = Theme.of(context).colorScheme.primary;
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
              color: active ? primaryColor : Colors.grey[400],
            ),
          ),
          if (active)
            Container(
              margin: const EdgeInsets.only(top: 8),
              height: 3,
              width: 30,
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    if (_isEditing) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(25, 0, 25, 30),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 60,
                child: OutlinedButton(
                  onPressed: _cancelEdit,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF1B5E20), width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(
                      color: Color(0xFF1B5E20),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SizedBox(
                height: 60,
                child: ElevatedButton(
                  onPressed: _saveEdit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B5E20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Salvar',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(25, 0, 25, 30),
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: ElevatedButton(
          onPressed: () => _showSoonDialog(context),
          child: const Text(
            'Acompanhar Chamado',
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
        title: const Text("Notificação"),
        content: const Text("Você receberá atualizações sobre este chamado."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Entendido"),
          ),
        ],
      ),
    );
  }
}
