import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import '../models/solicitacao_model.dart';

Future<List<Solicitacao>> buscarSolicitacoesUsuario() async {
  final authBox = Hive.box('authBox');
  final String? usuarioId = authBox.get('usuario_id');

  if (usuarioId == null) return [];

  final url = Uri.parse(
    'https://arrumaifapiflask.vercel.app/api/solicitacoes/usuario/$usuarioId',
  );

  try {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> dados = jsonDecode(response.body);
      return dados.map((json) => Solicitacao.fromJson(json)).toList();
    } else if (response.statusCode == 404) {
      // MSG004: Nenhum registro encontrado
      return [];
    }
    return [];
  } catch (e) {
    print('Erro ao buscar solicitações: $e');
    return [];
  }
}
