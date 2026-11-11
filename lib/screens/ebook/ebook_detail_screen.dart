import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/wali_model.dart';
import '../../services/storage_service.dart';

class EbookDetailScreen extends StatefulWidget {
  final WaliModel wali;

  const EbookDetailScreen({super.key, required this.wali});

  @override
  State<EbookDetailScreen> createState() => _EbookDetailScreenState();
}

class _EbookDetailScreenState extends State<EbookDetailScreen> {
  @override
  void initState() {
    super.initState();
    StorageService.addRecent(widget.wali);
  }

  Widget _buildHeaderImage(String gambarPath, String nama) {
    if (gambarPath.isNotEmpty) {
      if (gambarPath.startsWith('data:image')) {
        try {
          final base64Str = gambarPath.split(',').last;
          final bytes = base64Decode(base64Str);
          return Image.memory(
            bytes,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildHeaderFallback(nama),
          );
        } catch (_) {}
      } else if (gambarPath.startsWith('http')) {
        return Image.network(
          gambarPath,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildHeaderFallback(nama),
        );
      } else if (gambarPath.startsWith('assets/')) {
        return Image.asset(
          gambarPath,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildHeaderFallback(nama),
        );
      } else {
        return Image.file(
          File(gambarPath),
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildHeaderFallback(nama),
        );
      }
    }
    return _buildHeaderFallback(nama);
  }

  Widget _buildHeaderFallback(String nama) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF03045E), Color(0xFF0077B6), Color(0xFF00B4D8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          nama,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF0B132B),
      body: Stack(
        children: [
          // 1. GAMBAR BACKGROUND HEADER
          SizedBox(
            height: screenHeight * 0.5,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                _buildHeaderImage(widget.wali.gambar, widget.wali.nama),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.4),
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.7),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 60,
                  left: 20,
                  right: 20,
                  child: Text(
                    widget.wali.nama,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          blurRadius: 8,
                          color: Colors.black54,
                          offset: Offset(0, 2),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. SHEET PUTIH
          SizedBox.expand(
            child: DraggableScrollableSheet(
              initialChildSize: 0.55,
              minChildSize: 0.55,
              maxChildSize: 1.0,
              snap: false,
              builder: (context, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // HANDLE GARIS GULIR
                        Center(
                          child: Container(
                            width: 44,
                            height: 5,
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),

                        Text(
                          widget.wali.nama,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0B132B),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Penyebar Islam • ${widget.wali.wilayah}',
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 20),

                        if (widget.wali.ringkasan.isNotEmpty) ...[
                          Text(
                            widget.wali.ringkasan,
                            style: const TextStyle(
                              fontSize: 15,
                              fontStyle: FontStyle.italic,
                              color: Color(0xFF0077B6),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 16),
                        ],

                        // ====================================================
                        // KOTAK TABEL BIODATA & SILSILAH
                        // ====================================================
                        const Text(
                          '1. Data Diri & Silsilah',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0B132B),
                          ),
                        ),
                        const SizedBox(height: 12),

                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFFAFAFA),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey[200]!),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              )
                            ],
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              _buildTableHeader(),
                              const Divider(height: 16),
                              _buildTableRow(
                                  'Nama Lengkap', widget.wali.namaLengkap),
                              _buildTableRow('Gelar / Nama Lain',
                                  widget.wali.gelarNamaLain),
                              _buildTableRow('Asal-Usul & Kelahiran',
                                  widget.wali.asalUsulKelahiran),
                              _buildTableRow('Garis Keturunan',
                                  widget.wali.garisKeturunan),
                              _buildTableRow('Ayah', widget.wali.ayah),
                              _buildTableRow(
                                  'Pasangan / Istri', widget.wali.pasangIstri),
                              _buildTableRow('Keturunan Utama',
                                  widget.wali.keturunanUtama),
                              _buildTableRow('Wafat & Lokasi Makam',
                                  widget.wali.wafatLokasiMakam,
                                  isLast: true),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // ====================================================
                        // KISAH & SEJARAH LENGKAP (DI LUAR KOTAK TABEL)
                        // ====================================================
                        const Text(
                          'Kisah & Sejarah Lengkap',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0B132B),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.wali.konten.isNotEmpty
                              ? widget.wali.konten
                              : 'Informasi detail mengenai ${widget.wali.nama} belum tersedia.',
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.6,
                            color: Color(0xFF1C2541),
                          ),
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // 3. TOMBOL KEMBALI
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.black45,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Header Tabel "Kategori - Keterangan"
  Widget _buildTableHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 125,
            child: Text(
              'Kategori',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Keterangan',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Baris Isi Data Tabel
  Widget _buildTableRow(String label, String value, {bool isLast = false}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 125,
                child: Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Color(0xFF0B132B),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  value.isNotEmpty ? value : '-',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!isLast) Divider(color: Colors.grey[200], height: 1),
      ],
    );
  }
}
