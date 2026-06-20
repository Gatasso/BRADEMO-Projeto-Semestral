import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/config.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();

  factory ApiService() {
    return _instance;
  }

  ApiService._internal();

  final String _baseUrl = Config.apiUrl;

  // Login - Busca usuário na lista e valida senha localmente
  // Endpoint disponível: GET /api/usuarios/
  Future<Map<String, dynamic>> login(String prontuario, String senha) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/usuarios/'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      print('Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final usuarios = jsonDecode(response.body) as List;
        print('Usuários obtidos: ${usuarios.length}');
        
        // Procurar usuário com prontuário matching
        for (var usuarioData in usuarios) {
          if (usuarioData['prontuario'] == prontuario) {
            // Validar senha (usando padrão do .env por enquanto)
            // Em produção, deveria ser validado no servidor com bcrypt
            if (senha == Config.defaultUserPassword) {
              print('Login bem-sucedido para: $prontuario');
              return usuarioData;
            } else {
              throw Exception('Senha incorreta');
            }
          }
        }
        
        throw Exception('Usuário não encontrado: $prontuario');
      } else {
        throw Exception('Falha ao buscar usuários: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao fazer login: $e');
    }
  }

  // Get User by ID
  Future<Map<String, dynamic>> getUserById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/usuarios/$id'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Usuário não encontrado: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao buscar usuário: $e');
    }
  }

  // Get Equipments
  Future<List<dynamic>> getEquipments() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/equipamento'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Se a resposta é um objeto com chave 'equipamentos', extrai a lista
        if (data is Map && data.containsKey('equipamentos')) {
          return data['equipamentos'];
        }
        // Se a resposta é uma lista diretamente
        return data is List ? data : [];
      } else {
        throw Exception('Erro ao buscar equipamentos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao buscar equipamentos: $e');
    }
  }

  // Get Solicitations
  Future<List<dynamic>> getSolicitations() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/solicitacao'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Se a resposta é um objeto com chave 'solicitacoes', extrai a lista
        if (data is Map && data.containsKey('solicitacoes')) {
          return data['solicitacoes'];
        }
        // Se a resposta é uma lista diretamente
        return data is List ? data : [];
      } else {
        throw Exception('Erro ao buscar solicitações: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao buscar solicitações: $e');
    }
  }

  // Create Solicitation
  Future<Map<String, dynamic>> createSolicitation({
    required String titulo,
    required String descricao,
    required String equipamento,
    required String sala,
    required String prioridade,
    required String solicitanteProntuario,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/solicitacao'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'titulo': titulo,
          'descricao': descricao,
          'equipamento': equipamento,
          'sala': sala,
          'prioridade': prioridade,
          'solicitanteProntuario': solicitanteProntuario,
          'status': 'Aberta',
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erro ao criar solicitação: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao criar solicitação: $e');
    }
  }

  // Get Locais (Salas)
  Future<List<dynamic>> getLocais() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/local'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map && data.containsKey('locais')) {
          return data['locais'];
        }
        return data is List ? data : [];
      } else {
        throw Exception('Erro ao buscar locais: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao buscar locais: $e');
    }
  }

  // Get Defeitos
  Future<List<dynamic>> getDefeitos() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/defeitos'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map && data.containsKey('defeitos')) {
          return data['defeitos'];
        }
        return data is List ? data : [];
      } else {
        throw Exception('Erro ao buscar defeitos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao buscar defeitos: $e');
    }
  }
}
