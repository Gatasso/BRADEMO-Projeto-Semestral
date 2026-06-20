class Usuario {
  final String id;
  final String prontuario;
  final String nome;
  final String tipo;

  Usuario({
    required this.id,
    required this.prontuario,
    required this.nome,
    required this.tipo,
  });

  // Factory para converter o JSON da sua API Flask em um Objeto Dart
  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'],
      prontuario: json['prontuario'],
      nome: json['nome'],
      tipo: json['tipo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'prontuario': prontuario, 'nome': nome, 'tipo': tipo};
  }
}
