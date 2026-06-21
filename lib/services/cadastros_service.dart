import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/config.dart';

class CadastroService {
  static final String? _baseUrl = Config.apiUrl;

  static Future<List<String>> buscarSalas() async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/api/suporte/locais'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> dados = jsonDecode(response.body);
        return dados.map((item) => item['cod_sala'].toString()).toList();
      }
      return [];
    } catch (e) {
      print('Erro ao buscar salas: $e');
      return [];
    }
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
      return [];
    } catch (e) {
      print('Erro ao buscar equipamentos: $e');
      return [];
    }
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

      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print('Erro ao enviar cadastro para $endpoint: $e');
      return false;
    }
  }
}
