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
    // Tenta obter a imagem enviada pela API (como base64 em url_foto_anexo ou paths em imageUrl/image_url)
    final String apiImage = json['url_foto_anexo']?.toString() ??
        json['imageUrl']?.toString() ??
        json['image_url']?.toString() ??
        '';

    return Solicitacao(
      id: json['id']?.toString() ?? '',
      codSala: json['cod_sala'] ?? '',
      material: json['material'] ?? 'Material',
      idDefeito: json['id_defeito'] ?? 0,
      defeitoTitulo: json['defeito_titulo'] ?? 'Defeito não informado',
      status: json['status'] ?? 'Registrada',
      criadoEm: DateTime.parse(json['criado_em']),
      imageUrl: apiImage.isNotEmpty
          ? apiImage
          : _definirImagemPadrao(json['material'] ?? ''),
    );
  }

  static String _definirImagemPadrao(String material) {
    final m = material.toLowerCase();
    if (m.contains('projetor')) return 'assets/images/projetor.jpeg';
    if (m.contains('ar condicionado') || m.contains('ventilador')) {
      return 'assets/images/ventilador.jpeg';
    }
    if (m.contains('cadeira') ||
        m.contains('mesa') ||
        m.contains('mobiliário') ||
        m.contains('mobilia')) {
      return 'assets/images/computador.png';
    }
    return 'assets/images/computador.png';
  }
}
