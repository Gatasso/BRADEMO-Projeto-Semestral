import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import '../models/equipment.dart';
import '../models/login.dart';

class DatabaseService {
  static const String _boxName = 'equipments';

  // IP local do computador rodando a API.
  // IMPORTANTE: Altere este IP para o IP da sua máquina na mesma rede Wi-Fi!
  static const String _computerIp = "192.168.15.98";
  static const String _baseUrl = "http://$_computerIp:5000/api";

  static Future<List<User>> loadUsers() async {
    final String response = await rootBundle.loadString(
      'assets/data/database.json',
    );
    final data = json.decode(response);
    return (data['users'] as List).map((user) => User.fromJson(user)).toList();
  }

  static Future<List<Equipment>> loadEquipments() async {
    final box = Hive.box<Equipment>(_boxName);

    try {
      // Tenta buscar os dados reais da API local
      final response = await http
          .get(Uri.parse('$_baseUrl/equipamentos'))
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final apiList = data.map((eq) => Equipment.fromApi(eq)).toList();

        // Limpa a base local e sincroniza com os dados do banco PostgreSQL
        await box.clear();
        await box.addAll(apiList);
        return apiList;
      }
    } catch (e) {
      print("Erro ao conectar na API: $e. Usando cache local do Hive.");
    }

    // Se a API estiver offline e o Hive estiver vazio, carrega os dados mockados
    if (box.isEmpty) {
      final String response = await rootBundle.loadString(
        'assets/data/database.json',
      );
      final data = json.decode(response);
      final initialList = (data['equipments'] as List)
          .map((eq) => Equipment.fromJson(eq))
          .toList();
      await box.addAll(initialList);
    }

    return box.values.toList();
  }

  static Future<void> updateEquipment(int index, Equipment equipment) async {
    final box = Hive.box<Equipment>(_boxName);
    // Atualiza localmente no Hive primeiro para resposta instantânea da interface
    await box.putAt(index, equipment);

    try {
      if (equipment.codPatrimonio != null) {
        // Envia atualização via PUT para a API local
        await http
            .put(
              Uri.parse('$_baseUrl/equipamentos/${equipment.codPatrimonio}'),
              headers: {'Content-Type': 'application/json'},
              body: json.encode({
                'nome': equipment.name,
                'descricao': equipment.details,
                'cod_sala': equipment.room,
              }),
            )
            .timeout(const Duration(seconds: 4));
      }
    } catch (e) {
      print("Erro ao sincronizar atualização com o servidor: $e");
    }
  }

  static Future<bool> validateLogin(String prontuario, String senha) async {
    try {
      // Faz o POST para a rota de login da API local
      final response = await http
          .post(
            Uri.parse('$_baseUrl/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'prontuario': prontuario}),
          )
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        // Salva a sessão do usuário no Hive para persistência e uso de dados
        final sessionBox = await Hive.openBox('session');
        await sessionBox.put('user_id', responseData['usuario']['id']);
        await sessionBox.put(
          'prontuario',
          responseData['usuario']['prontuario'],
        );
        await sessionBox.put('nome', responseData['usuario']['nome']);
        await sessionBox.put('tipo', responseData['usuario']['tipo']);

        return true;
      }
    } catch (e) {
      print("Erro ao autenticar com a API: $e");

      // Fallback offline: se falhar por erro de rede (celular sem rede/servidor offline),
      // valida contra os usuários locais para que você possa testar mesmo sem o servidor ativo.
      if (e is SocketException || e is http.ClientException) {
        final users = await loadUsers();
        final isValidLocal = users.any(
          (user) => user.prontuario == prontuario && user.senha == senha,
        );
        if (isValidLocal) {
          final sessionBox = await Hive.openBox('session');
          await sessionBox.put('user_id', 'e036a28a-b4fb-4c4c-9352-73de779e17dc'); // ID padrão do João Silva
          await sessionBox.put('prontuario', prontuario);
          await sessionBox.put('nome', 'Usuário Local (Offline)');
          await sessionBox.put('tipo', 'Aluno');
          return true;
        }
      }
    }
    return false;
  }

  // Enviar a abertura de chamado para a API Flask
  static Future<bool> createSolicitacao({
    required String usuarioId,
    required String codSala,
    required int idDefeito,
    required String codPatrimonio,
    String? descricaoDefeito,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/solicitacoes'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'usuario_id': usuarioId,
          'cod_sala': codSala,
          'id_defeito': idDefeito,
          'cod_patrimonio': codPatrimonio,
          'descricao_defeito': descricaoDefeito ?? '',
        }),
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 201) {
        return true;
      }
    } catch (e) {
      print("Erro ao cadastrar chamado na API: $e");
    }
    return false;
  }
}
