import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kz_core/kz_core.dart';
import 'package:kz_ui_components/kz_ui_components.dart';

/// Auth Screen — dummy Google Login per spec.
/// Al pulsar espera 1s y navega a /home.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _loading = false;

  Future<void> _onLogin() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) context.go('/home');
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
              // ─── Wordmark ─────────────────────────────────────────────────
              RichText(
                text: const TextSpan(
                  style: TextStyle(fontFamily: 'Courier'),
                  children: [
                    TextSpan(
                      text: 'KANJI',
                      style: TextStyle(
                        fontSize: 28,
                        color: CyberTheme.textNeutral,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 6,
                      ),
                    ),
                    TextSpan(
                      text: 'ZEN',
                      style: TextStyle(
                        fontSize: 28,
                        color: CyberTheme.defaultAccent,
                        fontWeight: FontWeight.w100,
                        letterSpacing: 6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'SISTEMA DE APRENDIZAJE DE NIVEL ÉLITE',
                style: TextStyle(
                  color: CyberTheme.textNeutral.withOpacity(0.3),
                  fontSize: 9,
                  fontFamily: 'Courier',
                  letterSpacing: 2,
                ),
              ),

              const SizedBox(height: 64),

              // ─── Login button ─────────────────────────────────────────────
              if (_loading)
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: CyberTheme.defaultAccent,
                    strokeWidth: 1.5,
                  ),
                )
              else
                CyberButton(
                  label: 'Entrar al Sistema',
                  icon: Icons.login,
                  onTap: _onLogin,
                ),

              const SizedBox(height: 32),
              Text(
                'v0.1.0-alpha · MecaNet × SRS × Kana',
                style: TextStyle(
                  color: CyberTheme.textNeutral.withOpacity(0.15),
                  fontSize: 9,
                  fontFamily: 'Courier',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
