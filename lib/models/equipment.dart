import 'package:hive/hive.dart';

part 'equipment.g.dart';

@HiveType(typeId: 0)
class Equipment {
  Equipment({
    required this.name,
    required this.room,
    required this.campus,
    required this.reportDate,
    required this.priority,
    required this.reports,
    required this.details,
    required this.imageUrl,
    this.codPatrimonio,
  });

  @HiveField(0)
  final String name;
  @HiveField(1)
  final String room;
  @HiveField(2)
  final String campus;
  @HiveField(3)
  final DateTime reportDate;
  @HiveField(4)
  final String priority;
  @HiveField(5)
  final int reports;
  @HiveField(6)
  final String details;
  @HiveField(7)
  final String imageUrl;
  @HiveField(8)
  final String? codPatrimonio;

  Equipment copyWith({
    String? name,
    String? room,
    String? campus,
    DateTime? reportDate,
    String? priority,
    int? reports,
    String? details,
    String? imageUrl,
    String? codPatrimonio,
  }) {
    return Equipment(
      name: name ?? this.name,
      room: room ?? this.room,
      campus: campus ?? this.campus,
      reportDate: reportDate ?? this.reportDate,
      priority: priority ?? this.priority,
      reports: reports ?? this.reports,
      details: details ?? this.details,
      imageUrl: imageUrl ?? this.imageUrl,
      codPatrimonio: codPatrimonio ?? this.codPatrimonio,
    );
  }

  factory Equipment.fromJson(Map<String, dynamic> json) {
    return Equipment(
      name: json['name'],
      room: json['room'],
      campus: json['campus'],
      reportDate: DateTime.parse(json['reportDate']),
      priority: json['priority'],
      reports: json['reports'],
      details: json['details'],
      imageUrl: json['imageUrl'],
      codPatrimonio: json['codPatrimonio'] ?? json['cod_patrimonio'],
    );
  }

  factory Equipment.fromApi(Map<String, dynamic> json) {
    final nome = json['nome'] as String;
    final codPat = json['cod_patrimonio'] as String;
    String img = 'assets/images/ventilador.jpeg';
    if (nome.toLowerCase().contains('projetor')) {
      img = 'assets/images/projetor.jpeg';
    } else if (nome.toLowerCase().contains('computador')) {
      img = 'assets/images/computador.png';
    }

    return Equipment(
      name: nome,
      room: json['cod_sala'] ?? 'Sala B101',
      campus: 'IFSP Bragança Paulista',
      reportDate: json['criado_em'] != null ? DateTime.parse(json['criado_em']) : DateTime.now(),
      priority: 'Média',
      reports: 1,
      details: json['descricao'] ?? '',
      imageUrl: img,
      codPatrimonio: codPat,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'room': room,
      'campus': campus,
      'reportDate': reportDate.toIso8601String(),
      'priority': priority,
      'reports': reports,
      'details': details,
      'imageUrl': imageUrl,
      'codPatrimonio': codPatrimonio,
    };
  }

  String get formattedReportDate {
    final day = reportDate.day.toString().padLeft(2, '0');
    final month = reportDate.month.toString().padLeft(2, '0');
    final year = reportDate.year.toString();
    return '$day/$month/$year';
  }

  String get location => '$room · $campus';
}
