import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import '../config/config.dart';

class UserService {
  static const String _boxName = 'currentUser';
  static final String? _baseUrl = Config.apiUrl;

  static Future<void> saveUser({
    required String id,
    required String prontuario,
    required String nome,
    required String email,
    required String tipo,
  }) async {
    final box = await Hive.openBox(_boxName);
    await box.putAll({
      'id': id,
      'prontuario': prontuario,
      'nome': nome,
      'email': email,
      'tipo': tipo,
    });
  }

  static Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final authBox = Hive.box('authBox');
      if (authBox.get('usuario_id') == null) return null;

      // Monta o mapa esperado pela ProfileScreen com base nas chaves salvas pelo AuthService
      return {
        'id': authBox.get('usuario_id'),
        'nome': authBox.get('usuario_nome'),
        'prontuario':
            authBox.get('usuario_prontuario') ??
            authBox.get('authBox_prontuario_fallback') ??
            '',
        'tipo': authBox.get('usuario_tipo'),
        'email': authBox.get(
          'usuario_email',
        ), // Fallback caso a API não mande email estruturado
      };
    } catch (e) {
      print('Erro ao obter usuário local do Hive: $e');
      return null;
    }
  }

  static Future<String?> getCurrentUserProntuario() async {
    final user = await getCurrentUser();
    return user?['prontuario'];
  }

  static Future<void> logout() async {
    final authBox = Hive.box('authBox');
    await authBox.clear();
  }
}
