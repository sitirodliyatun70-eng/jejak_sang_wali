import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/wali_model.dart';
import '../../services/storage_service.dart';
import '../login_screen.dart';
import '../main_navigation.dart';

class AdminDashboardScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggleDarkMode;

  const AdminDashboardScreen({
    super.key,
    required this.isDarkMode,
    required this.onToggleDarkMode,
  });

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  // Picker gambar dari galeri HP / Web
  Future<String?> _pickImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        return 'data:image/jpeg;base64,${Uri.encodeComponent(String.fromCharCodes(bytes))}';
      } else {
        return image.path;
      }
    }
    return null;
  }

  // Widget pembaca gambar otomatis (Network, Asset, atau File Lokal HP)
  Widget _buildImageWidget(String path,
      {double? width, double? height, BoxFit fit = BoxFit.cover}) {
    if (path.isEmpty) return const SizedBox();

    if (path.startsWith('http') || path.startsWith('data:')) {
      return Image.network(
        path,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => const Center(
          child: Text('📷 Gambar Error', style: TextStyle(color: Colors.white)),
        ),
      );
    } else if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => const Center(
          child: Text('📷 Gambar Error', style: TextStyle(color: Colors.white)),
        ),
      );
    } else {
      return Image.file(
        File(path),
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => const Center(
          child: Text('📷 Gambar Error', style: TextStyle(color: Colors.white)),
        ),
      );
    }
  }

  void _showWaliForm({WaliModel? wali}) {
    final namaController = TextEditingController(text: wali?.nama ?? '');
    final wilayahController = TextEditingController(text: wali?.wilayah ?? '');
    final periodeController = TextEditingController(text: wali?.periode ?? '');
    final ringkasanController =
        TextEditingController(text: wali?.ringkasan ?? '');
    final kontenController = TextEditingController(text: wali?.konten ?? '');
    String selectedGambar = wali?.gambar ?? '';

    // Controller Tambahan untuk Tabel Biodata & Silsilah
    final namaLengkapController =
        TextEditingController(text: wali?.namaLengkap ?? '');
    final gelarNamaLainController =
        TextEditingController(text: wali?.gelarNamaLain ?? '');
    final asalUsulKelahiranController =
        TextEditingController(text: wali?.asalUsulKelahiran ?? '');
    final garisKeturunanController =
        TextEditingController(text: wali?.garisKeturunan ?? '');
    final ayahController = TextEditingController(text: wali?.ayah ?? '');
    final pasangIstriController =
        TextEditingController(text: wali?.pasangIstri ?? '');
    final keturunanUtamaController =
        TextEditingController(text: wali?.keturunanUtama ?? '');
    final wafatLokasiMakamController =
        TextEditingController(text: wali?.wafatLokasiMakam ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1C2541),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      wali == null
                          ? '➕ Tambah Informasi Sunan'
                          : '✏️ Edit Informasi Sunan',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    _buildField('Nama Sunan', namaController),
                    _buildField('Wilayah', wilayahController),
                    _buildField('Periode / Abad', periodeController),
                    const Text(
                      'Foto / Gambar Sampul',
                      style: TextStyle(color: Colors.white60, fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () async {
                        final imageData = await _pickImageFromGallery();
                        if (imageData != null) {
                          setModalState(() {
                            selectedGambar = imageData;
                          });
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        height: 110,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0B132B),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF3A506B)),
                        ),
                        child: selectedGambar.isNotEmpty
                            ? Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: _buildImageWidget(
                                      selectedGambar,
                                      width: double.infinity,
                                      height: 110,
                                    ),
                                  ),
                                  Container(
                                    color: Colors.black45,
                                    child: const Center(
                                      child: Text(
                                        'Klik untuk Mengubah Foto',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  )
                                ],
                              )
                            : const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.photo_library,
                                      color: Color(0xFF48CAE4), size: 32),
                                  SizedBox(height: 6),
                                  Text(
                                    'Pilih Foto dari Galeri',
                                    style: TextStyle(
                                        color: Colors.white70, fontSize: 13),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    _buildField('Ringkasan', ringkasanController),
                    const SizedBox(height: 12),
                    const Text(
                      '📋 Data Diri & Silsilah (Tampil di Kotak Tabel)',
                      style: TextStyle(
                        color: Color(0xFF48CAE4),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildField('Nama Lengkap', namaLengkapController),
                    _buildField('Gelar / Nama Lain', gelarNamaLainController),
                    _buildField(
                        'Asal-Usul & Kelahiran', asalUsulKelahiranController),
                    _buildField('Garis Keturunan', garisKeturunanController),
                    _buildField('Ayah', ayahController),
                    _buildField('Pasangan / Istri', pasangIstriController),
                    _buildField('Keturunan Utama', keturunanUtamaController),
                    _buildField(
                        'Wafat & Lokasi Makam', wafatLokasiMakamController),
                    const SizedBox(height: 12),
                    const Text(
                      '📖 Kisah & Sejarah Lengkap (Tampil di Luar Kotak)',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _buildField('Sejarah Lengkap', kontenController,
                        maxLines: 4),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00B4D8),
                        ),
                        onPressed: () async {
                          if (namaController.text.isEmpty) return;
                          final newWali = WaliModel(
                            id: wali?.id ??
                                (StorageService.waliList.length + 1),
                            nama: namaController.text,
                            wilayah: wilayahController.text,
                            periode: periodeController.text,
                            gambar: selectedGambar,
                            ringkasan: ringkasanController.text,
                            konten: kontenController.text,
                            namaLengkap: namaLengkapController.text,
                            gelarNamaLain: gelarNamaLainController.text,
                            asalUsulKelahiran: asalUsulKelahiranController.text,
                            garisKeturunan: garisKeturunanController.text,
                            ayah: ayahController.text,
                            pasangIstri: pasangIstriController.text,
                            keturunanUtama: keturunanUtamaController.text,
                            wafatLokasiMakam: wafatLokasiMakamController.text,
                          );

                          setState(() {
                            if (wali == null) {
                              StorageService.waliList.add(newWali);
                            } else {
                              int idx = StorageService.waliList.indexWhere(
                                  (element) => element.id == wali.id);
                              if (idx != -1) {
                                StorageService.waliList[idx] = newWali;
                              }
                            }
                          });

                          await StorageService.saveData();

                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        },
                        child: const Text('Simpan Data',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildField(String label, TextEditingController controller,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white60),
          filled: true,
          fillColor: const Color(0xFF0B132B),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B132B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B132B),
        title: const Text('Dashboard Admin',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.preview, color: Color(0xFF48CAE4)),
            tooltip: 'Pratinjau Aplikasi Siswa',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MainNavigationScreen(
                    isDarkMode: widget.isDarkMode,
                    onToggleDarkMode: widget.onToggleDarkMode,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: () {
              StorageService.isAdmin = false;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => LoginScreen(
                    isDarkMode: widget.isDarkMode,
                    onToggleDarkMode: widget.onToggleDarkMode,
                  ),
                ),
              );
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF00B4D8),
        onPressed: () => _showWaliForm(),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Tambah Sunan',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: StorageService.waliList.length,
        itemBuilder: (context, i) {
          final item = StorageService.waliList[i];
          return Card(
            color: const Color(0xFF1C2541),
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: const Color(0xFF0077B6),
                ),
                child: item.gambar.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: _buildImageWidget(item.gambar,
                            width: 44, height: 44),
                      )
                    : Center(
                        child: Text('${item.id}',
                            style: const TextStyle(color: Colors.white)),
                      ),
              ),
              title: Text(item.nama,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: Text('${item.wilayah} - ${item.periode}',
                  style: const TextStyle(color: Colors.white60)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Color(0xFF48CAE4)),
                    onPressed: () => _showWaliForm(wali: item),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () async {
                      setState(() {
                        StorageService.waliList.removeAt(i);
                      });
                      await StorageService.saveData();
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
