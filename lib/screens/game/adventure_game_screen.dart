import 'dart:math';
import 'package:flutter/material.dart';

class QuizModel {
  final String sunanNama;
  final String pertanyaan;
  final List<String> pilihan;
  final int jawabanBenar;

  QuizModel({
    required this.sunanNama,
    required this.pertanyaan,
    required this.pilihan,
    required this.jawabanBenar,
  });
}

class AdventureGameScreen extends StatefulWidget {
  final bool isDarkMode;

  const AdventureGameScreen({super.key, required this.isDarkMode});

  @override
  State<AdventureGameScreen> createState() => _AdventureGameScreenState();
}

class _AdventureGameScreenState extends State<AdventureGameScreen>
    with TickerProviderStateMixin {
  late AnimationController _animController;
  late AnimationController _confettiController;
  late AnimationController _pulseController;

  final ScrollController _scrollController = ScrollController();

  int _currentPosIndex = 0;
  int _targetIndex = 0;
  bool _isMoving = false;
  bool _showQuizModal = false;
  bool _showWelcomeScreen = true;
  bool _gameStarted = false;
  bool _showFinishAnimation = false;

  final List<QuizModel> _allQuizzes = generate45Quizzes();

  final double _pointSpacing = 160.0;
  final double _mapHeight = 45 * 160.0 + 350.0;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            _isMoving = false;
            _currentPosIndex = _targetIndex;
            _showQuizModal = false;
          });
        }
      });

    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
      lowerBound: 0.94,
      upperBound: 1.06,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    _confettiController.dispose();
    _pulseController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToPosition(int index) {
    if (!_scrollController.hasClients) return;
    double targetY = _mapHeight - (index * _pointSpacing) - 400;
    if (targetY < 0) targetY = 0;
    if (targetY > _scrollController.position.maxScrollExtent) {
      targetY = _scrollController.position.maxScrollExtent;
    }
    _scrollController.animateTo(
      targetY,
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeInOut,
    );
  }

  void _onWelcomeStartPressed() {
    setState(() {
      _showWelcomeScreen = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  void _onStartPressed() {
    if (_isMoving) return;
    setState(() {
      _gameStarted = true;
      _showQuizModal = true;
    });
  }

  void _startAutomaticWalkToNext() {
    int nextIndex = _currentPosIndex + 1;

    setState(() {
      _targetIndex = nextIndex;
      _isMoving = true;
      _showQuizModal = false;
    });

    _scrollToPosition(nextIndex);
    _animController.forward(from: 0.0);
  }

  void _onSpotTapped(int index) {
    if (_isMoving) return;

    if (index == _currentPosIndex && !_showQuizModal) {
      setState(() {
        _showQuizModal = true;
      });
    }
  }

  void _answerQuestion(int selectedIndex) {
    final currentQuiz = _allQuizzes[_currentPosIndex];
    if (selectedIndex == currentQuiz.jawabanBenar) {
      setState(() {
        _showQuizModal = false;
      });

      if (_currentPosIndex >= _allQuizzes.length - 1) {
        setState(() {
          _showFinishAnimation = true;
        });
        _scrollToPosition(_allQuizzes.length - 1);
        _showVictoryDialog();
      } else {
        _startAutomaticWalkToNext();
      }
    } else {
      setState(() {
        _showQuizModal = false;
      });
      _showGameOverDialog();
    }
  }

  void _restartGame() {
    setState(() {
      _currentPosIndex = 0;
      _targetIndex = 0;
      _isMoving = false;
      _showQuizModal = false;
      _gameStarted = false;
      _showWelcomeScreen = true;
      _showFinishAnimation = false;
    });
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Text('❌ ', style: TextStyle(fontSize: 22)),
            Text(
              'Jawaban Salah!',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        content: const Text(
          'Jawaban kamu kurang tepat. Kamu harus mengulang petualangan dari awal!',
          style: TextStyle(color: Colors.black87, fontSize: 14),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: () {
              Navigator.pop(context);
              _restartGame();
            },
            child: const Text('Ulangi Dari Awal',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  void _showVictoryDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Text('🏆 ', style: TextStyle(fontSize: 26)),
            Text(
              'FINISH & SELAMAT!',
              style: TextStyle(
                color: Color(0xFFE65100),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: const Text(
          'Luar biasa! Kamu telah menuntaskan seluruh 45 kuis petualangan Wali Songo sampai garis FINISH! 🎉',
          style: TextStyle(color: Colors.black87, fontSize: 14),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: () {
              Navigator.pop(context);
              _restartGame();
            },
            child: const Text('Main Lagi',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  Offset _getPointCoordinates(int index, double screenWidth) {
    double y = _mapHeight - (index * _pointSpacing) - 200;
    double x = (index % 2 == 0) ? screenWidth * 0.30 : screenWidth * 0.70;
    return Offset(x, y);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDark = widget.isDarkMode;

    if (_showWelcomeScreen) {
      return Scaffold(
        body: _buildPixelWelcomeScreen(context),
      );
    }

    final bgColor = isDark ? const Color(0xFF0B132B) : const Color(0xFF55B947);

    Offset startPos = _getPointCoordinates(_currentPosIndex, screenWidth);
    Offset endPos = _getPointCoordinates(_targetIndex, screenWidth);

    Offset finishPointOffset = _getPointCoordinates(44, screenWidth);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          'ROAD MAP PETUALANGAN (${_currentPosIndex + 1}/45)',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        backgroundColor:
            isDark ? const Color(0xFF1C2541) : const Color(0xFF388E3C),
        elevation: 2,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            child: SizedBox(
              height: _mapHeight,
              width: screenWidth,
              child: Stack(
                children: [
                  CustomPaint(
                    size: Size(screenWidth, _mapHeight),
                    painter: PixelRoadPainter(
                      totalPoints: 45,
                      spacing: _pointSpacing,
                      mapHeight: _mapHeight,
                      isDarkMode: isDark,
                    ),
                  ),

                  // Pohon Pixel Art 8-Bit
                  for (int i = 0; i < 40; i++) ...[
                    Positioned(
                      left: (i % 2 == 0)
                          ? screenWidth * 0.08
                          : screenWidth * 0.82,
                      top: _mapHeight - (i * 180.0) - 100,
                      child: Column(
                        children: [
                          SizedBox(
                            width: 36,
                            height: 48,
                            child: CustomPaint(
                              painter: PixelTreePainter(isDark: isDark),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Icon(Icons.local_florist,
                              size: 16, color: Colors.yellow[600]),
                        ],
                      ),
                    ),
                  ],

                  // Header Banner "ROAD MAP"
                  Positioned(
                    top: 30,
                    left: 20,
                    right: 20,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE65100),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: const [
                            BoxShadow(color: Colors.black45, blurRadius: 6)
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.map, color: Colors.white, size: 28),
                            SizedBox(width: 8),
                            Text(
                              'ROAD MAP',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // GARIS FINISH
                  Positioned(
                    left: finishPointOffset.dx - 60,
                    top: finishPointOffset.dy - 110,
                    child: Column(
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.emoji_events,
                                color: Colors.amber, size: 36),
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD32F2F),
                                borderRadius: BorderRadius.circular(12),
                                border:
                                    Border.all(color: Colors.white, width: 3),
                                boxShadow: const [
                                  BoxShadow(
                                      color: Colors.black38, blurRadius: 4)
                                ],
                              ),
                              child: const Text(
                                'FINISH 🏁',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // ANIMASI SELEBRASI BINTANG KILAU
                  if (_showFinishAnimation)
                    AnimatedBuilder(
                      animation: _confettiController,
                      builder: (context, child) {
                        double value = _confettiController.value;
                        return Positioned(
                          left: finishPointOffset.dx - 100,
                          top: finishPointOffset.dy - 160,
                          child: SizedBox(
                            width: 200,
                            height: 120,
                            child: Stack(
                              children: [
                                Positioned(
                                  top: 10 + (value * 15),
                                  left: 20,
                                  child: const Icon(Icons.star,
                                      color: Colors.amberAccent, size: 28),
                                ),
                                Positioned(
                                  top: 30 - (value * 15),
                                  right: 20,
                                  child: const Icon(Icons.star,
                                      color: Colors.yellow, size: 32),
                                ),
                                Positioned(
                                  bottom: 10 + (value * 10),
                                  left: 80,
                                  child: const Icon(Icons.auto_awesome,
                                      color: Colors.white, size: 30),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                  // START BANNER DI BAGIAN BAWAH PETA
                  Positioned(
                    bottom: 30,
                    left: screenWidth * 0.15,
                    child: GestureDetector(
                      onTap: _onStartPressed,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 10),
                        decoration: BoxDecoration(
                          color: _gameStarted
                              ? Colors.grey[700]
                              : const Color(0xFF2E7D32),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: const [
                            BoxShadow(
                                color: Colors.black38,
                                blurRadius: 4,
                                offset: Offset(0, 2))
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(_gameStarted ? Icons.check : Icons.play_arrow,
                                color: Colors.white),
                            const SizedBox(width: 6),
                            Text(
                              _gameStarted ? 'STARTED' : 'START',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Kotak Putih & Pin Kuis (1 - 45)
                  for (int i = 0; i < 45; i++) ...[
                    Builder(builder: (context) {
                      Offset pointOffset = _getPointCoordinates(i, screenWidth);
                      bool isPassed = i < _currentPosIndex;
                      bool isCurrent = i == _currentPosIndex;
                      bool isLeft = (i % 2 == 0);

                      return Positioned(
                        left:
                            isLeft ? pointOffset.dx - 10 : pointOffset.dx - 130,
                        top: pointOffset.dy - 35,
                        child: GestureDetector(
                          onTap: () => _onSpotTapped(i),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (!isLeft) ...[
                                Container(
                                  width: 100,
                                  height: 55,
                                  decoration: BoxDecoration(
                                    color: isCurrent
                                        ? const Color(0xFFFFF3CD)
                                        : (isPassed
                                            ? Colors.green[100]
                                            : Colors.white),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isCurrent
                                          ? Colors.amber[800]!
                                          : (isPassed
                                              ? Colors.green[700]!
                                              : Colors.grey[700]!),
                                      width: 3,
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 4,
                                          offset: Offset(0, 2))
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      isPassed
                                          ? '✓ Lulus'
                                          : (isCurrent
                                              ? 'Tekan Kuis'
                                              : 'Terkunci'),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: isCurrent
                                            ? Colors.amber[900]
                                            : (isPassed
                                                ? Colors.green[900]
                                                : Colors.grey[800]),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
                              Column(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    size: 36,
                                    color: isPassed
                                        ? Colors.green
                                        : (isCurrent
                                            ? Colors.redAccent
                                            : Colors.grey[400]),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: isCurrent
                                          ? Colors.amber
                                          : Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: Colors.black, width: 2),
                                    ),
                                    child: Text(
                                      '${i + 1}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (isLeft) ...[
                                const SizedBox(width: 8),
                                Container(
                                  width: 100,
                                  height: 55,
                                  decoration: BoxDecoration(
                                    color: isCurrent
                                        ? const Color(0xFFFFF3CD)
                                        : (isPassed
                                            ? Colors.green[100]
                                            : Colors.white),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isCurrent
                                          ? Colors.amber[800]!
                                          : (isPassed
                                              ? Colors.green[700]!
                                              : Colors.grey[700]!),
                                      width: 3,
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 4,
                                          offset: Offset(0, 2))
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      isPassed
                                          ? '✓ Lulus'
                                          : (isCurrent
                                              ? 'Tekan Kuis'
                                              : 'Terkunci'),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: isCurrent
                                            ? Colors.amber[900]
                                            : (isPassed
                                                ? Colors.green[900]
                                                : Colors.grey[800]),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    }),
                  ],

                  // KARAKTER PIXEL ANIMASI JALAN
                  AnimatedBuilder(
                    animation: _animController,
                    builder: (context, child) {
                      double progress = _animController.value;

                      double currentX =
                          startPos.dx + (endPos.dx - startPos.dx) * progress;
                      double currentY =
                          startPos.dy + (endPos.dy - startPos.dy) * progress;

                      double bounceY = _isMoving
                          ? (sin(progress * pi * 12).abs() * 6.0)
                          : 0.0;
                      int walkFrame =
                          _isMoving ? ((progress * 16).floor() % 2 + 1) : 0;

                      return Positioned(
                        left: currentX - 18,
                        top: (currentY - 55) - bounceY,
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _isMoving ? '🏃 Jalan...' : '🧍 Disini',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 9),
                              ),
                            ),
                            const SizedBox(height: 2),
                            SizedBox(
                              width: 36,
                              height: 44,
                              child: CustomPaint(
                                painter: AnimatedPixelCharacterPainter(
                                  walkFrame: walkFrame,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // DIALOG SOAL KUIS
          if (_showQuizModal &&
              !_isMoving &&
              _currentPosIndex < _allQuizzes.length)
            Positioned(
              bottom: 20,
              left: 16,
              right: 16,
              child: _buildQuizCard(_allQuizzes[_currentPosIndex]),
            ),
        ],
      ),
    );
  }

  // WIDGET WELCOME SCREEN RETRO PIXEL ART
  Widget _buildPixelWelcomeScreen(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFF87CEEB),
      child: Stack(
        children: [
          // AWAN-AWAN PIXEL UKURAN BESAR DENGAN SKALA LEBIH MANTAP
          Positioned(
            top: 25,
            left: -10,
            child: SizedBox(
              width: 150,
              height: 75,
              child: CustomPaint(painter: PixelCloudPainter()),
            ),
          ),
          Positioned(
            top: 80,
            right: -15,
            child: SizedBox(
              width: 180,
              height: 90,
              child: CustomPaint(painter: PixelCloudPainter()),
            ),
          ),
          Positioned(
            top: 170,
            left: screenWidth * 0.25,
            child: SizedBox(
              width: 130,
              height: 65,
              child: CustomPaint(painter: PixelCloudPainter()),
            ),
          ),
          Positioned(
            top: 260,
            left: -20,
            child: SizedBox(
              width: 140,
              height: 70,
              child: CustomPaint(painter: PixelCloudPainter()),
            ),
          ),
          Positioned(
            top: 290,
            right: -10,
            child: SizedBox(
              width: 150,
              height: 75,
              child: CustomPaint(painter: PixelCloudPainter()),
            ),
          ),

          // POHON-POHON PIXEL ART DI ATAS RUMPUT
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      width: 50,
                      height: 65,
                      child:
                          CustomPaint(painter: PixelTreePainter(isDark: false)),
                    ),
                    SizedBox(
                      width: 44,
                      height: 58,
                      child:
                          CustomPaint(painter: PixelTreePainter(isDark: false)),
                    ),
                    SizedBox(
                      width: 56,
                      height: 72,
                      child:
                          CustomPaint(painter: PixelTreePainter(isDark: false)),
                    ),
                    SizedBox(
                      width: 48,
                      height: 60,
                      child:
                          CustomPaint(painter: PixelTreePainter(isDark: false)),
                    ),
                  ],
                ),
                Container(
                  height: 60,
                  width: double.infinity,
                  color: const Color(0xFF55B947),
                ),
                Container(
                  height: 20,
                  width: double.infinity,
                  color: const Color(0xFF8B4513),
                ),
              ],
            ),
          ),

          // KONTEN UTAMA TENGAH
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // HATI PIXEL RED HEARTS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      5,
                      (index) => const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.0),
                        child: Icon(
                          Icons.favorite,
                          color: Color(0xFFE53935),
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // BANNER WELCOME! KUNING PIXEL ART RETRO
                  SizedBox(
                    width: 280,
                    height: 75,
                    child: CustomPaint(
                      painter: RetroPixelWelcomeBannerPainter(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // SUBTITLE DESKRIPSI KUIS TERBARU
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black, width: 2),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        )
                      ],
                    ),
                    child: const Text(
                      'Ayo uji pemahaman mu setelah membaca sejarah hidup wali songo dengan memulai petualangan 45 kuis',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1C2541),
                        height: 1.3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),

                  // TOMBOL START TERPUSAT (CENTER) & BERDETAK (PULSE)
                  ScaleTransition(
                    scale: _pulseController,
                    child: GestureDetector(
                      onTap: _onWelcomeStartPressed,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E7D32),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white, width: 3.5),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black45,
                              blurRadius: 0,
                              offset: Offset(4, 5),
                            ),
                          ],
                        ),
                        child: const Text(
                          'START',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 3,
                            shadows: [
                              Shadow(
                                blurRadius: 0,
                                color: Colors.black,
                                offset: Offset(2, 2),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizCard(QuizModel quiz) {
    return Card(
      color: Colors.white,
      elevation: 12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFF2E7D32), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Wali Songo: ${quiz.sunanNama}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                Text(
                  'Soal ${_currentPosIndex + 1}/45',
                  style: const TextStyle(
                    color: Color(0xFFE65100),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              quiz.pertanyaan,
              style: const TextStyle(
                color: Color(0xFF1C2541),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),
            ...List.generate(
              quiz.pilihan.length,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF0F4F8),
                      foregroundColor: const Color(0xFF1C2541),
                      elevation: 0,
                      side: const BorderSide(
                          color: Color(0xFFCBD5E1), width: 1.5),
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => _answerQuestion(index),
                    child: Text(
                      '${String.fromCharCode(65 + index)}. ${quiz.pilihan[index]}',
                      style: const TextStyle(
                        color: Color(0xFF1C2541),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// PAINTER AWAN PIXEL ART 8-BIT
class PixelCloudPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final pixelSize = size.width / 14;
    void drawPixel(int x, int y, Color color) {
      final paint = Paint()..color = color;
      canvas.drawRect(
        Rect.fromLTWH(x * pixelSize, y * pixelSize, pixelSize, pixelSize),
        paint,
      );
    }

    const cCloud = Colors.white;
    const cShadow = Color(0xFFE0E0E0);

    for (int x = 4; x <= 9; x++) drawPixel(x, 0, cCloud);
    for (int x = 3; x <= 10; x++) drawPixel(x, 1, cCloud);
    for (int x = 2; x <= 11; x++) drawPixel(x, 2, cCloud);
    for (int x = 1; x <= 12; x++) drawPixel(x, 3, cCloud);
    for (int x = 0; x <= 13; x++) drawPixel(x, 4, cCloud);
    for (int x = 0; x <= 13; x++) drawPixel(x, 5, cShadow);
    for (int x = 1; x <= 12; x++) drawPixel(x, 6, cShadow);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// PAINTER BANNER KUNING + TEKS "WELCOME!" BERGAYA RETRO PIXEL ART
class RetroPixelWelcomeBannerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final pixelSize = size.height / 14;

    // 1. Gambar Pixel Shadow Hitam 3D
    final shadowOffset = 6.0;
    _drawPixelBox(
      canvas,
      shadowOffset,
      shadowOffset,
      size.width,
      size.height,
      pixelSize,
      Colors.black,
    );

    // 2. Gambar Border Hitam Pixel Utama
    _drawPixelBox(
      canvas,
      0,
      0,
      size.width,
      size.height,
      pixelSize,
      Colors.black,
    );

    // 3. Isi Kuning Pixel
    _drawPixelBox(
      canvas,
      pixelSize,
      pixelSize,
      size.width - (pixelSize * 2),
      size.height - (pixelSize * 2),
      pixelSize,
      const Color(0xFFFFB703),
    );

    // 4. Render Teks Pixel "WELCOME!"
    const textStyle = TextStyle(
      color: Colors.white,
      fontSize: 28,
      fontWeight: FontWeight.w900,
      letterSpacing: 2,
      fontFamily: 'monospace',
      shadows: [
        Shadow(blurRadius: 0, color: Colors.black, offset: Offset(3, 3))
      ],
    );

    final textSpan = TextSpan(text: 'WELCOME!', style: textStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    final xCenter = (size.width - textPainter.width) / 2;
    final yCenter = (size.height - textPainter.height) / 2;
    textPainter.paint(canvas, Offset(xCenter, yCenter));
  }

  void _drawPixelBox(
    Canvas canvas,
    double offsetX,
    double offsetY,
    double width,
    double height,
    double px,
    Color color,
  ) {
    final paint = Paint()..color = color;

    canvas.drawRect(
      Rect.fromLTWH(
        offsetX + px,
        offsetY,
        width - (px * 2),
        height,
      ),
      paint,
    );

    canvas.drawRect(
      Rect.fromLTWH(
        offsetX,
        offsetY + px,
        width,
        height - (px * 2),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// PAINTER POHON PIXEL ART 8-BIT
class PixelTreePainter extends CustomPainter {
  final bool isDark;

  PixelTreePainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final pixelSize = size.width / 10;

    void drawPixel(int x, int y, Color color) {
      final paint = Paint()..color = color;
      canvas.drawRect(
        Rect.fromLTWH(x * pixelSize, y * pixelSize, pixelSize, pixelSize),
        paint,
      );
    }

    final cLeavesLight =
        isDark ? const Color(0xFF1B4332) : const Color(0xFF2D6A4F);
    final cLeavesDark =
        isDark ? const Color(0xFF081C15) : const Color(0xFF1B4332);
    const cTrunk = Color(0xFF4A2E12);

    for (int x = 4; x <= 5; x++) drawPixel(x, 0, cLeavesLight);
    for (int x = 3; x <= 6; x++) drawPixel(x, 1, cLeavesLight);
    for (int x = 2; x <= 7; x++) drawPixel(x, 2, cLeavesDark);

    for (int x = 3; x <= 6; x++) drawPixel(x, 3, cLeavesLight);
    for (int x = 2; x <= 7; x++) drawPixel(x, 4, cLeavesLight);
    for (int x = 1; x <= 8; x++) drawPixel(x, 5, cLeavesDark);

    for (int x = 2; x <= 7; x++) drawPixel(x, 6, cLeavesLight);
    for (int x = 1; x <= 8; x++) drawPixel(x, 7, cLeavesLight);
    for (int x = 0; x <= 9; x++) drawPixel(x, 8, cLeavesDark);

    for (int y = 9; y <= 11; y++) {
      drawPixel(4, y, cTrunk);
      drawPixel(5, y, cTrunk);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// PAINTER KARAKTER PIXEL ART 8-BIT
class AnimatedPixelCharacterPainter extends CustomPainter {
  final int walkFrame;

  AnimatedPixelCharacterPainter({required this.walkFrame});

  @override
  void paint(Canvas canvas, Size size) {
    final pixelSize = size.width / 10;

    void drawPixel(int x, int y, Color color) {
      final paint = Paint()..color = color;
      canvas.drawRect(
        Rect.fromLTWH(x * pixelSize, y * pixelSize, pixelSize, pixelSize),
        paint,
      );
    }

    const cCap = Color(0xFFD32F2F);
    const cSkin = Color(0xFFFFCC80);
    const cShirt = Color(0xFF1976D2);
    const cBelt = Color(0xFFFFD54F);
    const cShoes = Color(0xFF5D4037);
    const cHair = Color(0xFF3E2723);

    for (int x = 2; x <= 7; x++) drawPixel(x, 0, cCap);
    for (int x = 1; x <= 8; x++) drawPixel(x, 1, cCap);
    for (int x = 1; x <= 9; x++) drawPixel(x, 2, cCap);

    drawPixel(1, 3, cHair);
    for (int x = 2; x <= 7; x++) drawPixel(x, 3, cSkin);
    drawPixel(8, 3, cHair);
    drawPixel(3, 4, Colors.black);
    drawPixel(6, 4, Colors.black);
    for (int x = 2; x <= 7; x++) drawPixel(x, 4, cSkin);

    if (walkFrame == 1) {
      for (int x = 1; x <= 6; x++) drawPixel(x, 5, cShirt);
      drawPixel(0, 6, cSkin);
    } else if (walkFrame == 2) {
      for (int x = 3; x <= 8; x++) drawPixel(x, 5, cShirt);
      drawPixel(9, 6, cSkin);
    } else {
      for (int x = 2; x <= 7; x++) drawPixel(x, 5, cShirt);
    }

    for (int x = 1; x <= 8; x++) drawPixel(x, 6, cShirt);
    for (int x = 2; x <= 7; x++) drawPixel(x, 7, cShirt);

    for (int x = 3; x <= 6; x++) drawPixel(x, 8, cBelt);
    for (int x = 2; x <= 7; x++) drawPixel(x, 9, cShirt);

    if (walkFrame == 1) {
      drawPixel(1, 10, cShoes);
      drawPixel(2, 10, cShoes);
      drawPixel(6, 10, cShoes);
    } else if (walkFrame == 2) {
      drawPixel(3, 10, cShoes);
      drawPixel(7, 10, cShoes);
      drawPixel(8, 10, cShoes);
    } else {
      drawPixel(2, 10, cShoes);
      drawPixel(3, 10, cShoes);
      drawPixel(6, 10, cShoes);
      drawPixel(7, 10, cShoes);
    }
  }

  @override
  bool shouldRepaint(covariant AnimatedPixelCharacterPainter oldDelegate) {
    return oldDelegate.walkFrame != walkFrame;
  }
}

class PixelRoadPainter extends CustomPainter {
  final int totalPoints;
  final double spacing;
  final double mapHeight;
  final bool isDarkMode;

  PixelRoadPainter({
    required this.totalPoints,
    required this.spacing,
    required this.mapHeight,
    required this.isDarkMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = isDarkMode ? const Color(0xFF2B2D42) : const Color(0xFF424242)
      ..strokeWidth = 55
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final centerLinePaint = Paint()
      ..color = Colors.white70
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    Path path = Path();
    double startY = mapHeight - 200;
    double startX = size.width * 0.30;
    path.moveTo(startX, startY);

    for (int i = 1; i < totalPoints; i++) {
      double endY = mapHeight - (i * spacing) - 200;
      double endX = (i % 2 == 0) ? size.width * 0.30 : size.width * 0.70;
      double controlY = (startY + endY) / 2;

      path.cubicTo(startX, controlY, endX, controlY, endX, endY);
      startX = endX;
      startY = endY;
    }

    canvas.drawPath(path, roadPaint);
    canvas.drawPath(path, centerLinePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// 45 SOAL KUIS WALI SONGO DARI PDF
List<QuizModel> generate45Quizzes() {
  return [
    QuizModel(
      sunanNama: 'Sunan Gresik',
      pertanyaan:
          'Siapakah nama asli dari Sunan Gresik yang dianggap sebagai Wali Songo tertua?',
      pilihan: [
        'Syekh Maulana Malik Ibrahim',
        'Raden Rahmat',
        'Raden Paku',
        'Syarif Hidayatullah'
      ],
      jawabanBenar: 0,
    ),
    QuizModel(
      sunanNama: 'Sunan Gresik',
      pertanyaan:
          'Metode awal yang digunakan Sunan Gresik saat pertama kali berdakwah di tengah masyarakat Gresik adalah melalui...',
      pilihan: [
        'Kesenian wayang kulit',
        'Perdagangan dan pengobatan gratis',
        'Peperangan dan ekspansi militer',
        'Penulisan kitab suluk'
      ],
      jawabanBenar: 1,
    ),
    QuizModel(
      sunanNama: 'Sunan Gresik',
      pertanyaan:
          'Kota tempat peristirahatan terakhir (makam) dari Sunan Gresik berada di daerah...',
      pilihan: [
        'Ampel, Surabaya',
        'Gapura Sukolilo, Gresik',
        'Kadilangu, Demak',
        'Gunung Sembung, Cirebon'
      ],
      jawabanBenar: 1,
    ),
    QuizModel(
      sunanNama: 'Sunan Gresik',
      pertanyaan:
          'Berdasarkan tulisan pada batu nisan makam beliau, Sunan Gresik wafat pada tahun...',
      pilihan: ['1419 M', '1478 M', '1500 M', '1550 M'],
      jawabanBenar: 0,
    ),
    QuizModel(
      sunanNama: 'Sunan Gresik',
      pertanyaan:
          'Sikap keteladanan utama Sunan Gresik dalam berinteraksi dengan masyarakat kasta rendah saat itu adalah...',
      pilihan: [
        'Menjauhi rakyat jelata',
        'Merakyat dan tidak membeda-bedakan kasta',
        'Mengharuskan upeti',
        'Membangun istana megah'
      ],
      jawabanBenar: 1,
    ),
    QuizModel(
      sunanNama: 'Sunan Ampel',
      pertanyaan: 'Nama asli dari tokoh Sunan Ampel adalah...',
      pilihan: ['Raden Said', 'Raden Rahmat', 'Raden Qasim', 'Raden Makhdum'],
      jawabanBenar: 1,
    ),
    QuizModel(
      sunanNama: 'Sunan Ampel',
      pertanyaan:
          'Falsafah ajaran dakwah terkenal Sunan Ampel untuk mengentaskan kemerosotan moral masyarakat disebut...',
      pilihan: [
        'Falsafah Mo Limo',
        'Tembung Nem',
        'Serat Centhini',
        'Panca Sila'
      ],
      jawabanBenar: 0,
    ),
    QuizModel(
      sunanNama: 'Sunan Ampel',
      pertanyaan:
          'Pusat pondok pesantren yang didirikan oleh Sunan Ampel berlokasi di daerah...',
      pilihan: ['Tuban', 'Ampeldenta, Surabaya', 'Giri, Gresik', 'Kudus'],
      jawabanBenar: 1,
    ),
    QuizModel(
      sunanNama: 'Sunan Ampel',
      pertanyaan:
          'Salah satu pendiri Kesultanan Demak yang merupakan pendiri sekaligus murid utama Sunan Ampel adalah...',
      pilihan: ['Sultan Trenggana', 'Raden Patah', 'Pati Unus', 'Sultan Agung'],
      jawabanBenar: 1,
    ),
    QuizModel(
      sunanNama: 'Sunan Ampel',
      pertanyaan:
          'Dalam falsafah "Moh Limo", larangan "Moh Madat" bermakna tidak mau...',
      pilihan: [
        'Mencuri',
        'Berjudi',
        'Mengonsumsi obat-obatan/candu',
        'Berzina'
      ],
      jawabanBenar: 2,
    ),
    QuizModel(
      sunanNama: 'Sunan Bonang',
      pertanyaan:
          'Sunan Bonang merupakan putra dari anggota Wali Songo lainnya, yaitu...',
      pilihan: ['Sunan Gresik', 'Sunan Ampel', 'Sunan Giri', 'Sunan Kalijaga'],
      jawabanBenar: 1,
    ),
    QuizModel(
      sunanNama: 'Sunan Bonang',
      pertanyaan: 'Nama asli dari Sunan Bonang adalah...',
      pilihan: [
        'Raden Makhdum Ibrahim',
        'Raden Umar Said',
        'Ja\'far Shadiq',
        'Syarif Hidayatullah'
      ],
      jawabanBenar: 0,
    ),
    QuizModel(
      sunanNama: 'Sunan Bonang',
      pertanyaan:
          'Instrumen musik gamelan yang dikreasikan dan dimanfaatkan Sunan Bonang sebagai sarana dakwah adalah...',
      pilihan: ['Kendang', 'Bonang', 'Gong', 'Siter'],
      jawabanBenar: 1,
    ),
    QuizModel(
      sunanNama: 'Sunan Bonang',
      pertanyaan:
          'Salah satu karya tembang spiritual Jawa yang populer diciptakan oleh Sunan Bonang adalah...',
      pilihan: [
        'Lir-Ilir',
        'Tombo Ati',
        'Cublak-Cublak Suweng',
        'Gundul Pacul'
      ],
      jawabanBenar: 1,
    ),
    QuizModel(
      sunanNama: 'Sunan Bonang',
      pertanyaan:
          'Pusat dakwah utama dan lokasi makam dari Sunan Bonang terletak di kota...',
      pilihan: ['Tuban, Jawa Timur', 'Cirebon', 'Demak', 'Jepara'],
      jawabanBenar: 0,
    ),
    QuizModel(
      sunanNama: 'Sunan Drajat',
      pertanyaan:
          'Sunan Drajat merupakan saudara kandung dari tokoh Wali Songo, yaitu...',
      pilihan: ['Sunan Giri', 'Sunan Bonang', 'Sunan Kalijaga', 'Sunan Kudus'],
      jawabanBenar: 1,
    ),
    QuizModel(
      sunanNama: 'Sunan Drajat',
      pertanyaan:
          'Fokus utama dan ajaran khas dari dakwah Sunan Drajat sangat menonjol di bidang...',
      pilihan: [
        'Keprajuritan dan perang',
        'Sosial kemasyarakatan dan kepedulian fakir miskin',
        'Politik istana',
        'Perdagangan maritim'
      ],
      jawabanBenar: 1,
    ),
    QuizModel(
      sunanNama: 'Sunan Drajat',
      pertanyaan: 'Nama asli dari Sunan Drajat adalah...',
      pilihan: ['Raden Qasim', 'Raden Said', 'Raden Paku', 'Raden Umar'],
      jawabanBenar: 0,
    ),
    QuizModel(
      sunanNama: 'Sunan Drajat',
      pertanyaan:
          'Filosofi ajaran Sunan Drajat "Wenehana mangan marang wong kang luwe" memiliki makna...',
      pilihan: [
        'Berilah pakaian kepada orang telanjang',
        'Berilah makan kepada orang yang kelaparan',
        'Berilah payung kepada orang kehujanan',
        'Berilah tongkat kepada orang buta'
      ],
      jawabanBenar: 1,
    ),
    QuizModel(
      sunanNama: 'Sunan Drajat',
      pertanyaan:
          'Kompleks pemakaman dan museum peninggalan Sunan Drajat terletak di Kabupaten...',
      pilihan: ['Gresik', 'Lamongan', 'Kudus', 'Demak'],
      jawabanBenar: 1,
    ),
    QuizModel(
      sunanNama: 'Sunan Giri',
      pertanyaan: 'Nama kecil / nama asli dari Sunan Giri adalah...',
      pilihan: [
        'Raden Said',
        'Raden Paku / Prabu Satmata',
        'Raden Rahmat',
        'Syarif Hidayatullah'
      ],
      jawabanBenar: 1,
    ),
    QuizModel(
      sunanNama: 'Sunan Giri',
      pertanyaan:
          'Kerajaan pesantren yang didirikan oleh Sunan Giri yang pengaruh politiknya mencapai Nusa Tenggara & Maluku adalah...',
      pilihan: ['Demak Bintoro', 'Giri Kedaton', 'Mataram Islam', 'Pajang'],
      jawabanBenar: 1,
    ),
    QuizModel(
      sunanNama: 'Sunan Giri',
      pertanyaan:
          'Permainan tradisional dan tembang anak-anak yang diciptakan oleh Sunan Giri sebagai media dakwah adalah...',
      pilihan: [
        'Cublak-Cublak Suweng dan Jelungan',
        'Engklek dan Kelereng',
        'Jamuran dan Congklak',
        'Pok Ame-Ame'
      ],
      jawabanBenar: 0,
    ),
    QuizModel(
      sunanNama: 'Sunan Giri',
      pertanyaan:
          'Ayah dari Sunan Giri yang merupakan seorang ulama pendakwah dari Pasai adalah...',
      pilihan: [
        'Syekh Maulana Malik Ibrahim',
        'Syekh Maulana Ishaq',
        'Syekh Datuk Kahfi',
        'Syekh Siti Jenar'
      ],
      jawabanBenar: 1,
    ),
    QuizModel(
      sunanNama: 'Sunan Giri',
      pertanyaan:
          'Julukan "Joko Samudro" diberikan kepada Sunan Giri sewaktu kecil karena...',
      pilihan: [
        'Suka berenang di laut',
        'Ditemukan hanyut di laut oleh awak kapal',
        'Menjadi nakhoda kapal dagang',
        'Lahir di tengah laut'
      ],
      jawabanBenar: 1,
    ),
    QuizModel(
      sunanNama: 'Sunan Kalijaga',
      pertanyaan: 'Nama asli dari Sunan Kalijaga adalah...',
      pilihan: ['Raden Said', 'Raden Umar', 'Raden Qasim', 'Raden Patah'],
      jawabanBenar: 0,
    ),
    QuizModel(
      sunanNama: 'Sunan Kalijaga',
      pertanyaan:
          'Kesenian rakyat tradisional Jawa yang dimodifikasi oleh Sunan Kalijaga dengan menyisipkan nilai Islam adalah...',
      pilihan: ['Ludruk', 'Wayang Kulit', 'Reog', 'Ketoprak'],
      jawabanBenar: 1,
    ),
    QuizModel(
      sunanNama: 'Sunan Kalijaga',
      pertanyaan:
          'Tembang spiritual ciptaan Sunan Kalijaga yang mengandung kiasan mendalam tentang keimanan adalah...',
      pilihan: [
        'Tombo Ati',
        'Lir-Ilir',
        'Gundul Pacul',
        'Cublak-Cublak Suweng'
      ],
      jawabanBenar: 1,
    ),
    QuizModel(
      sunanNama: 'Sunan Kalijaga',
      pertanyaan:
          'Guru utama yang memberikan petuah dan ujian kesabaran bertapa di tepi sungai kepada Sunan Kalijaga adalah...',
      pilihan: ['Sunan Ampel', 'Sunan Bonang', 'Sunan Giri', 'Sunan Drajat'],
      jawabanBenar: 1,
    ),
    QuizModel(
      sunanNama: 'Sunan Kalijaga',
      pertanyaan: 'Lokasi makam Sunan Kalijaga berada di wilayah...',
      pilihan: ['Kadilangu, Demak', 'Muria, Kudus', 'Ampel, Surabaya', 'Tuban'],
      jawabanBenar: 0,
    ),
    QuizModel(
      sunanNama: 'Sunan Kudus',
      pertanyaan: 'Nama asli dari tokoh Sunan Kudus adalah...',
      pilihan: [
        'Ja\'far Shadiq',
        'Raden Umar Said',
        'Syarif Hidayatullah',
        'Raden Makhdum'
      ],
      jawabanBenar: 0,
    ),
    QuizModel(
      sunanNama: 'Sunan Kudus',
      pertanyaan:
          'Wujud toleransi tinggi Sunan Kudus terhadap masyarakat pemeluk agama Hindu di Kudus diwujudkan dengan...',
      pilihan: [
        'Melarang menyembelih sapi saat Idul Adha',
        'Melarang pembangunan masjid',
        'Menggunakan bahasa Sansekerta',
        'Mengadakan festival tari'
      ],
      jawabanBenar: 0,
    ),
    QuizModel(
      sunanNama: 'Sunan Kudus',
      pertanyaan:
          'Bangunan ikonik Masjid Menara Kudus memiliki gaya arsitektur yang memadukan kebudayaan...',
      pilihan: [
        'Islam dan Eropa',
        'Islam dan Hindu-Buddha',
        'Islam dan Tiongkok',
        'Islam dan Yunani'
      ],
      jawabanBenar: 1,
    ),
    QuizModel(
      sunanNama: 'Sunan Kudus',
      pertanyaan:
          'Dalam struktur tata pemerintahan Kesultanan Demak, Sunan Kudus memegang peran penting sebagai...',
      pilihan: [
        'Bendahara kerajaan',
        'Panglima perang dan Qadi (Hakim Agung)',
        'Juru tulis',
        'Duta besar luar negeri'
      ],
      jawabanBenar: 1,
    ),
    QuizModel(
      sunanNama: 'Sunan Kudus',
      pertanyaan:
          'Dua tembang macapat yang dikreasikan dan diciptakan oleh Sunan Kudus adalah...',
      pilihan: [
        'Maskumambang dan Mijil',
        'Sinom dan Kinanthi',
        'Asmarandana dan Pocung',
        'Dhandhanggula dan Durma'
      ],
      jawabanBenar: 0,
    ),
    QuizModel(
      sunanNama: 'Sunan Muria',
      pertanyaan:
          'Sunan Muria merupakan putra dari salah satu tokoh Wali Songo, yaitu...',
      pilihan: ['Sunan Kalijaga', 'Sunan Kudus', 'Sunan Bonang', 'Sunan Giri'],
      jawabanBenar: 0,
    ),
    QuizModel(
      sunanNama: 'Sunan Muria',
      pertanyaan: 'Nama asli dari Sunan Muria adalah...',
      pilihan: ['Raden Umar Said', 'Raden Qasim', 'Raden Said', 'Raden Patah'],
      jawabanBenar: 0,
    ),
    QuizModel(
      sunanNama: 'Sunan Muria',
      pertanyaan:
          'Ciri khas utama gaya berdakwah Sunan Muria yang membedakannya dari wali lainnya adalah...',
      pilihan: [
        'Tinggal di istana kota',
        'Berdakwah di daerah pedalaman dan pelosok gunung',
        'Menjadi pedagang kaya laut',
        'Mengandalkan kekuatan militer'
      ],
      jawabanBenar: 1,
    ),
    QuizModel(
      sunanNama: 'Sunan Muria',
      pertanyaan:
          'Dua jenis tembang macapat yang diciptakan oleh Sunan Muria adalah...',
      pilihan: [
        'Sinom dan Kinanthi',
        'Mijil dan Maskumambang',
        'Megatruh dan Pocung',
        'Pangkur dan Durma'
      ],
      jawabanBenar: 0,
    ),
    QuizModel(
      sunanNama: 'Sunan Muria',
      pertanyaan:
          'Lokasi makam tempat Sunan Muria dimakamkan terletak di puncak...',
      pilihan: [
        'Gunung Muria, Kudus',
        'Gunung Merapi, Sleman',
        'Gunung Lawu, Karanganyar',
        'Gunung Bromo, Probolinggo'
      ],
      jawabanBenar: 0,
    ),
    QuizModel(
      sunanNama: 'Sunan Gunung Jati',
      pertanyaan: 'Nama asli dari Sunan Gunung Jati adalah...',
      pilihan: [
        'Syarif Hidayatullah',
        'Ja\'far Shadiq',
        'Maulana Malik Ibrahim',
        'Raden Rahmat'
      ],
      jawabanBenar: 0,
    ),
    QuizModel(
      sunanNama: 'Sunan Gunung Jati',
      pertanyaan:
          'Keunikan Sunan Gunung Jati di antara anggota Wali Songo lainnya adalah beliau memegang peran sebagai...',
      pilihan: [
        'Kepala pemerintahan / Sultan sekaligus ulama',
        'Seniman pemahat patung',
        'Saudagar asing',
        'Tabib pengembara'
      ],
      jawabanBenar: 0,
    ),
    QuizModel(
      sunanNama: 'Sunan Gunung Jati',
      pertanyaan:
          'Dua kesultanan Islam di wilayah Tatar Sunda/Jawa Barat yang didirikan oleh Sunan Gunung Jati adalah...',
      pilihan: [
        'Kesultanan Cirebon dan Banten',
        'Kesultanan Demak dan Pajang',
        'Kesultanan Mataram dan Kartasura',
        'Kesultanan Gowa dan Tallo'
      ],
      jawabanBenar: 0,
    ),
    QuizModel(
      sunanNama: 'Sunan Gunung Jati',
      pertanyaan:
          'Ibu dari Sunan Gunung Jati yang merupakan putri dari Kerajaan Sunda Pajajaran bernama...',
      pilihan: [
        'Nyai Rara Santang (Syarifah Mudaim)',
        'Dewi Candrawulan',
        'Nyai Ageng Manila',
        'Dewi Sekardadu'
      ],
      jawabanBenar: 0,
    ),
    QuizModel(
      sunanNama: 'Sunan Gunung Jati',
      pertanyaan:
          'Pusat kedudukan dakwah dan kompleks pemakaman Sunan Gunung Jati berlokasi di...',
      pilihan: [
        'Gunung Sembung, Cirebon',
        'Banten Lama',
        'Sumedang',
        'Priangan'
      ],
      jawabanBenar: 0,
    ),
  ];
}
