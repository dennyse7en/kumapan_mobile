// lib/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Package untuk format tanggal dan angka
import 'package:kumapan_mobile/api/api_service.dart';
import 'package:kumapan_mobile/models/credit_application.dart';
import 'package:kumapan_mobile/screens/detail_screen.dart';
import 'package:kumapan_mobile/screens/login_screen.dart';
import 'package:kumapan_mobile/screens/create_application_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<List<CreditApplication>> _applicationsFuture;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _applicationsFuture = _apiService.getCreditApplications();
  }

  Future<void> _handleLogout() async {
    await _apiService.logout();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }

  // Fungsi untuk mendapatkan warna badge berdasarkan status
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Disetujui':
      case 'Lunas':
        return Colors.green;
      case 'Ditolak':
      case 'Dibatalkan':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Riwayat Pengajuan'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _handleLogout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: FutureBuilder<List<CreditApplication>>(
        future: _applicationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Gagal memuat data: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Anda belum memiliki pengajuan.'));
          }

          final applications = snapshot.data!;
          return ListView.builder(
            padding: EdgeInsets.all(8.0), // Beri sedikit padding pada list
            itemCount: applications.length,
            itemBuilder: (context, index) {
              final app = applications[index];

              // Format tanggal
              final date = DateTime.parse(app.createdAt);
              final formattedDate =
                  DateFormat('dd MMM yyyy', 'id_ID').format(date);

              // Format angka
              final currencyFormatter = NumberFormat.currency(
                  locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
              final formattedAmount = currencyFormatter.format(app.amount);

              return Card(
                elevation: 4.0,
                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            DetailScreen(applicationId: app.id),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Kode: ${app.trackingCode}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getStatusColor(app.status)
                                    .withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                app.status,
                                style: TextStyle(
                                  color: _getStatusColor(app.status),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Jumlah Pinjaman',
                                    style: TextStyle(
                                        color: Colors.grey[600], fontSize: 12)),
                                Text(formattedAmount,
                                    style: TextStyle(fontSize: 16)),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('Tanggal Pengajuan',
                                    style: TextStyle(
                                        color: Colors.grey[600], fontSize: 12)),
                                Text(formattedDate,
                                    style: TextStyle(fontSize: 16)),
                              ],
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => CreateApplicationScreen()),
          );
        },
        icon: Icon(Icons.add),
        label: Text('Buat Pengajuan Baru'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }
}
