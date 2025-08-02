// lib/models/credit_application.dart
class CreditApplication {
  final int id;
  final String trackingCode;
  final String createdAt;
  final double amount;
  final String status;

  CreditApplication({
    required this.id,
    required this.trackingCode,
    required this.createdAt,
    required this.amount,
    required this.status,
  });

  factory CreditApplication.fromJson(Map<String, dynamic> json) {
    return CreditApplication(
      id: json['id'] ?? 0,
      // Gunakan '??' untuk memberikan nilai default jika data null
      trackingCode: json['tracking_code'] ?? '',
      createdAt: json['created_at'] ?? '',
      amount: double.parse((json['amount'] ?? '0').toString()),
      status: json['status'] ?? 'Tidak Diketahui',
    );
  }
}
