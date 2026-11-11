import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import 'admin/admin_dashboard_screen.dart';
import 'main_navigation.dart';

class LoginScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggleDarkMode;

  const LoginScreen({
    super.key,
    required this.isDarkMode,
    required this.onToggleDarkMode,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isAdminMode = false;
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);

    try {
      await StorageService.initData();
    } catch (_) {}

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (_isAdminMode) {
      if (_usernameController.text == 'admin' &&
          _passwordController.text == 'admin123') {
        StorageService.isAdmin = true;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => AdminDashboardScreen(
              isDarkMode: widget.isDarkMode,
              onToggleDarkMode: widget.onToggleDarkMode,
            ),
          ),
        );
      } else {
        // PERINGATAN DIREVISI TANPA MENAMPILKAN USERNAME DAN PASSWORD
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Username atau Password salah!'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } else {
      StorageService.isAdmin = false;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MainNavigationScreen(
            isDarkMode: widget.isDarkMode,
            onToggleDarkMode: widget.onToggleDarkMode,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B132B),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF03045E), Color(0xFF00B4D8)],
                    ),
                  ),
                  child: const Icon(Icons.menu_book_rounded,
                      size: 60, color: Colors.white),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Wali Songo EduApp',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Aplikasi Edukasi & Gamifikasi Sejarah',
                  style: TextStyle(color: Colors.white54, fontSize: 13),
                ),
                const SizedBox(height: 32),

                // MODE SELECTOR (SISWA / ADMIN)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ChoiceChip(
                      label: const Text('Siswa / Pengguna'),
                      selected: !_isAdminMode,
                      selectedColor: const Color(0xFF0077B6),
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: !_isAdminMode
                            ? Colors.white
                            : const Color(0xFF0077B6),
                        fontWeight: FontWeight.bold,
                      ),
                      onSelected: (val) => setState(() => _isAdminMode = false),
                    ),
                    const SizedBox(width: 12),
                    ChoiceChip(
                      label: const Text('Admin'),
                      selected: _isAdminMode,
                      selectedColor: const Color(0xFF0077B6),
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: _isAdminMode
                            ? Colors.white
                            : const Color(0xFF0077B6),
                        fontWeight: FontWeight.bold,
                      ),
                      onSelected: (val) => setState(() => _isAdminMode = true),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                if (_isAdminMode) ...[
                  TextField(
                    controller: _usernameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Username Admin',
                      hintStyle: const TextStyle(color: Colors.white38),
                      prefixIcon:
                          const Icon(Icons.person, color: Color(0xFF48CAE4)),
                      filled: true,
                      fillColor: const Color(0xFF1C2541),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Password Admin',
                      hintStyle: const TextStyle(color: Colors.white38),
                      prefixIcon:
                          const Icon(Icons.lock, color: Color(0xFF48CAE4)),
                      filled: true,
                      fillColor: const Color(0xFF1C2541),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00B4D8),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _isLoading ? null : _handleLogin,
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            _isAdminMode
                                ? 'Masuk Dashboard Admin'
                                : 'Mulai Belajar',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
