import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import '../services/database_service.dart';
import '../services/user_service.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  String? _selectedImagePath;
  bool _loadingPhoto = true;
  
  // Dados do usuário
  String _nome = 'Carregando...';
  String _prontuario = '';
  String _email = '';
  String _tipo = '';

  @override
  void initState() {
    super.initState();
    _loadProfilePhoto();
    _loadUserData();
  }

  /// Carrega dados do usuário do Hive
  Future<void> _loadUserData() async {
    try {
      final user = await UserService.getCurrentUser();
      if (mounted && user != null) {
        setState(() {
          _nome = user['nome'] ?? 'Usuário';
          _prontuario = user['prontuario'] ?? '';
          _email = user['email'] ?? '';
          _tipo = user['tipo'] ?? '';
        });
      }
    } catch (e) {
      debugPrint('Erro ao carregar dados do usuário: $e');
    }
  }

  /// Carrega a foto persistida no Hive ao abrir a tela.
  Future<void> _loadProfilePhoto() async {
    try {
      final saved = await DatabaseService.loadProfilePhoto();
      if (mounted) {
        setState(() {
          _selectedImagePath = saved as String?;
          _loadingPhoto = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loadingPhoto = false);
      }
      debugPrint('Erro ao carregar foto de perfil: $e');
    }
  }

  Future<void> _logout(BuildContext context) async {
    await UserService.logout();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (image != null) await _saveImage(image.path);
    } catch (e) {
      _showError('Erro ao selecionar foto: $e');
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (image != null) await _saveImage(image.path);
    } catch (e) {
      _showError('Erro ao capturar foto: $e');
    }
  }

  /// Converte a imagem para base64, persiste no Hive e atualiza o estado de forma segura.
  Future<void> _saveImage(String path) async {
    try {
      final bytes = await File(path).readAsBytes();
      final base64String = base64Encode(bytes);

      // Salva no banco de dados (Hive)
      await DatabaseService.saveProfilePhoto(base64String);

      // Verifica se o widget ainda está na árvore antes de atualizar o estado ou mostrar SnackBar
      if (!mounted) return;

      setState(() => _selectedImagePath = base64String);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto de perfil atualizada com sucesso')),
      );
    } catch (e) {
      _showError('Erro ao salvar foto: $e');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildProfilePhoto() {
    if (_loadingPhoto) {
      return CircleAvatar(
        radius: 60,
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_selectedImagePath != null && _selectedImagePath!.isNotEmpty) {
      try {
        final imageBytes = base64Decode(_selectedImagePath!);
        return CircleAvatar(
          radius: 60,
          backgroundImage: MemoryImage(imageBytes),
        );
      } catch (_) {}
    }

    return CircleAvatar(
      radius: 60,
      backgroundColor: Theme.of(context).colorScheme.primary,
      child: const Icon(Icons.person, size: 80, color: Colors.white),
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
        title: Text(
          'Meu Perfil',
          style: textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: IconButton(
              onPressed: () => _logout(context),
              icon: const Icon(Icons.logout),
              color: Colors.red,
              tooltip: 'Sair',
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth > 900 ? 40.0 : 20.0;

            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 32),
                    Center(
                      child: Column(
                        children: [
                          Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              _buildProfilePhoto(),
                              Container(
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.2),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: PopupMenuButton<String>(
                                  onSelected: (value) {
                                    if (value == 'gallery') {
                                      _pickImage();
                                    } else if (value == 'camera') {
                                      _takePhoto();
                                    }
                                  },
                                  itemBuilder: (BuildContext context) => [
                                    const PopupMenuItem<String>(
                                      value: 'gallery',
                                      child: Row(
                                        children: [
                                          Icon(Icons.image),
                                          SizedBox(width: 12),
                                          Text('Galeria'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem<String>(
                                      value: 'camera',
                                      child: Row(
                                        children: [
                                          Icon(Icons.camera_alt),
                                          SizedBox(width: 12),
                                          Text('Câmera'),
                                        ],
                                      ),
                                    ),
                                  ],
                                  child: const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Icon(Icons.camera_alt, color: Colors.white, size: 20),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _nome,
                            style: textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _tipo,
                            style: textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Informações Pessoais',
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F3F6),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow(context, Icons.badge_outlined, 'Prontuário', _prontuario),
                          const SizedBox(height: 16),
                          Divider(color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          _buildInfoRow(context, Icons.email_outlined, 'E-mail', _email),
                          const SizedBox(height: 16),
                          Divider(color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          _buildInfoRow(context, Icons.business_outlined, 'Tipo', _tipo),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Segurança',
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F3F6),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        ),
                      ),
                      child: ListTile(
                        leading: Icon(Icons.lock_outline, color: theme.colorScheme.primary),
                        title: const Text('Alterar Senha'),
                        subtitle: const Text('Atualize sua senha de acesso'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        contentPadding: EdgeInsets.zero,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Funcionalidade em desenvolvimento')),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Row(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: textTheme.labelSmall?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}