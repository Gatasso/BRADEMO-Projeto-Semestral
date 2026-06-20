import 'package:hive/hive.dart';

class UserService {
  static const String _boxName = 'currentUser';

  static Future<void> saveUser({
    required String id,
    required String prontuario,
    required String nome,
    required String email,
    required String tipo,
  }) async {
    final box = await Hive.openBox(_boxName);
    await box.putAll({
      'id': id,
      'prontuario': prontuario,
      'nome': nome,
      'email': email,
      'tipo': tipo,
    });
  }

  static Future<Map<String, dynamic>?> getCurrentUser() async {
    final box = await Hive.openBox(_boxName);
    if (box.isEmpty) return null;
    return {
      'id': box.get('id'),
      'prontuario': box.get('prontuario'),
      'nome': box.get('nome'),
      'email': box.get('email'),
      'tipo': box.get('tipo'),
    };
  }

  static Future<String?> getCurrentUserProntuario() async {
    final user = await getCurrentUser();
    return user?['prontuario'];
  }

  static Future<void> logout() async {
    final box = await Hive.openBox(_boxName);
    await box.clear();
  }
}
