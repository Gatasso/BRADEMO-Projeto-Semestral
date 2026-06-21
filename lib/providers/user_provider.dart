import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/usuario.dart';

class UserProvider extends ChangeNotifier {
  final Box _authBox = Hive.box('authBox');

  Usuario? _usuarioLogado;
  bool _estaAutenticado = false;

  Usuario? get usuarioLogado => _usuarioLogado;
  bool get estaAutenticado => _estaAutenticado;

  void carregarSessaoUsuario() {
    final String? id = _authBox.get('usuario_id')?.toString();
    final String? prontuario = _authBox.get('usuario_prontuario')?.toString();
    final String? nome = _authBox.get('usuario_nome')?.toString();
    final String? tipo = _authBox.get('usuario_tipo')?.toString();

    if (id != null && prontuario != null && nome != null) {
      _usuarioLogado = Usuario(
        id: id,
        prontuario: prontuario,
        nome: nome,
        tipo: tipo ?? 'Aluno',
      );
      _estaAutenticado = true;
    } else {
      _usuarioLogado = null;
      _estaAutenticado = false;
    }
    notifyListeners();
  }

  void atualizarEstadoAposLogin() {
    carregarSessaoUsuario();
  }

  Future<void> efetuarLogout() async {
    _usuarioLogado = null;
    _estaAutenticado = false;

    await _authBox.clear();

    notifyListeners();
  }
}
