import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../services/cadastro_service.dart';
import '../services/solicitacao_service.dart';

class SolicitacaoProvider extends ChangeNotifier {
  final Box _authBox = Hive.box('authBox');

  int _currentStep = 1;
  bool _isLoading = true;
  bool _isSubmitting = false;

  List<String> _salas = [];
  List<Map<String, dynamic>> _equipamentos = [];
  List<Map<String, dynamic>> _componentes = [];
  List<Map<String, dynamic>> _mobiliarios = [];
  List<Map<String, dynamic>> _defeitos = [];

  String? _selectedRoom;
  String _materialType = 'Equipamento';
  String? _selectedEquipment;
  bool _isComponent = false;
  String? _selectedComponent;
  String? _selectedMobiliario;
  String? _selectedDefect;
  String? _base64Image;

  int get currentStep => _currentStep;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  List<String> get salas => _salas;
  List<Map<String, dynamic>> get equipamentos => _equipamentos;
  List<Map<String, dynamic>> get componentes => _componentes;
  List<Map<String, dynamic>> get mobiliarios => _mobiliarios;
  List<Map<String, dynamic>> get defeitos => _defeitos;

  String? get selectedRoom => _selectedRoom;
  String get materialType => _materialType;
  String? get selectedEquipment => _selectedEquipment;
  bool get isComponent => _isComponent;
  String? get selectedComponent => _selectedComponent;
  String? get selectedMobiliario => _selectedMobiliario;
  String? get selectedDefect => _selectedDefect;
  String? get base64Image => _base64Image;

  Future<void> inicializarProvider() async {
    _isLoading = true;
    notifyListeners();
    _salas = await CadastroService.buscarSalas();
    _isLoading = false;
    notifyListeners();
  }

  void setRoom(String? room) {
    _selectedRoom = room;
    notifyListeners();
  }

  void setMaterialType(String type) {
    _materialType = type;
    _selectedEquipment = null;
    _selectedComponent = null;
    _selectedMobiliario = null;
    _selectedDefect = null;
    _isComponent = false;
    notifyListeners();
  }

  void setEquipment(String? equip) {
    _selectedEquipment = equip;
    notifyListeners();
  }

  void setComponent(String? comp) {
    _selectedComponent = comp;
    notifyListeners();
  }

  void setMobiliario(String? mobi) {
    _selectedMobiliario = mobi;
    notifyListeners();
  }

  void setDefect(String? defect) {
    _selectedDefect = defect;
    notifyListeners();
  }

  void setImage(String? base64) {
    _base64Image = base64;
    notifyListeners();
  }

  void backStep() {
    if (_currentStep > 1) {
      _currentStep--;
      notifyListeners();
    }
  }

  void avancarPasso2() {
    if (_selectedRoom != null) {
      _currentStep = 2;
      notifyListeners();
    }
  }

  Future<void> avancarPasso3() async {
    _isLoading = true;
    notifyListeners();
    if (_materialType == 'Equipamento') {
      _equipamentos = await SolicitacaoService.buscarEquipamentosPorSala(
        _selectedRoom!,
      );
    } else {
      _mobiliarios = await SolicitacaoService.buscarMobiliarios();
    }
    _isLoading = false;
    _currentStep = 3;
    notifyListeners();
  }

  Future<void> avancarPasso4() async {
    _isLoading = true;
    notifyListeners();
    _defeitos = await SolicitacaoService.buscarDefeitosPorCategoria(
      _materialType,
    );
    _isLoading = false;
    _currentStep = 4;
    notifyListeners();
  }

  Future<void> alternarComponenteCheckbox(bool checked) async {
    _isComponent = checked;
    _selectedComponent = null;
    _componentes = [];
    notifyListeners();

    if (_isComponent) {
      _isLoading = true;
      notifyListeners();
      _componentes = await SolicitacaoService.buscarComponentes();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> dispararSubmissaoServidor(String descricao) async {
    final String? usuarioId = _authBox.get('usuario_id');
    if (usuarioId == null || _selectedDefect == null) return false;

    _isSubmitting = true;
    notifyListeners();

    final Map<String, dynamic> payload = {
      'usuario_id': usuarioId,
      'cod_sala': _selectedRoom,
      'id_defeito': _selectedDefect,
      'descricao_defeito': descricao.trim().isEmpty ? null : descricao.trim(),
      'url_foto_anexo': _base64Image,
      'cod_patrimonio': null,
      'mobiliario_id': null,
      'componente_id': null,
    };

    if (_materialType == 'Mobília') {
      payload['mobiliario_id'] = _selectedMobiliario;
    } else {
      if (_isComponent) {
        payload['componente_id'] = _selectedComponent;
      } else {
        payload['cod_patrimonio'] = _selectedEquipment;
      }
    }

    final sucesso = await SolicitacaoService.registrarSolicitacao(payload);
    _isSubmitting = false;

    if (sucesso) {
      _currentStep = 1;
      _selectedRoom = null;
      _selectedEquipment = null;
      _selectedComponent = null;
      _selectedMobiliario = null;
      _selectedDefect = null;
      _base64Image = null;
      _isComponent = false;
      _equipamentos = [];
      _mobiliarios = [];
      _componentes = [];
      _defeitos = [];
    }
    notifyListeners();
    return sucesso;
  }
}
