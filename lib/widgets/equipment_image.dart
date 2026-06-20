import 'dart:io';
import 'package:flutter/material.dart';

/// Widget para renderizar imagens de equipamentos
/// com suporte a assets, URLs de rede e arquivos locais.
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
    return FileImage(File(imageUrl));
  }
}
