import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import '../config/config.dart';
import '../models/solicitacao_model.dart';
import 'cadastro_service.dart';

final String? _baseUrl = Config.apiUrl;

Future<List<Solicitacao>> buscarSolicitacoesUsuario() async {
  final authBox = Hive.box('authBox');
  final String? usuarioId = authBox.get('usuario_id');
  if (usuarioId == null) return [];

  final solicitationsBox = Hive.box('solicitations');
  final url = Uri.parse('$_baseUrl/api/solicitacoes/usuario/$usuarioId');

  List<Solicitacao> apiList = [];
  bool hasConnection = false;

  try {
    final response = await http.get(url).timeout(const Duration(seconds: 4));
    if (response.statusCode == 200) {
      final List<dynamic> dados = jsonDecode(response.body);
      apiList = dados.map((json) => Solicitacao.fromJson(json)).toList();
      hasConnection = true;

      // Carrega as fotos dos chamados
      final List<Future<Solicitacao>> detailFutures = apiList.map((sol) async {
        try {
          final detailUrl = Uri.parse('$_baseUrl/api/solicitacoes/${sol.id}');
          final detailRes = await http
              .get(detailUrl)
              .timeout(const Duration(seconds: 2));
          if (detailRes.statusCode == 200) {
            final Map<String, dynamic> detailJson = jsonDecode(detailRes.body);
            final String apiImage =
                detailJson['url_foto_anexo']?.toString() ??
                detailJson['imageUrl']?.toString() ??
                detailJson['image_url']?.toString() ??
                '';
            if (apiImage.isNotEmpty) {
              return Solicitacao(
                id: sol.id,
                codSala: sol.codSala,
                material: sol.material,
                idDefeito: sol.idDefeito,
                defeitoTitulo: sol.defeitoTitulo,
                status: sol.status,
                criadoEm: sol.criadoEm,
                imageUrl: apiImage,
              );
            }
          }
        } catch (_) {}
        return sol;
      }).toList();

      apiList = await Future.wait(detailFutures);

      // Cache local
      for (var sol in apiList) {
        final existingLocal = solicitationsBox.get(sol.id);
        if (existingLocal == null) {
          await solicitationsBox.put(sol.id, {
            'imageUrl': sol.imageUrl,
            'material': sol.material,
            'cod_sala': sol.codSala,
            'defeito_titulo': sol.defeitoTitulo,
            'status': sol.status,
          });
        } else {
          // Atualiza cache mantendo imagem local
          final localMap = Map<String, dynamic>.from(existingLocal as Map);
          await solicitationsBox.put(sol.id, {
            'imageUrl':
                (localMap['imageUrl'] != null &&
                    localMap['imageUrl'].toString().length > 50)
                ? localMap['imageUrl']
                : sol.imageUrl,
            'material': sol.material,
            'cod_sala': sol.codSala,
            'defeito_titulo': sol.defeitoTitulo,
            'status': sol.status,
          });
        }
      }
    }
  } catch (_) {}

  if (!hasConnection) {
    // Modo offline: carrega do cache do Hive
    final List<Solicitacao> localList = [];
    for (var key in solicitationsBox.keys) {
      final localData = solicitationsBox.get(key);
      if (localData != null && localData is Map) {
        localList.add(
          Solicitacao(
            id: key.toString(),
            codSala: localData['cod_sala'] ?? '',
            material: localData['material'] ?? '',
            idDefeito: 1,
            defeitoTitulo: localData['defeito_titulo'] ?? '',
            status: localData['status'] ?? 'Registrada',
            criadoEm: DateTime.now(), // fallback
            imageUrl: localData['imageUrl'] ?? 'assets/images/computador.png',
          ),
        );
      }
    }
    return localList;
  }

  // Modo online: retorna a lista da API mesclada com os dados locais
  final List<Solicitacao> finalList = [];
  for (var sol in apiList) {
    final localData = solicitationsBox.get(sol.id);
    if (localData != null && localData is Map) {
      finalList.add(
        Solicitacao(
          id: sol.id,
          codSala: localData['cod_sala'] ?? sol.codSala,
          material: localData['material'] ?? sol.material,
          idDefeito: sol.idDefeito,
          defeitoTitulo: localData['defeito_titulo'] ?? sol.defeitoTitulo,
          status: localData['status'] ?? sol.status,
          criadoEm: sol.criadoEm,
          imageUrl: localData['imageUrl'] ?? sol.imageUrl,
        ),
      );
    } else {
      finalList.add(sol);
    }
  }

  return finalList;
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
    } catch (_) {}
    return [];
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
    } catch (_) {}
    return [];
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
    } catch (_) {}
    return [];
  }

  static Future<List<Map<String, dynamic>>> buscarDefeitosPorCategoria(
    String categoria,
  ) async {
    final todosDefeitos = await CadastroService.buscarDefeitosGeral();
    final String busca = categoria.toLowerCase();

    return todosDefeitos.where((item) {
      final String itemCat = item['categoria'].toString().toLowerCase();
      if (busca.contains('mobi') && itemCat.contains('mobi')) return true;
      if (busca.contains('equip') && itemCat.contains('equip')) return true;
      return itemCat == busca;
    }).toList();
  }

  static Future<bool> registrarSolicitacao(Map<String, dynamic> payload) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/solicitacoes/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );
      return response.statusCode == 201;
    } catch (_) {}
    return false;
  }
}
