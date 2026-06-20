class Solicitacao {
  final String id;
  final String codSala;
  final String material;
  final int idDefeito;
  final String defeitoTitulo;
  final String status;
  final DateTime criadoEm;
  final String imageUrl; // Adicionada para alimentar seu EquipmentCard

  Solicitacao({
    required this.id,
    required this.codSala,
    required this.material,
    required this.idDefeito,
    required this.defeitoTitulo,
    required this.status,
    required this.criadoEm,
    required this.imageUrl,
  });

  factory Solicitacao.fromJson(Map<String, dynamic> json) {
    return Solicitacao(
      id: json['id'],
      codSala: json['cod_sala'] ?? '',
      material: json['material'] ?? 'Material',
      idDefeito: json['id_defeito'] ?? 0,
      defeitoTitulo: json['defeito_titulo'] ?? 'Defeito não informado',
      status: json['status'] ?? 'Registrada',
      criadoEm: DateTime.parse(json['criado_em']),
      // Como a API não retorna imagem da solicitação ainda, definimos uma fallback padrão por tipo de material
      imageUrl: _definirImagemPadrao(json['material'] ?? ''),
    );
  }

  static String _definirImagemPadrao(String material) {
    final m = material.toLowerCase();
    if (m.contains('projetor')) return 'assets/images/projetor.png';
    if (m.contains('ar condicionado'))
      return 'assets/images/ar_condicionado.png';
    if (m.contains('cadeira') ||
        m.contains('mesa') ||
        m.contains('mobiliário')) {
      return 'assets/images/mobilia.png';
    }
    return 'assets/images/default_equipment.png';
  }
}
