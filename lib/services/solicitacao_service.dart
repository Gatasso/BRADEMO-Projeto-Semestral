import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import '../models/solicitacao_model.dart';
import '../config/config.dart';

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
    } else if (response.statusCode == 404) {
      return [];
    }
    return [];
  } catch (e) {
    print('Erro ao buscar solicitações: $e');
    return [];
  }
}

Future<Map<String, dynamic>> criarSolicitacao({
  required String titulo,
  required String descricao,
  required String equipamento,
  required String sala,
  required String prioridade,
  required String solicitanteProntuario,
}) async {
  final url = Uri.parse('$_baseUrl/solicitacao');
  try {
    final response = await http
        .post(
          url,
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

Future<List<dynamic>> buscarTodasSolicitacoes() async {
  final url = Uri.parse('$_baseUrl/solicitacao');
  try {
    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is Map && data.containsKey('solicitacoes')) {
        return data['solicitacoes'];
      }
      return data is List ? data : [];
    } else {
      throw Exception(
        'Erro ao buscar todas as solicitações: ${response.statusCode}',
      );
    }
  } catch (e) {
    throw Exception('Erro ao buscar solicitações: $e');
  }
}
