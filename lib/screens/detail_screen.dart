// lib/screens/detail_screen.dart
import 'package:flutter/material.dart';
import 'package:kumapan_mobile/api/api_service.dart';
import 'package:kumapan_mobile/models/credit_application_detail.dart';

class DetailScreen extends StatefulWidget {
  final int applicationId;

  const DetailScreen({super.key, required this.applicationId});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Future<CreditApplicationDetail> _detailFuture;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _detailFuture =
        _apiService.getCreditApplicationDetail(widget.applicationId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Pengajuan'),
      ),
      body: FutureBuilder<CreditApplicationDetail>(
        future: _detailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Gagal memuat data: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('Data tidak ditemukan.'));
          }

          final detail = snapshot.data!;
          return SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Data Pengajuan',
                    style: Theme.of(context).textTheme.headlineSmall),
                SizedBox(height: 16),
                Text('Kode Lacak: ${detail.trackingCode}'),
                Text('Nama: ${detail.fullName}'),
                Text('NIK: ${detail.nik}'),
                // Tampilkan semua data lain di sini

                SizedBox(height: 24),
                Text('Riwayat Status',
                    style: Theme.of(context).textTheme.headlineSmall),
                SizedBox(height: 16),
                // Menampilkan riwayat status
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: detail.histories.length,
                  itemBuilder: (context, index) {
                    final history = detail.histories[index];
                    return ListTile(
                      leading: Icon(Icons.history),
                      title: Text(history.status),
                      subtitle: Text(history.createdAt),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
