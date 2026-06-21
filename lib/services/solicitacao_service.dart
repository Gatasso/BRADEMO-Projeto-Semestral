import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import '../config/config.dart';
import '../models/solicitacao_model.dart';

final String? _baseUrl = Config.apiUrl;

Future<List<Solicitacao>> buscarSolicitacoesUsuario() async {
  final authBox = Hive.box('authBox');
  final String? usuarioId = authBox.get('usuario_id');
  if (usuarioId == null) return [];
  final url = Uri.parse('$_baseUrl/api/solicitacoes/usuario/$usuarioId');
  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> dados = jsonDecode(response.body);
      return dados.map((json) => Solicitacao.fromJson(json)).toList();
    }
    return [];
  } catch (e) {
    print('Erro ao buscar solicitações: $e');
    return [];
  }
}

class SolicitacaoService {
  static Future<List<Map<String, dynamic>>> buscarEquipamentosPorSala(
    String codSala,
  ) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/api/equipamentos/'));
      if (response.statusCode == 200) {
        final List<dynamic> dados = jsonDecode(response.body);
        return dados
            .where((item) => item['cod_sala'].toString() == codSala)
            .map(
              (item) => {
                'cod_patrimonio': item['cod_patrimonio'].toString(),
                'nome': item['nome'].toString(),
              },
            )
            .toList();
      }
      return [];
    } catch (e) {
      print('Erro ao buscar equipamentos por sala: $e');
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> buscarComponentes() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/api/componentes/'));
      if (response.statusCode == 200) {
        final List<dynamic> dados = jsonDecode(response.body);
        return dados
            .map(
              (item) => {
                'id': item['id'].toString(),
                'nome': item['nome'].toString(),
              },
            )
            .toList();
      }
      return [];
    } catch (e) {
      print('Erro ao buscar componentes: $e');
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> buscarMobiliarios() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/api/mobiliarios/'));
      if (response.statusCode == 200) {
        final List<dynamic> dados = jsonDecode(response.body);
        return dados
            .map(
              (item) => {
                'id': item['id'].toString(),
                'nome': item['nome'].toString(),
              },
            )
            .toList();
      }
      return [];
    } catch (e) {
      print('Erro ao buscar mobiliarios: $e');
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> buscarDefeitosPorCategoria(
    String categoria,
  ) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/api/defeitos/'));
      if (response.statusCode == 200) {
        final List<dynamic> dados = jsonDecode(response.body);
        return dados
            .where(
              (item) =>
                  item['categoria'].toString().toLowerCase() ==
                  categoria.toLowerCase(),
            )
            .map(
              (item) => {
                'id': item['id'].toString(),
                'titulo': item['titulo'].toString(),
              },
            )
            .toList();
      }
      return [];
    } catch (e) {
      print('Erro ao buscar defeitos: $e');
      return [];
    }
  }

  static Future<bool> registrarSolicitacao(Map<String, dynamic> payload) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/solicitacoes/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );
      return response.statusCode == 201;
    } catch (e) {
      print('Erro ao registrar solicitação: $e');
      return false;
    }
  }
}
