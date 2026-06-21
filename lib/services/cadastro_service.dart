import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import '../config/config.dart';

class CadastroService {
  static final String? _baseUrl = Config.apiUrl;
  static final Box _tabelasBox = Hive.box('tabelasSuporteBox');

  static Future<List<String>> buscarSalas() async {
    if (_tabelasBox.containsKey('cache_salas')) {
      final List<dynamic> cached = _tabelasBox.get('cache_salas');
      return cached.cast<String>();
    }

    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/api/suporte/locais'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> dados = jsonDecode(response.body);
        final listaSalas = dados
            .map((item) => item['cod_sala'].toString())
            .toList();
        await _tabelasBox.put('cache_salas', listaSalas);
        return listaSalas;
      }
    } catch (_) {}
    return [];
  }

  static Future<List<Map<String, dynamic>>> buscarDefeitosGeral() async {
    if (_tabelasBox.containsKey('cache_defeitos_todos')) {
      final String jsonStr = _tabelasBox.get('cache_defeitos_todos');
      final List<dynamic> decoded = jsonDecode(jsonStr);
      return decoded.map((item) => Map<String, dynamic>.from(item)).toList();
    }

    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/api/defeitos/'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> dados = jsonDecode(response.body);
        final listaDefeitos = dados
            .map(
              (item) => {
                'id': item['id'].toString(),
                'titulo': item['titulo'].toString(),
                'categoria': item['categoria'].toString(),
              },
            )
            .toList();

        await _tabelasBox.put(
          'cache_defeitos_todos',
          jsonEncode(listaDefeitos),
        );
        return listaDefeitos;
      }
    } catch (_) {}
    return [];
  }

  static Future<List<Map<String, dynamic>>> buscarSolucoesGeral() async {
    if (_tabelasBox.containsKey('cache_solucoes_todas')) {
      final String jsonStr = _tabelasBox.get('cache_solucoes_todas');
      final List<dynamic> decoded = jsonDecode(jsonStr);
      return decoded.map((item) => Map<String, dynamic>.from(item)).toList();
    }

    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/api/solucoes/'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> dados = jsonDecode(response.body);
        final listaSolucoes = dados
            .map(
              (item) => {
                'id': item['id'].toString(),
                'titulo': item['titulo'].toString(),
                'categoria': item['categoria'].toString(),
              },
            )
            .toList();

        await _tabelasBox.put(
          'cache_solucoes_todas',
          jsonEncode(listaSolucoes),
        );
        return listaSolucoes;
      }
    } catch (_) {}
    return [];
  }

  static Future<List<String>> buscarEquipamentos() async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/api/equipamentos/'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> dados = jsonDecode(response.body);
        return dados.map((item) => item['cod_patrimonio'].toString()).toList();
      }
    } catch (_) {}
    return [];
  }

  static Future<bool> enviarCadastro(
    String endpoint,
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl$endpoint'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (endpoint.contains('locais')) {
          await _tabelasBox.delete('cache_salas');
        } else if (endpoint.contains('defeitos')) {
          await _tabelasBox.delete('cache_defeitos_todos');
        } else if (endpoint.contains('solucoes')) {
          await _tabelasBox.delete('cache_solucoes_todas');
        }
        return true;
      }
    } catch (_) {}
    return false;
  }
}
