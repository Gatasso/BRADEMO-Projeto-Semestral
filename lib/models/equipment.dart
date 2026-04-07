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
  });

  final String name;
  final String room;
  final String campus;
  final DateTime reportDate;
  final String priority;
  final int reports;
  final String details;
  final String imageUrl;

  String get formattedReportDate {
    final day = reportDate.day.toString().padLeft(2, '0');
    final month = reportDate.month.toString().padLeft(2, '0');
    final year = reportDate.year.toString();
    return '$day/$month/$year';
  }

  String get location => '$room · $campus';
}
