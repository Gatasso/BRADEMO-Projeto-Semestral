import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/config.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();

  factory ApiService() {
    return _instance;
  }

  ApiService._internal();

  final String? _baseUrl = Config.apiUrl;

  // Get Equipments
  Future<List<dynamic>> getEquipments() async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/equipamento'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

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
      final response = await http
          .get(
            Uri.parse('$_baseUrl/solicitacao'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

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
      final response = await http
          .post(
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
          )
          .timeout(const Duration(seconds: 10));

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
      final response = await http
          .get(
            Uri.parse('$_baseUrl/local'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

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
      final response = await http
          .get(
            Uri.parse('$_baseUrl/defeitos'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

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
