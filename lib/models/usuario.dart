import 'package:hive/hive.dart';

part 'usuario.g.dart'; // Indica o arquivo que o build_runner vai criar

@HiveType(typeId: 1) // ID único para o Adapter de Usuário
class Usuario {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String prontuario;

  @HiveField(2)
  final String nome;

  @HiveField(3)
  final String tipo;

  Usuario({
    required this.id,
    required this.prontuario,
    required this.nome,
    required this.tipo,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'],
      prontuario: json['prontuario'],
      nome: json['nome'],
      tipo: json['tipo']?.toString() ?? 'Aluno',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'prontuario': prontuario, 'nome': nome, 'tipo': tipo};
  }
}
