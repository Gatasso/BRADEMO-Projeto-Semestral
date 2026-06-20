// lib/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import '../models/usuario.dart';

class AuthService {
  static const String _baseUrl = 'https://arrumaifapiflask.vercel.app';

  /// Realiza o login na API Flask e salva o ID do usuário no Hive se obtiver sucesso.
  static Future<bool> login(String prontuario, String senha) async {
    final url = Uri.parse('$_baseUrl/api/login/');
    
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'prontuario': prontuario,
          'senha': senha,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        
        // Mapeia os dados internos do nó "usuario" vindo do Flask
        final usuarioData = responseData['usuario'];
        final usuario = Usuario.fromJson(usuarioData);

        // Abre a caixa do Hive (garanta que foi inicializada no main.dart)
        final authBox = Hive.box('authBox');
        
        // Persiste o ID do usuário e dados que achar necessário
        await authBox.put('usuario_id', usuario.id);
        await authBox.put('usuario_nome', usuario.nome);
        await authBox.put('usuario_tipo', usuario.tipo);
        await authBox.put('is_logged_in', true);

        return true;
      } else {
        // Log ou tratamento de erro caso a API retorne 401, 400, etc.
        print('Erro no login: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Erro de conexão com a API: $e');
      return false;
    }
  }

  /// Retorna o ID do usuário logado de forma síncrona e rápida
  static String? getUsuarioId() {
    final authBox = Hive.box('authBox');
    return authBox.get('usuario_id') as String?;
  }

  /// Realiza o logout limpando a caixa do Hive
  static Future<void> logout() async {
    final authBox = Hive.box('authBox');
    await authBox.clear();
  }
}