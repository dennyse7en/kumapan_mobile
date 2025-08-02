// lib/models/history.dart
class History {
  final String status;
  final String createdAt;

  History({required this.status, required this.createdAt});

  factory History.fromJson(Map<String, dynamic> json) {
    return History(
      status: json['status'],
      createdAt: json['created_at'],
    );
  }
}
