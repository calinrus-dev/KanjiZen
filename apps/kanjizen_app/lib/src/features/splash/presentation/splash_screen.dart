import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kz_core/kz_core.dart';
import 'package:kz_data/kz_data.dart';
import 'package:kz_ui_components/kz_ui_components.dart';

/// Splash Screen — muestra logo y verifica el estado de la BD.
/// Inicia el seeding invisible en Isolate background.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _opacity = Tween(
      begin: 0.4,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut));
    _init();
  }

  Future<void> _init() async {
    // Iniciar seeding en background sin bloquear UI
    await Future.wait([
      DatabaseInitializerService.seedInBackground(),
      Future<void>.delayed(const Duration(seconds: 2)), // mínimo splash visible
    ]);
    if (mounted) context.go('/auth');
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CyberTheme.bgObsidian,
      body: BgPattern(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ─── Logo KanjiZen ──────────────────────────────────────────
              FadeTransition(
                opacity: _opacity,
                child: Column(
                  children: [
                    // SVG-style logo mark
                    CustomPaint(
                      size: const Size(80, 80),
                      painter: _LogoPainter(),
                    ),
                    const SizedBox(height: 24),
                    // Wordmark
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontFamily: 'Courier',
                          letterSpacing: 8,
                        ),
                        children: [
                          TextSpan(
                            text: 'KANJI',
                            style: TextStyle(
                              fontSize: 32,
                              color: CyberTheme.textNeutral,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          TextSpan(
                            text: 'ZEN',
                            style: TextStyle(
                              fontSize: 32,
                              color: CyberTheme.defaultAccent,
                              fontWeight: FontWeight.w100,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'ZERO BS · LATENCIA CERO · FLUIDEZ NATIVA',
                      style: TextStyle(
                        color: CyberTheme.textNeutral.withValues(alpha: 0.3),
                        fontSize: 9,
                        fontFamily: 'Courier',
                        letterSpacing: 3,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 60),

              // ─── Loading indicator ──────────────────────────────────────
              SizedBox(
                width: 120,
                child: LinearProgressIndicator(
                  backgroundColor: CyberTheme.defaultAccent.withValues(alpha: 0.1),
                  valueColor: const AlwaysStoppedAnimation(
                    CyberTheme.defaultAccent,
                  ),
                  minHeight: 1,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'INICIALIZANDO SISTEMA',
                style: TextStyle(
                  color: CyberTheme.textNeutral.withValues(alpha: 0.2),
                  fontSize: 9,
                  fontFamily: 'Courier',
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// CustomPainter SVG-style para el logo mark de KanjiZen.
class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    const accent = CyberTheme.defaultAccent;
    final p = Paint()
      ..color = accent
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final pFill = Paint()
      ..color = accent.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    // Octágono exterior
    final oct = Path();
    final r = s.width / 2;
    final cx = s.width / 2;
    final cy = s.height / 2;
    for (var i = 0; i < 8; i++) {
      final angle = (i * 45 - 22.5) * (3.14159 / 180);
      final x = cx + r * _cos(angle);
      final y = cy + r * _sin(angle);
      if (i == 0) {
        oct.moveTo(x, y);
      } else {
        oct.lineTo(x, y);
      }
    }
    oct.close();
    canvas.drawPath(oct, pFill);
    canvas.drawPath(oct, p);

    // Cruz interior (zen)
    final inner = r * 0.35;
    canvas.drawLine(
      Offset(cx - inner, cy),
      Offset(cx + inner, cy),
      p..strokeWidth = 1.5,
    );
    canvas.drawLine(Offset(cx, cy - inner), Offset(cx, cy + inner), p);

    // Punto central
    canvas.drawCircle(Offset(cx, cy), 4, Paint()..color = accent);
  }

  double _cos(double r) {
    // simple cos via Taylor (4 terms)
    final r2 = r * r;
    return 1 - r2 / 2 + r2 * r2 / 24 - r2 * r2 * r2 / 720;
  }

  double _sin(double r) {
    final r2 = r * r;
    return r - r2 * r / 6 + r2 * r2 * r / 120;
  }

  @override
  bool shouldRepaint(_) => false;
}
