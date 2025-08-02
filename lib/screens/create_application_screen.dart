// lib/screens/create_application_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kumapan_mobile/api/api_service.dart';

class CreateApplicationScreen extends StatefulWidget {
  const CreateApplicationScreen({super.key});

  @override
  State<CreateApplicationScreen> createState() =>
      _CreateApplicationScreenState();
}

class _CreateApplicationScreenState extends State<CreateApplicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();
  bool _isLoading = false;

  // Controller untuk setiap field
  final _fullNameController = TextEditingController();
  final _nikController = TextEditingController();
  // ... Tambahkan controller lain sesuai kebutuhan ...
  final _amountController = TextEditingController();

  File? _ktpImage;
  File? _businessPhotoImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(
      ImageSource source, Function(File) onImagePicked) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        onImagePicked(File(pickedFile.path));
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() &&
        _ktpImage != null &&
        _businessPhotoImage != null) {
      setState(() {
        _isLoading = true;
      });

      // Buat Map untuk data form
      final formData = {
        'full_name': _fullNameController.text,
        'nik': _nikController.text,
        // ... Tambahkan semua field lain dari controller ...
        'amount': _amountController.text,
        'tenor': '6', // Contoh, bisa diganti dengan dropdown
      };

      final result = await _apiService.createCreditApplication(
        formData,
        _ktpImage!,
        _businessPhotoImage!,
      );

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'])),
        );
        if (result['success']) {
          Navigator.of(context).pop(); // Kembali ke dashboard
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Harap lengkapi semua data dan dokumen.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Formulir Pengajuan Baru')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _fullNameController,
                decoration: InputDecoration(labelText: 'Nama Lengkap'),
                validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
              ),
              TextFormField(
                controller: _nikController,
                decoration: InputDecoration(labelText: 'NIK'),
                validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
              ),
              // ... Tambahkan TextFormField lain untuk semua field ...
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(labelText: 'Jumlah Pinjaman'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
              ),

              SizedBox(height: 24),

              // Pemilih Gambar KTP
              _buildImagePicker(
                  'Foto KTP', _ktpImage, (file) => _ktpImage = file),

              SizedBox(height: 16),

              // Pemilih Gambar Tempat Usaha
              _buildImagePicker('Foto Tempat Usaha', _businessPhotoImage,
                  (file) => _businessPhotoImage = file),

              SizedBox(height: 32),

              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context)
                      .primaryColor, // Warna primary dari tema Anda
                  foregroundColor: Colors.white, // Warna teks putih
                  padding: EdgeInsets.symmetric(
                      vertical: 16), // Beri sedikit padding
                ),
                child: _isLoading
                    ? CircularProgressIndicator()
                    : Text('Kirim Pengajuan'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget helper untuk pemilih gambar
  Widget _buildImagePicker(
      String title, File? imageFile, Function(File) onImagePicked) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Container(
          height: 150,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: imageFile != null
              ? Image.file(imageFile, fit: BoxFit.cover)
              : Center(child: Text('Belum ada gambar dipilih')),
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.camera, onImagePicked),
              icon: Icon(Icons.camera_alt),
              label: Text('Kamera'),
            ),
            ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.gallery, onImagePicked),
              icon: Icon(Icons.photo_library),
              label: Text('Galeri'),
            ),
          ],
        )
      ],
    );
  }
}
