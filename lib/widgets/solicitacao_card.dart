import 'package:flutter/material.dart';
import '../models/solicitacao_model.dart';
import 'equipment_image.dart';

/// Widget especializado para exibir os dados de uma Solicitação de reparo.
class SolicitacaoCard extends StatelessWidget {
  final Solicitacao solicitacao;
  final VoidCallback onTap;
  final double height;

  const SolicitacaoCard({
    super.key,
    required this.solicitacao,
    required this.onTap,
    this.height = 180.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    // Lógica antiga da Home concentrada aqui: Nome do Material + Título do Defeito
    final String tituloConcatenado =
        "${solicitacao.material} - ${solicitacao.defeitoTitulo}";

    // Define a cor do status dinamicamente
    final Color statusColor = solicitacao.status == 'Concluída'
        ? Colors.green
        : Colors.orange;

    // Trata o fallback da imagem caso não venha uma URL válida da API Flask
    final String imgUrl = solicitacao.imageUrl.startsWith('http')
        ? solicitacao.imageUrl
        : 'assets/images/computador.png';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Status: ${solicitacao.status}",
          style: textTheme.labelSmall?.copyWith(
            color: statusColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onTap,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                buildEquipmentImage(
                  imgUrl,
                  width: double.infinity,
                  height: height,
                  fit: BoxFit.cover,
                ),
                Container(
                  width: double.infinity,
                  height: height,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Color.fromRGBO(0, 0, 0, 0.6),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  left: 12,
                  right: 12, // Evita estouro de texto em telas menores
                  child: Text(
                    tituloConcatenado,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
