import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:lottie/lottie.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'pages/region_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey:"AIzaSyD2z5VV9CyYh_ePtobuyqBW3hIFQAVA830",
          authDomain: "pharmacie-h24-9bd40.firebaseapp.com",
          projectId: "pharmacie-h24-9bd40",
          storageBucket: "pharmacie-h24-9bd40.firebasestorage.app",
          messagingSenderId: "972821009663",
          appId:"1:972821009663:web:0478ba44058e870b8b68ca", 
        ),
      );
    } else {
      await Firebase.initializeApp();
    }
  } catch (e) {
    debugPrint("🔥 Erreur Firebase : $e");
  }

  runApp(const PharmaciesApp());
}

class PharmaciesApp extends StatelessWidget {
  const PharmaciesApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pharmacie H24',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),
      home: const SplashScreen(),
    );
  }
}

// ------------------------------------------------------------
// 🎬 Splash Screen animé
// ------------------------------------------------------------
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AccueilPage3D()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 180,
              child: Lottie.asset(
                'assets/images/animation.json', // 🔹 Animation locale
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Pharmacie H24',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0E7C24),
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Chargement…',
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------
// 🌌 Accueil 3D avec Parallax (Gyroscope/Molette + Souris)
// ------------------------------------------------------------
class AccueilPage3D extends StatefulWidget {
  const AccueilPage3D({Key? key}) : super(key: key);
  @override
  State<AccueilPage3D> createState() => _AccueilPage3DState();
}

class _AccueilPage3DState extends State<AccueilPage3D>
    with TickerProviderStateMixin {
  final List<String> regions = const [
    'Dakar',
    'Thiès',
    'Diourbel',
    'Saint-Louis',
    'Louga',
    'Matam',
    'Tambacounda',
    'Kédougou',
    'Kaffrine',
    'Kaolack',
    'Fatick',
    'Sédhiou',
    'Kolda',
    'Ziguinchor',
  ];

  double _tiltX = 0.0;
  double _tiltY = 0.0;
  Offset _mouse = Offset.zero;
  late final AnimationController _introController;
  StreamSubscription<AccelerometerEvent>? _accelSub;

  @override
  void initState() {
    super.initState();
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    if (!kIsWeb) {
      _accelSub = accelerometerEvents.listen((event) {
        final nx = (event.y / 10).clamp(-1.0, 1.0);
        final ny = (event.x / 10).clamp(-1.0, 1.0);
        setState(() {
          _tiltX = nx * 0.35;
          _tiltY = -ny * 0.35;
        });
      });
    }
  }

  @override
  void dispose() {
    _accelSub?.cancel();
    _introController.dispose();
    super.dispose();
  }

  Matrix4 _perspective({double x = 0, double y = 0, double z = 0}) {
    final m = Matrix4.identity()
      ..setEntry(3, 2, 0.0018)
      ..rotateX(x)
      ..rotateY(y)
      ..translate(0.0, 0.0, z);
    return m;
  }

  void _updateMouseTilt(Size size, Offset position) {
    final px = (position.dx / size.width).clamp(0.0, 1.0);
    final py = (position.dy / size.height).clamp(0.0, 1.0);
    final cx = (py - 0.5) * 2;
    final cy = (px - 0.5) * 2;
    setState(() {
      _mouse = position;
      _tiltX = cx * 0.25;
      _tiltY = cy * 0.25;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: MouseRegion(
        onHover: (e) {
          if (kIsWeb) _updateMouseTilt(size, e.position);
        },
        onExit: (_) {
          if (kIsWeb) setState(() => {_tiltX = 0, _tiltY = 0});
        },
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFE9F7EF), Color(0xFFD6F5E0)],
                  ),
                ),
              ),
            ),
            Positioned(
              top: -120,
              left: -80,
              child: Transform(
                transform: _perspective(x: _tiltX * 0.2, y: _tiltY * 0.2, z: -60),
                alignment: Alignment.center,
                child: _blob(220, const Color(0xB20E7C24)),
              ),
            ),
            Positioned(
              bottom: -140,
              right: -60,
              child: Transform(
                transform: _perspective(x: _tiltX * 0.35, y: _tiltY * 0.35, z: -30),
                alignment: Alignment.center,
                child: _blob(280, const Color(0x8019A463)),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Transform(
                    transform: _perspective(x: _tiltX * 0.15, y: _tiltY * 0.15),
                    alignment: Alignment.center,
                    child: _glass(
                      child: Row(
                        children: const [
                          Icon(Icons.local_pharmacy, color: Color(0xFF0E7C24)),
                          SizedBox(width: 10),
                          Text(
                            'Pharmacie H24',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Column(
                children: [
                  const SizedBox(height: 90),
                  Transform(
                    transform: _perspective(x: _tiltX * 0.25, y: _tiltY * 0.25, z: -10),
                    alignment: Alignment.center,
                    child: SizedBox(
                      height: 160,
                      child: Lottie.asset(
                        'assets/images/animation.json', // 🔹 Animation locale
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: FadeTransition(
                      opacity: CurvedAnimation(
                        parent: _introController,
                        curve: Curves.easeOut,
                      ),
                      child: Column(
                        children: const [
                          Text(
                            'Bienvenue sur Pharmacie H24 🌿',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0E7C24),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Trouvez les pharmacies ouvertes 24h/24 et les pharmacies de garde partout au Sénégal.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: GridView.builder(
                        itemCount: regions.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1.9,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                        ),
                        itemBuilder: (context, index) {
                          return _RegionCard3D(
                            label: regions[index],
                            tiltX: _tiltX,
                            tiltY: _tiltY,
                            delayMs: 120 * index,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => RegionPage(regionName: regions[index]),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Transform(
                      transform: _perspective(x: _tiltX * 0.15, y: _tiltY * 0.15),
                      alignment: Alignment.center,
                      child: const Text(
                        '© 2025 Pharmacie H24 • Tous droits réservés',
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _glass({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.15),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.6), width: 1),
      ),
      child: child,
    );
  }

  Widget _blob(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.35),
            blurRadius: 120,
            spreadRadius: 40,
          )
        ],
      ),
    );
  }
}

// ------------------------------------------------------------
// 🧩 Carte 3D interactive d'une région
// ------------------------------------------------------------
class _RegionCard3D extends StatefulWidget {
  final String label;
  final double tiltX;
  final double tiltY;
  final int delayMs;
  final VoidCallback onTap;

  const _RegionCard3D({
    Key? key,
    required this.label,
    required this.tiltX,
    required this.tiltY,
    required this.delayMs,
    required this.onTap,
  }) : super(key: key);

  @override
  State<_RegionCard3D> createState() => _RegionCard3DState();
}

class _RegionCard3DState extends State<_RegionCard3D>
    with SingleTickerProviderStateMixin {
  bool _hover = false;
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appear = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    final localTiltX = widget.tiltX + (_hover ? -0.08 : 0);
    final localTiltY = widget.tiltY + (_hover ? 0.10 : 0);

    return FadeTransition(
      opacity: appear,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0016)
              ..rotateX(localTiltX)
              ..rotateY(localTiltY)
              ..translate(0.0, 0.0, _hover ? 16.0 : 0.0),
            child: Stack(
              children: [
                Positioned.fill(
                  top: 10,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 260),
                    opacity: _hover ? 1 : 0.5,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.10),
                            blurRadius: 24,
                            spreadRadius: 2,
                            offset: const Offset(0, 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 260),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF0E7C24), Color(0xFF19A463)],
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.local_pharmacy, color: Colors.white),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            widget.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ],
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