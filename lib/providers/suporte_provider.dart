import 'package:flutter/material.dart';
import '../services/cadastro_service.dart';
import '../services/solicitacao_service.dart';

class SuporteProvider extends ChangeNotifier {
  List<String> _salas = [];
  List<Map<String, dynamic>> _defeitosGeral = [];
  List<Map<String, dynamic>> _solucoesGeral = [];
  bool _carregandoEstaticos = false;

  List<String> get salas => _salas;
  List<Map<String, dynamic>> get defeitosGeral => _defeitosGeral;
  List<Map<String, dynamic>> get solucoesGeral => _solucoesGeral;
  bool get carregandoEstaticos => _carregandoEstaticos;

  Future<void> inicializarTabelasSuporte() async {
    _carregandoEstaticos = true;
    notifyListeners();

    _salas = await CadastroService.buscarSalas();
    _defeitosGeral = await CadastroService.buscarDefeitosGeral();
    _solucoesGeral = await CadastroService.buscarSolucoesGeral();

    _carregandoEstaticos = false;
    notifyListeners();
  }

  List<Map<String, dynamic>> filtrarDefeitosPorCategoria(String categoria) {
    final String busca = categoria.toLowerCase();
    return _defeitosGeral.where((item) {
      final String itemCat = item['categoria'].toString().toLowerCase();
      if (busca.contains('mobi') && itemCat.contains('mobi')) return true;
      if (busca.contains('equip') && itemCat.contains('equip')) return true;
      return itemCat == busca;
    }).toList();
  }

  List<Map<String, dynamic>> filtrarSolucoesPorCategoria(String categoria) {
    final String busca = categoria.toLowerCase();
    return _solucoesGeral.where((item) {
      final String itemCat = item['categoria'].toString().toLowerCase();
      if (busca.contains('mobi') && itemCat.contains('mobi')) return true;
      if (busca.contains('equip') && itemCat.contains('equip')) return true;
      return itemCat == busca;
    }).toList();
  }

  Future<void> invalidarCacheEAtualizar(String tipoEntidade) async {
    _carregandoEstaticos = true;
    notifyListeners();

    if (tipoEntidade == 'local') {
      _salas = await CadastroService.buscarSalas();
    } else if (tipoEntidade == 'defeito') {
      _defeitosGeral = await CadastroService.buscarDefeitosGeral();
    } else if (tipoEntidade == 'solucao') {
      _solucoesGeral = await CadastroService.buscarSolucoesGeral();
    }

    _carregandoEstaticos = false;
    notifyListeners();
  }
}
