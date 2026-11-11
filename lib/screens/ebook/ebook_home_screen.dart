import 'dart:convert';
import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../models/wali_model.dart';
import '../../services/storage_service.dart';
import '../login_screen.dart';
import 'ebook_detail_screen.dart';

class EbookHomeScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggleDarkMode;

  const EbookHomeScreen({
    super.key,
    required this.isDarkMode,
    required this.onToggleDarkMode,
  });

  @override
  State<EbookHomeScreen> createState() => _EbookHomeScreenState();
}

class _EbookHomeScreenState extends State<EbookHomeScreen> {
  List<WaliModel> _filteredWali = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await StorageService.initData();
    if (mounted) {
      setState(() {
        _filteredWali = StorageService.waliList;
        _loading = false;
      });
    }
  }

  void _filter(String q) {
    setState(() {
      _filteredWali = StorageService.waliList
          .where((e) =>
              e.nama.toLowerCase().contains(q.toLowerCase()) ||
              e.wilayah.toLowerCase().contains(q.toLowerCase()))
          .toList();
    });
  }

  Widget _buildCoverImage(WaliModel item, {double? width, double? height}) {
    if (item.gambar.isNotEmpty) {
      // 1. Jika gambar berupa Base64 / Data URI (Web / Upload)
      if (item.gambar.startsWith('data:image')) {
        try {
          final base64Str = item.gambar.split(',').last;
          final bytes = base64Decode(base64Str);
          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(
              bytes,
              width: width,
              height: height,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _buildFallbackCover(item),
            ),
          );
        } catch (_) {}
      }
      // 2. Jika gambar berupa URL HTTP/HTTPS
      else if (item.gambar.startsWith('http')) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            item.gambar,
            width: width,
            height: height,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildFallbackCover(item),
          ),
        );
      }
      // 3. Jika gambar berupa Asset bawaan Flutter
      else if (item.gambar.startsWith('assets/')) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            item.gambar,
            width: width,
            height: height,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildFallbackCover(item),
          ),
        );
      }
      // 4. Jika gambar berasal dari file lokal galeri HP Android
      else {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            File(item.gambar),
            width: width,
            height: height,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildFallbackCover(item),
          ),
        );
      }
    }
    return _buildFallbackCover(item);
  }

  Widget _buildFallbackCover(WaliModel item) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF03045E), Color(0xFF0077B6), Color(0xFF00B4D8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            item.nama,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B132B),
      body: SafeArea(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF48CAE4)))
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // SEARCH HEADER
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1C2541),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: const Color(0xFF3A506B)
                                      .withValues(alpha: 0.5),
                                ),
                              ),
                              child: TextField(
                                onChanged: _filter,
                                style: const TextStyle(color: Colors.white),
                                decoration: const InputDecoration(
                                  hintText: 'Search books',
                                  hintStyle: TextStyle(
                                      color: Colors.white54, fontSize: 14),
                                  prefixIcon: Icon(Icons.search,
                                      color: Color(0xFF48CAE4)),
                                  border: InputBorder.none,
                                  contentPadding:
                                      EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // IKON PROFIL (KLIK UNTUK KEMBALI KE MENU LOGIN)
                          GestureDetector(
                            onTap: () {
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
                            child: Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF0077B6),
                                    Color(0xFF00B4D8)
                                  ],
                                ),
                              ),
                              child: const CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.transparent,
                                child: Icon(Icons.person, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // SECTION RECENT (IKON TOGGLE TEMA TELAH DIHILANGKAN)
                    const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Text(
                        'Recent',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    // LIST HORIZONTAL RECENT
                    SizedBox(
                      height: 110,
                      child: StorageService.recentWali.isEmpty
                          ? const Center(
                              child: Text(
                                'Belum ada riwayat bacaan',
                                style: TextStyle(
                                    color: Colors.white38, fontSize: 13),
                              ),
                            )
                          : ScrollConfiguration(
                              behavior:
                                  ScrollConfiguration.of(context).copyWith(
                                dragDevices: {
                                  PointerDeviceKind.touch,
                                  PointerDeviceKind.mouse,
                                },
                              ),
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: StorageService.recentWali.length,
                                itemBuilder: (context, i) {
                                  final item = StorageService.recentWali[i];
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              EbookDetailScreen(wali: item),
                                        ),
                                      ).then((_) => setState(() {}));
                                    },
                                    child: Container(
                                      width: 240,
                                      margin: const EdgeInsets.only(
                                          right: 12, top: 8, bottom: 8),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF0077B6)
                                                .withValues(alpha: 0.15),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          )
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: 50,
                                            height: 70,
                                            child: _buildCoverImage(item),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  item.nama,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 13,
                                                      color: Color(0xFF0B132B)),
                                                ),
                                                Text(
                                                  'By ${item.wilayah}',
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      fontSize: 11,
                                                      color: Colors.grey[600]),
                                                ),
                                                const SizedBox(height: 8),
                                                LinearProgressIndicator(
                                                  value: 0.85,
                                                  backgroundColor:
                                                      Colors.blue[50],
                                                  color:
                                                      const Color(0xFF00B4D8),
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                    ),

                    const SizedBox(height: 16),

                    // GRID MY BOOKS
                    Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(28)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding:
                                EdgeInsets.only(left: 20, top: 20, bottom: 12),
                            child: Text(
                              'Books List',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0B132B)),
                            ),
                          ),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.only(
                                left: 16, right: 16, bottom: 24),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              childAspectRatio: 0.58,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: _filteredWali.length,
                            itemBuilder: (context, i) {
                              final item = _filteredWali[i];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          EbookDetailScreen(wali: item),
                                    ),
                                  ).then((_) => setState(() {}));
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFF0077B6)
                                                  .withValues(alpha: 0.2),
                                              blurRadius: 6,
                                              offset: const Offset(0, 3),
                                            )
                                          ],
                                        ),
                                        child: _buildCoverImage(item),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      item.nama,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF0B132B)),
                                    ),
                                    Text(
                                      item.wilayah,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
