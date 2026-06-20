import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import '../models/equipment.dart';
import '../models/login.dart';
import '../models/solicitation.dart';

class DatabaseService {
  static const String _boxName = 'equipments';
  static const String _profileBoxName = 'profile_box';
  static const String _solicitationsBoxName = 'solicitations';

  // --- MÉTODOS DE USUÁRIO / LOGIN ---
  static Future<List<User>> loadUsers() async {
    final String response = await rootBundle.loadString(
      'assets/data/database.json',
    );
    final data = json.decode(response);
    return (data['users'] as List).map((user) => User.fromJson(user)).toList();
  }

  static Future<bool> validateLogin(String prontuario, String senha) async {
    final users = await loadUsers();
    return users.any(
      (user) => user.prontuario == prontuario && user.senha == senha,
    );
  }

  // --- MÉTODOS DE EQUIPAMENTOS ---
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

  /// 🟢 CORREÇÃO: Método addEquipment que estava faltando para a CadastroScreen
  static Future<void> addEquipment(Equipment equipment) async {
    final box = Hive.box<Equipment>(_boxName);
    await box.add(equipment);
  }

  // --- MÉTODOS DE FOTO DE PERFIL ---
  static Future<void> saveProfilePhoto(String base64String) async {
    final box = Hive.box(_profileBoxName);
    await box.put('profile_photo', base64String);
  }

  static Future<String?> loadProfilePhoto() async {
    final box = Hive.box(_profileBoxName);
    return box.get('profile_photo') as String?;
  }

  // --- MÉTODOS DE SOLICITAÇÕES ---
  /// 🟢 CORREÇÃO: Método loadSolicitations que estava faltando para a SolicitationsScreen
  static Future<List<Solicitation>> loadSolicitations() async {
    final box = Hive.box(_solicitationsBoxName);

    // Se a caixa estiver vazia no Hive, carrega dados iniciais do arquivo JSON simulado
    if (box.isEmpty) {
      try {
        final String response = await rootBundle.loadString(
          'assets/data/database.json',
        );
        final data = json.decode(response);
        if (data['solicitations'] != null) {
          final initialList = (data['solicitations'] as List)
              .map((sol) => Solicitation.fromJson(sol))
              .toList();

          // Salva cada uma mapeada por ID ou em lista ordenada
          for (var sol in initialList) {
            await box.put(
              sol.id,
              sol.toJson(),
            ); // salvando como mapa para evitar problemas de adapter
          }
        }
      } catch (e) {
        // Fallback caso não encontre a chave no JSON
        return [];
      }
    }

    // Mapeia de volta os itens salvos na caixa como instâncias de Solicitation
    final List<Solicitation> list = [];
    for (var key in box.keys) {
      final value = box.get(key);
      if (value is Map) {
        // Caso esteja salvo como Map (JSON)
        list.add(Solicitation.fromJson(Map<String, dynamic>.from(value)));
      } else if (value is Solicitation) {
        // Caso possua adapter direto configurado futuramente
        list.add(value);
      }
    }
    return list;
  }
}
