class Solicitation {
  final String id;
  final String titulo;
  final String descricao;
  final String status; // 'Aberta', 'Em Andamento', 'Concluída', 'Cancelada'
  final String prioridade; // 'Baixa', 'Média', 'Alta'
  final String equipamento;
  final String sala;
  final DateTime dataCriacao;
  final DateTime? dataAtualizacao;
  final String solicitanteProntuario;

  Solicitation({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.status,
    required this.prioridade,
    required this.equipamento,
    required this.sala,
    required this.dataCriacao,
    required this.solicitanteProntuario,
    this.dataAtualizacao,
  });

  factory Solicitation.fromJson(Map<String, dynamic> json) {
    return Solicitation(
      id: json['id'] ?? '',
      titulo: json['titulo'] ?? '',
      descricao: json['descricao'] ?? '',
      status: json['status'] ?? 'Aberta',
      prioridade: json['prioridade'] ?? 'Média',
      equipamento: json['equipamento'] ?? '',
      sala: json['sala'] ?? '',
      dataCriacao: json['dataCriacao'] != null
          ? DateTime.parse(json['dataCriacao'])
          : DateTime.now(),
      dataAtualizacao: json['dataAtualizacao'] != null
          ? DateTime.parse(json['dataAtualizacao'])
          : null,
      solicitanteProntuario: json['solicitanteProntuario'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descricao': descricao,
      'status': status,
      'prioridade': prioridade,
      'equipamento': equipamento,
      'sala': sala,
      'dataCriacao': dataCriacao.toIso8601String(),
      'dataAtualizacao': dataAtualizacao?.toIso8601String(),
      'solicitanteProntuario': solicitanteProntuario,
    };
  }
}
