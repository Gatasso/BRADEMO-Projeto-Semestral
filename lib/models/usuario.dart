class Usuario {
  final String id;
  final String prontuario;
  final String nome;
  final String tipo;
  // final String email;

  Usuario({
    required this.id,
    required this.prontuario,
    required this.nome,
    required this.tipo,
    // required this.email;
  });

  // Factory para converter o JSON da sua API Flask em um Objeto Dart
  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'],
      prontuario: json['prontuario'],
      nome: json['nome'],
      tipo: json['tipo']?.toString() ?? 'Aluno',
      // email: json['email']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'prontuario': prontuario, 'nome': nome, 'tipo': tipo};
    // return {'id': id, 'prontuario': prontuario, 'nome': nome, 'tipo': tipo, 'email': email};
  }
}
