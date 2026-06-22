import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

/// Widget para renderizar imagens de equipamentos
/// com suporte a assets, URLs de rede, base64 e arquivos locais.
Widget buildEquipmentImage(
  String imageUrl, {
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
}) {
  if (imageUrl.isEmpty) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: const Icon(Icons.image, color: Colors.grey, size: 40),
    );
  }

  // Verifica se é uma string em formato Base64
  try {
    String cleanBase64 = imageUrl;
    if (imageUrl.startsWith('data:image')) {
      final commaIndex = imageUrl.indexOf(',');
      if (commaIndex != -1) {
        cleanBase64 = imageUrl.substring(commaIndex + 1);
      }
    }
    // Remove espaços e novas linhas que possam quebrar o decoder
    final cleanString = cleanBase64.trim().replaceAll(RegExp(r'\s+'), '');
    
    // Tenta decodificar apenas se tiver um tamanho mínimo de base64 de imagem
    if (cleanString.length > 50) {
      final bytes = base64Decode(cleanString);
      return Image.memory(
        bytes,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: width,
            height: height,
            color: Colors.grey[200],
            child: const Icon(Icons.broken_image, color: Colors.red, size: 40),
          );
        },
      );
    }
  } catch (_) {
    // Não é base64 válido ou falhou, continua com os fallbacks normais
  }

  if (imageUrl.startsWith('assets/')) {
    return Image.asset(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
    );
  } else if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
    return Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: width,
          height: height,
          color: Colors.grey[200],
          child: const Icon(Icons.broken_image, color: Colors.red, size: 40),
        );
      },
    );
  } else {
    return Image.file(
      File(imageUrl),
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: width,
          height: height,
          color: Colors.grey[200],
          child: const Icon(Icons.broken_image, color: Colors.red, size: 40),
        );
      },
    );
  }
}

/// Obtém o ImageProvider certo dependendo do formato do caminho onde está salva a imagem.
ImageProvider getEquipmentImageProvider(String imageUrl) {
  if (imageUrl.startsWith('assets/')) {
    return AssetImage(imageUrl);
  } else if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
    return NetworkImage(imageUrl);
  } else {
    try {
      String cleanBase64 = imageUrl;
      if (imageUrl.startsWith('data:image')) {
        final commaIndex = imageUrl.indexOf(',');
        if (commaIndex != -1) {
          cleanBase64 = imageUrl.substring(commaIndex + 1);
        }
      }
      final cleanString = cleanBase64.trim().replaceAll(RegExp(r'\s+'), '');
      if (cleanString.length > 50) {
        final bytes = base64Decode(cleanString);
        return MemoryImage(bytes);
      }
    } catch (_) {}
    return FileImage(File(imageUrl));
  }
}
