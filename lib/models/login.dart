class User {
  final String prontuario;
  final String senha;

  User({required this.prontuario, required this.senha});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      prontuario: json['prontuario'],
      senha: json['senha'],
    );
  }
}
