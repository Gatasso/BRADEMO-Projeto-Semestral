import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import '../models/equipment.dart';
import '../models/login.dart';

class DatabaseService {
  static const String _boxName = 'equipments';

  static Future<List<User>> loadUsers() async {
    final String response = await rootBundle.loadString('assets/data/database.json');
    final data = json.decode(response);
    return (data['users'] as List).map((user) => User.fromJson(user)).toList();
  }

  static Future<List<Equipment>> loadEquipments() async {
    final box = Hive.box<Equipment>(_boxName);
    if (box.isEmpty) {
      final String response = await rootBundle.loadString('assets/data/database.json');
      final data = json.decode(response);
      final initialList = (data['equipments'] as List).map((eq) => Equipment.fromJson(eq)).toList();
      await box.addAll(initialList);
    }
    return box.values.toList();
  }

  static Future<void> updateEquipment(int index, Equipment equipment) async {
    final box = Hive.box<Equipment>(_boxName);
    await box.putAt(index, equipment);
  }

  static Future<bool> validateLogin(String prontuario, String senha) async {
    final users = await loadUsers();
    return users.any((user) => user.prontuario == prontuario && user.senha == senha);
  }
}