// lib/models/credit_application_detail.dart
import 'package:kumapan_mobile/models/history.dart';

class CreditApplicationDetail {
  final String trackingCode;
  final String fullName;
  final String nik;
  // Tambahkan semua field lain yang Anda butuhkan di sini
  // ...
  final List<History> histories;

  CreditApplicationDetail({
    required this.trackingCode,
    required this.fullName,
    required this.nik,
    required this.histories,
  });

  factory CreditApplicationDetail.fromJson(Map<String, dynamic> json) {
    var historyList = json['histories'] as List;
    List<History> histories =
        historyList.map((i) => History.fromJson(i)).toList();

    return CreditApplicationDetail(
      trackingCode: json['tracking_code'],
      fullName: json['full_name'],
      nik: json['nik'],
      histories: histories,
    );
  }
}
