import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'constants.dart';
import 'presentation.dart';

// ===========================================================================
//  PALETTE : lapis nocturne, or pharaonique, crème
// ===========================================================================
const Color _ink = Color(0xFF070B1F);
const Color _deep = Color(0xFF040818);
const Color _gold = Color(0xFFE8BE62);
const Color _goldDeep = Color(0xFFB88428);
const Color _cream = Color(0xFFFFF4DA);

TextStyle _serif(double size,
    {FontWeight weight = FontWeight.w600,
      Color color = _cream,
      double spacing = 0.3,
      double height = 1.2,
      FontStyle style = FontStyle.normal}) =>
    TextStyle(
      fontFamily: 'Georgia',
      fontFamilyFallback: const ['Times New Roman', 'serif'],
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: spacing,
      height: height,
      fontStyle: style,
    );

int _phaseOf(double t) {
  if (t >= 0.93 || t < 0.07) return 0; // aube
  if (t < 0.20) return 1; // matin
  if (t < 0.45) return 2; // plein jour
  if (t < 0.54) return 3; // heure dorée
  if (t < 0.66) return 4; // coucher
  return 5; // nuit
}

// ===========================================================================
//  PAGE LANGUES
//  Haut : la scène du Nil, seule, sans aucun élément d'interface dessus.
//  Bas  : le panneau de choix de la langue.
// ===========================================================================
class LanguesPage extends StatefulWidget {
  final bool isProfileCreated;
  const LanguesPage({super.key, required this.isProfileCreated});

  @override
  State<LanguesPage> createState() => _LanguesPageState();
}

class _LanguesPageState extends State<LanguesPage>
    with TickerProviderStateMixin {
  // Le cycle démarre sur un matin doré.
  static const double _startTime = 0.09;

  static const Map<String, String> _brand = {
    'fr': 'Égypte',
    'en': 'Egypt',
    'ar': 'مصر',
  };

  static const Map<String, List<String>> _phases = {
    'fr': [
      'Aube sur le Nil',
      'Matin doré',
      'Plein midi',
      'Heure dorée',
      'Coucher du soleil',
      'Nuit étoilée',
    ],
    'en': [
      'Dawn on the Nile',
      'Golden morning',
      'High noon',
      'Golden hour',
      'Sunset',
      'Starry night',
    ],
    'ar': [
      'فجر على النيل',
      'صباح ذهبي',
      'ظهيرة',
      'الساعة الذهبية',
      'غروب الشمس',
      'ليلة مرصعة بالنجوم',
    ],
  };

  String _selectedCode = 'fr';

  late final AnimationController _cycle;
  late final AnimationController _enter;
  late final Animation<double> _sceneFade;
  late final Animation<double> _panelIn;

  @override
  void initState() {
    super.initState();
    // Cycle jour/nuit lent et continu : il ne bloque jamais l'écran.
    _cycle = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
      value: _startTime,
    )..repeat();
    _enter = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _sceneFade = CurvedAnimation(
        parent: _enter, curve: const Interval(0.0, 0.6, curve: Curves.easeOut));
    _panelIn = CurvedAnimation(
        parent: _enter,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic));
    _enter.forward();
  }

  @override
  void dispose() {
    _cycle.dispose();
    _enter.dispose();
    super.dispose();
  }

  void _confirm() {
    HapticFeedback.mediumImpact();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (_) => PresentationScreen(languageCode: _selectedCode)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final list =
        localizedLanguagesData[_selectedCode] ?? localizedLanguagesData['fr']!;
    // Ponctuation adaptée à chaque langue :
    // Espace avant le point d'interrogation dans les trois langues.
    const Map<String, String> languageQuestions = {
      'fr': 'Quelle est votre langue ?',
      'en': 'What is your language ?',
      'ar': 'ما لغتك ؟',
    };
    final String question =
        languageQuestions[_selectedCode] ?? languageQuestions['fr']!;
    final ui_ = localizedUi[_selectedCode] ?? localizedUi['fr'] ?? {};
    final String validate = ui_['validate'] ?? 'Valider';
    final bool rtl = _selectedCode == 'ar';
    final double maxPanel = MediaQuery.of(context).size.height * 0.56;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Directionality(
        textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
        child: Scaffold(
          backgroundColor: _deep,
          body: Column(
            children: [
              Expanded(child: _buildScene(rtl)),
              _buildPanel(maxPanel, list, question, validate, rtl),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  //  SCÈNE (aucune langue ici, seulement le nom du pays et l'heure du jour)
  // -------------------------------------------------------------------------
  Widget _buildScene(bool rtl) {
    final String brand = _brand[_selectedCode] ?? _brand['en']!;
    final List<String> phases = _phases[_selectedCode] ?? _phases['en']!;
    final List<Shadow> glow = [
      Shadow(color: Colors.black.withOpacity(0.55), blurRadius: 18),
    ];

    return FadeTransition(
      opacity: _sceneFade,
      child: Stack(
        fit: StackFit.expand,
        children: [
          RepaintBoundary(
            child: CustomPaint(painter: _NileScenePainter(_cycle)),
          ),
          IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.center,
                  colors: [
                    Colors.black.withOpacity(0.48),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      brand,
                      style: _serif(20,
                          weight: FontWeight.w600,
                          spacing: rtl ? 0 : 10)
                          .copyWith(shadows: glow),
                    ),
                    const SizedBox(height: 8),
                    AnimatedBuilder(
                      animation: _cycle,
                      builder: (context, _) {
                        final int idx = _phaseOf(_cycle.value);
                        return AnimatedSwitcher(
                          duration: const Duration(milliseconds: 800),
                          child: Text(
                            phases[idx],
                            key: ValueKey('$_selectedCode$idx'),
                            style: _serif(13,
                                weight: FontWeight.w400,
                                color: _gold,
                                spacing: rtl ? 0 : 1.4,
                                style: rtl
                                    ? FontStyle.normal
                                    : FontStyle.italic)
                                .copyWith(shadows: glow),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  //  PANNEAU DES LANGUES (en bas, séparé de l'animation)
  // -------------------------------------------------------------------------
  Widget _buildPanel(double maxHeight, List<dynamic> list, String question,
      String validate, bool rtl) {
    return AnimatedBuilder(
      animation: _panelIn,
      builder: (context, child) => Opacity(
        opacity: _panelIn.value.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, (1 - _panelIn.value) * 48),
          child: child,
        ),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: _ink,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(color: _gold.withOpacity(0.26)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.55),
                blurRadius: 30,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 120,
                    height: 14,
                    child: CustomPaint(painter: _OrnamentPainter()),
                  ),
                  const SizedBox(height: 10),
                  ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 54),
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        child: Text(
                          question,
                          key: ValueKey('q$_selectedCode'),
                          textAlign: TextAlign.center,
                          style: _serif(23,
                              weight: FontWeight.w700,
                              spacing: rtl ? 0 : 0.2,
                              height: 1.25),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      physics: const BouncingScrollPhysics(),
                      itemCount: list.length,
                      separatorBuilder: (_, __) => Container(
                        height: 1,
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        color: Colors.white.withOpacity(0.06),
                      ),
                      itemBuilder: (context, i) {
                        final String c = list[i]['code'] ?? 'fr';
                        return _LangRow(
                          name: list[i]['name'] ?? '',
                          code: c,
                          icon: list[i]['icon'] ?? Icons.language,
                          selected: c == _selectedCode,
                          onTap: () {
                            if (c != _selectedCode) {
                              HapticFeedback.selectionClick();
                            }
                            setState(() => _selectedCode = c);
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildValidate(validate, rtl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildValidate(String label, bool rtl) {
    const Color dark = Color(0xFF2A1B05);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: _confirm,
        child: Ink(
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFE9A8), _gold, _goldDeep],
            ),
            boxShadow: [
              BoxShadow(
                color: _gold.withOpacity(0.28),
                blurRadius: 22,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label,
                  style: _serif(17,
                      weight: FontWeight.w800,
                      color: dark,
                      spacing: rtl ? 0 : 0.6)),
              const SizedBox(width: 10),
              Icon(
                rtl ? Icons.arrow_back_rounded : Icons.arrow_forward_rounded,
                color: dark,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
//  LIGNE DE LANGUE
// ===========================================================================
class _LangRow extends StatelessWidget {
  final String name;
  final String code;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _LangRow({
    required this.name,
    required this.code,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        height: 62,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? _gold.withOpacity(0.09) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: _gold.withOpacity(selected ? 0.9 : 0.25)),
              ),
              child: Icon(icon,
                  size: 18, color: selected ? _gold : Colors.white60),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                name,
                style: _serif(19,
                    weight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? _cream : Colors.white70),
              ),
            ),
            Text(
              code.toUpperCase(),
              style: _serif(12,
                  weight: FontWeight.w400,
                  color: _gold.withOpacity(selected ? 0.95 : 0.45),
                  spacing: 2.4),
            ),
            const SizedBox(width: 14),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? _gold : Colors.white24,
                  width: selected ? 1.6 : 1,
                ),
              ),
              alignment: Alignment.center,
              child: AnimatedScale(
                scale: selected ? 1 : 0,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutBack,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle, color: _gold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrnamentPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Offset c = size.center(Offset.zero);
    final Paint line = Paint()
      ..strokeWidth = 1
      ..shader = LinearGradient(colors: [
        _gold.withOpacity(0),
        _gold,
        _gold.withOpacity(0),
      ]).createShader(Offset.zero & size);
    canvas.drawLine(Offset(0, c.dy), Offset(c.dx - 14, c.dy), line);
    canvas.drawLine(Offset(c.dx + 14, c.dy), Offset(size.width, c.dy), line);
    canvas.drawPath(
        Path()
          ..moveTo(c.dx, c.dy - 6)
          ..lineTo(c.dx + 6, c.dy)
          ..lineTo(c.dx, c.dy + 6)
          ..lineTo(c.dx - 6, c.dy)
          ..close(),
        Paint()..color = _gold);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ===========================================================================
//  OUTILS DE SCÈNE
// ===========================================================================
class _K {
  final double t;
  final Color top, mid, hor, lit, shade, sil;
  const _K(this.t, this.top, this.mid, this.hor, this.lit, this.shade, this.sil);
}

class _Pal {
  final Color top, mid, hor, lit, shade, sil;
  const _Pal(this.top, this.mid, this.hor, this.lit, this.shade, this.sil);
}

class _Pt {
  final double x, y, s, a;
  const _Pt(this.x, this.y, this.s, this.a);
}

List<_Pt> _genPts(int n, int seed, {double sMin = 0.5, double sMax = 1.7}) {
  final Random r = Random(seed);
  return List.generate(
      n,
          (_) => _Pt(r.nextDouble(), r.nextDouble(),
          sMin + r.nextDouble() * (sMax - sMin), 0.4 + 0.6 * r.nextDouble()));
}

final List<_Pt> _stars = _genPts(110, 11);
final List<_Pt> _motes = _genPts(30, 3, sMin: 0.8, sMax: 2.2);
final List<_Pt> _ripples = _genPts(34, 7, sMin: 0.04, sMax: 0.12);

double _smooth(double a, double b, double x) {
  final double v = ((x - a) / (b - a)).clamp(0.0, 1.0);
  return v * v * (3 - 2 * v);
}

// Oscillation à nombre entier de périodes par cycle : la boucle est sans raccord.
double _osc(double t, int n, [double ph = 0]) => sin(2 * pi * n * t + ph);

// ===========================================================================
//  SCÈNE : Nil, felouque, pyramides, temple, obélisque, palmiers
//  Cycle complet : aube, matin, plein jour, coucher, crépuscule, nuit.
// ===========================================================================
class _NileScenePainter extends CustomPainter {
  final Animation<double> anim;
  _NileScenePainter(this.anim) : super(repaint: anim);

  // Palette du jour, interpolée entre ces repères (t de 0 à 1).
  static const List<_K> _keys = [
    _K(0.00, Color(0xFF22256B), Color(0xFFC8627A), Color(0xFFFFB27A),
        Color(0xFFE9A07C), Color(0xFF6A3E5E), Color(0xFF2A1F45)), // aube
    _K(0.10, Color(0xFF3F72BD), Color(0xFFEBA982), Color(0xFFFFDCA6),
        Color(0xFFFFD08E), Color(0xFFA9695A), Color(0xFF4A3340)), // matin
    _K(0.28, Color(0xFF2D7BD0), Color(0xFF86C2EE), Color(0xFFDDF0F8),
        Color(0xFFF6D9A2), Color(0xFFB98A62), Color(0xFF5A4636)), // plein jour
    _K(0.46, Color(0xFF3677C2), Color(0xFFA6C8E2), Color(0xFFFFE6B8),
        Color(0xFFF8CF92), Color(0xFFAE7A55), Color(0xFF54382E)), // après-midi
    _K(0.56, Color(0xFF3B2F80), Color(0xFFE26F5B), Color(0xFFFFB35E),
        Color(0xFFF2A46A), Color(0xFF7A3F4E), Color(0xFF2E1E3E)), // coucher
    _K(0.64, Color(0xFF15144C), Color(0xFF6D3B80), Color(0xFFEA876C),
        Color(0xFFB5707A), Color(0xFF3A2650), Color(0xFF1A1236)), // crépuscule
    _K(0.74, Color(0xFF040720), Color(0xFF0D1140), Color(0xFF1C1B5A),
        Color(0xFF2C2E6E), Color(0xFF0F1038), Color(0xFF080A26)), // nuit
    _K(0.90, Color(0xFF070B2E), Color(0xFF1B1F60), Color(0xFF55386F),
        Color(0xFF3A3A78), Color(0xFF121444), Color(0xFF0A0B2A)), // avant l'aube
    _K(1.00, Color(0xFF22256B), Color(0xFFC8627A), Color(0xFFFFB27A),
        Color(0xFFE9A07C), Color(0xFF6A3E5E), Color(0xFF2A1F45)), // aube
  ];

  static _Pal _sample(double t) {
    int i = 0;
    while (i < _keys.length - 2 && t >= _keys[i + 1].t) {
      i++;
    }
    final _K a = _keys[i], b = _keys[i + 1];
    final double v = ((t - a.t) / (b.t - a.t)).clamp(0.0, 1.0);
    final double p = v * v * (3 - 2 * v);
    Color l(Color x, Color y) => Color.lerp(x, y, p)!;
    return _Pal(l(a.top, b.top), l(a.mid, b.mid), l(a.hor, b.hor),
        l(a.lit, b.lit), l(a.shade, b.shade), l(a.sil, b.sil));
  }

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width, h = size.height;
    final double t = anim.value % 1.0;
    final _Pal p = _sample(t);
    final double gy = h * 0.64; // horizon
    final double night = _smooth(0.60, 0.72, t) * (1 - _smooth(0.90, 1.0, t));
    final double r = w * 0.062;

    // ---- Position du soleil (t 0 → 0.60) et de la lune (t 0.60 → 1.04) ----
    Offset? sun;
    Offset? moon;
    double sunElev = 0, moonElev = 0;
    if (t < 0.60) {
      final double u = t / 0.60;
      sunElev = sin(pi * u);
      sun = Offset(w * (0.16 + 0.68 * u),
          gy + r * 1.1 - (gy * 0.78 + r * 1.1) * sunElev);
    }
    final double mu = ((t - 0.60 + 1.0) % 1.0) / 0.44;
    if (mu <= 1.0) {
      moonElev = sin(pi * mu);
      moon = Offset(w * (0.16 + 0.68 * mu),
          gy + r * 1.1 - (gy * 0.70 + r * 1.1) * moonElev);
    }
    final Color sunCol = Color.lerp(const Color(0xFFFF5A2A),
        const Color(0xFFFFF3C4), (sunElev * 2.4).clamp(0.0, 1.0))!;
    final double lightX = (sun ?? moon)?.dx ?? w * 0.5;

    // ---- CIEL ----
    final Rect skyRect = Rect.fromLTWH(0, 0, w, gy + 2);
    canvas.drawRect(
      skyRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [p.top, p.mid, p.hor],
          stops: const [0.0, 0.58, 1.0],
        ).createShader(skyRect),
    );

    // ---- ÉTOILES ----
    if (night > 0.01) {
      final Paint sp = Paint();
      for (int i = 0; i < _stars.length; i++) {
        final _Pt s = _stars[i];
        final double tw = 0.55 + 0.45 * _osc(t, 18 + i % 7, i.toDouble());
        sp.color = Colors.white.withOpacity((night * s.a * tw).clamp(0.0, 1.0));
        canvas.drawCircle(Offset(s.x * w, s.y * gy * 0.82), s.s, sp);
      }
    }

    // ---- ASTRES + NUAGES (coupés à l'horizon) ----
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, w, gy));
    if (sun != null) {
      final double g = 0.65 + 0.35 * (1 - sunElev);
      canvas.drawCircle(
        sun,
        r * 7,
        Paint()
          ..shader = RadialGradient(colors: [
            sunCol.withOpacity(0.60 * g),
            sunCol.withOpacity(0.16 * g),
            sunCol.withOpacity(0),
          ], stops: const [0.0, 0.32, 1.0])
              .createShader(Rect.fromCircle(center: sun, radius: r * 7)),
      );
      canvas.drawCircle(
        sun,
        r,
        Paint()
          ..shader = RadialGradient(colors: [
            Colors.white.withOpacity(0.95),
            sunCol,
          ]).createShader(Rect.fromCircle(center: sun, radius: r)),
      );
    }
    if (moon != null) _moon(canvas, moon, r * 0.78);
    _clouds(canvas, w, h, t, p, night);
    canvas.restore();

    // ---- DUNES LOINTAINES (voilées par la brume) ----
    _dune(canvas, w, gy, h * 0.030, 0.9, 4.1, Color.lerp(p.lit, p.hor, 0.62)!);
    _dune(canvas, w, gy, h * 0.016, 2.1, 6.3, Color.lerp(p.shade, p.hor, 0.45)!);

    // ---- PYRAMIDES ----
    _pyramid(canvas, w * 0.20, gy, w * 0.50, h * 0.29, p, lightX, 0.10);
    _pyramid(canvas, w * 0.47, gy, w * 0.34, h * 0.19, p, lightX, 0.06);
    _pyramid(canvas, w * 0.37, gy, w * 0.20, h * 0.10, p, lightX, 0.0);

    // ---- TEMPLE + OBÉLISQUE ----
    _temple(canvas, w, h, gy, p, lightX, night);

    // ---- BERGE ----
    final Rect bank = Rect.fromLTRB(0, gy - 1, w, gy + h * 0.018);
    canvas.drawRect(
      bank,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color.lerp(p.sil, p.shade, 0.4)!, p.sil],
        ).createShader(bank),
    );

    // ---- PALMIERS ----
    final Color palm = Color.lerp(p.sil, Colors.black, 0.4)!;
    final double sway = _osc(t, 24) * 2.5;
    _palm(canvas, w * 0.03, gy + 2, h * 0.27, palm, sway);
    _palm(canvas, w * 0.085, gy + 2, h * 0.16, palm, -sway);
    _palm(canvas, w * 0.44, gy + 2, h * 0.10, palm, sway);
    _palm(canvas, w * 0.965, gy + 2, h * 0.22, palm, -sway);

    // ---- FLEUVE ----
    final double wt = gy + h * 0.018;
    final Rect water = Rect.fromLTRB(0, wt, w, h);
    canvas.drawRect(
      water,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(p.hor, _deep, 0.30)!,
            Color.lerp(p.mid, _deep, 0.62)!,
            _deep,
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(water),
    );

    // Reflet doux des monuments
    final Rect soft = Rect.fromLTWH(0, wt, w, h * 0.09);
    canvas.drawRect(
      soft,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [p.lit.withOpacity(0.30), Colors.transparent],
        ).createShader(soft),
    );

    // Colonne de lumière (soleil ou lune)
    double srcA = 0;
    Color srcCol = sunCol;
    double srcX = w * 0.5;
    if (sun != null) {
      srcA = (sunElev * 5).clamp(0.0, 1.0);
      srcX = sun.dx;
    } else if (moon != null) {
      srcA = (moonElev * 5).clamp(0.0, 1.0) * 0.55;
      srcCol = const Color(0xFFDDE6FF);
      srcX = moon.dx;
    }
    final double rh = h - wt;
    if (srcA > 0.01) {
      final Paint rf = Paint()
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round;
      for (int i = 0; i < 28; i++) {
        final double f = i / 28;
        final double yy = wt + 4 + f * rh * 0.92;
        final double lw =
            w * (0.05 + 0.24 * f) * (0.55 + 0.45 * _osc(t, 44, i * 1.9));
        final double dx = _osc(t, 26, i.toDouble()) * 5;
        rf.color = srcCol.withOpacity((0.75 * srcA * (1 - f * 0.8)).clamp(0.0, 1.0));
        canvas.drawLine(Offset(srcX - lw / 2 + dx, yy),
            Offset(srcX + lw / 2 + dx, yy), rf);
      }
    }

    // Rides sur l'eau
    final Paint rp = Paint()
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withOpacity(0.05 + 0.09 * (1 - night));
    for (final _Pt q in _ripples) {
      final double y = wt + 6 + q.y * (rh - 10);
      final double len = w * q.s * (0.4 + 0.9 * (y - wt) / rh);
      final double x = w * q.x + _osc(t, 12, q.a * 6) * 8;
      canvas.drawLine(Offset(x - len / 2, y), Offset(x + len / 2, y), rp);
    }

    _boat(canvas, w, h, t, p, night);
    _dust(canvas, w, h, t, sunElev);
    _birds(canvas, w, h, t, p, sunElev);

    // ---- BRUME D'HORIZON ----
    final Rect mist = Rect.fromLTWH(0, gy - h * 0.05, w, h * 0.10);
    canvas.drawRect(
      mist,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            p.hor.withOpacity(0.32),
            Colors.transparent,
          ],
        ).createShader(mist),
    );

    // ---- VIGNETTE + FONDU BAS (raccord avec le panneau) ----
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = RadialGradient(
          radius: 1.05,
          colors: [Colors.transparent, Colors.black.withOpacity(0.42)],
          stops: const [0.6, 1.0],
        ).createShader(Offset.zero & size),
    );
    final Rect fade = Rect.fromLTWH(0, h * 0.84, w, h * 0.16 + 1);
    canvas.drawRect(
      fade,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_deep.withOpacity(0), _deep],
        ).createShader(fade),
    );
  }

  // ---------------------------------------------------------------------------
  void _moon(Canvas canvas, Offset c, double rad) {
    canvas.drawCircle(
      c,
      rad * 6,
      Paint()
        ..shader = RadialGradient(colors: [
          const Color(0xFFBFD0FF).withOpacity(0.34),
          const Color(0xFFBFD0FF).withOpacity(0),
        ]).createShader(Rect.fromCircle(center: c, radius: rad * 6)),
    );
    canvas.drawCircle(c, rad, Paint()..color = const Color(0xFFF4F1E6));
    final Paint crater = Paint()..color = const Color(0xFFB8BCD0).withOpacity(0.35);
    canvas.drawCircle(c + Offset(-rad * 0.30, -rad * 0.20), rad * 0.18, crater);
    canvas.drawCircle(c + Offset(rad * 0.28, rad * 0.10), rad * 0.24, crater);
    canvas.drawCircle(c + Offset(-rad * 0.05, rad * 0.45), rad * 0.12, crater);
  }

  void _clouds(Canvas canvas, double w, double h, double t, _Pal p, double night) {
    final Color col = Color.lerp(p.hor, Colors.white, 0.45)!;
    final double a = 0.16 + 0.22 * (1 - night);
    for (int i = 0; i < 5; i++) {
      final double cx = w * (((t * 1.4 + i * 0.27) % 1.4) - 0.2);
      final double cy = h * (0.10 + i * 0.058);
      final double wd = w * (0.46 - i * 0.04);
      canvas.save();
      canvas.translate(cx, cy);
      canvas.scale(1, 0.11);
      canvas.drawCircle(
        Offset.zero,
        wd / 2,
        Paint()
          ..shader = RadialGradient(colors: [
            col.withOpacity(a),
            col.withOpacity(0),
          ]).createShader(Rect.fromCircle(center: Offset.zero, radius: wd / 2)),
      );
      canvas.restore();
    }
  }

  void _dune(Canvas canvas, double w, double gy, double amp, double ph,
      double freq, Color col) {
    final Path path = Path()..moveTo(0, gy);
    for (double x = 0; x <= w + 6; x += 6) {
      path.lineTo(x, gy - amp - amp * 0.7 * sin(x / w * freq + ph));
    }
    path
      ..lineTo(w, gy)
      ..close();
    canvas.drawPath(path, Paint()..color = col);
  }

  void _pyramid(Canvas canvas, double cx, double base, double wd, double ht,
      _Pal p, double lightX, double haze) {
    final Offset apex = Offset(cx, base - ht);
    final Rect box = Rect.fromLTRB(cx - wd / 2, apex.dy, cx + wd / 2, base);
    final Color lit = Color.lerp(p.lit, p.hor, haze)!;
    final Color litLow = Color.lerp(Color.lerp(p.lit, p.hor, 0.45)!, p.hor, haze)!;
    final Color shade = Color.lerp(p.shade, p.hor, haze)!;

    canvas.drawPath(
      Path()
        ..moveTo(cx - wd / 2, base)
        ..lineTo(apex.dx, apex.dy)
        ..lineTo(cx + wd / 2, base)
        ..close(),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [lit, litLow],
        ).createShader(box),
    );

    // assises de pierre
    final Paint course = Paint()
      ..color = shade.withOpacity(0.20)
      ..strokeWidth = 0.7;
    for (int i = 1; i < 8; i++) {
      final double f = i / 8;
      final double hw = wd / 2 * f;
      canvas.drawLine(Offset(cx - hw, apex.dy + ht * f),
          Offset(cx + hw, apex.dy + ht * f), course);
    }

    // face dans l'ombre, opposée à la lumière
    final bool lightFromLeft = lightX < cx;
    final Path face = Path()..moveTo(apex.dx, apex.dy);
    if (lightFromLeft) {
      face
        ..lineTo(cx + wd / 2, base)
        ..lineTo(cx + wd * 0.05, base);
    } else {
      face
        ..lineTo(cx - wd / 2, base)
        ..lineTo(cx - wd * 0.05, base);
    }
    face.close();
    canvas.drawPath(face, Paint()..color = shade);
  }

  void _temple(Canvas canvas, double w, double h, double gy, _Pal p,
      double lightX, double night) {
    final Paint stone = Paint()..color = Color.lerp(p.sil, p.shade, 0.35)!;
    final Paint stoneLit = Paint()..color = Color.lerp(p.sil, p.lit, 0.55)!;
    final bool litLeft = lightX < w * 0.8;

    // Pylône monumental
    final double th = h * 0.22;
    final double tw = w * 0.095;
    final double x1 = w * 0.745, x2 = w * 0.865;
    final Paint groove = Paint()
      ..color = Colors.black.withOpacity(0.18)
      ..strokeWidth = 0.8;
    for (final double x in [x1, x2]) {
      canvas.drawPath(
          Path()
            ..moveTo(x, gy)
            ..lineTo(x + tw * 0.07, gy - th)
            ..lineTo(x + tw * 0.93, gy - th)
            ..lineTo(x + tw, gy)
            ..close(),
          stone);
      if (litLeft) {
        canvas.drawPath(
            Path()
              ..moveTo(x, gy)
              ..lineTo(x + tw * 0.07, gy - th)
              ..lineTo(x + tw * 0.45, gy - th)
              ..lineTo(x + tw * 0.45, gy)
              ..close(),
            stoneLit);
      } else {
        canvas.drawPath(
            Path()
              ..moveTo(x + tw * 0.55, gy)
              ..lineTo(x + tw * 0.55, gy - th)
              ..lineTo(x + tw * 0.93, gy - th)
              ..lineTo(x + tw, gy)
              ..close(),
            stoneLit);
      }
      canvas.drawRect(
          Rect.fromLTWH(x - 2, gy - th - h * 0.008, tw + 4, h * 0.010), stone);
      for (int k = 1; k < 5; k++) {
        canvas.drawLine(Offset(x + tw * k / 5, gy),
            Offset(x + tw * k / 5, gy - th), groove);
      }
    }

    // Porte, éclairée la nuit
    final double gx1 = x1 + tw, gx2 = x2;
    final Rect door = Rect.fromLTRB(gx1, gy - th * 0.70, gx2, gy);
    canvas.drawRect(
      door,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _gold.withOpacity(0.18 + 0.70 * night),
            _gold.withOpacity(0.06 + 0.24 * night),
          ],
        ).createShader(door),
    );
    canvas.drawRect(
        Rect.fromLTRB(gx1 - 1, gy - th * 0.80, gx2 + 1, gy - th * 0.70), stone);

    // Colonnade à chapiteaux papyriformes
    final double ch = h * 0.10;
    for (int i = 0; i < 5; i++) {
      final double x = w * (0.585 + 0.034 * i);
      canvas.drawRect(Rect.fromLTWH(x, gy - ch, w * 0.014, ch), stone);
      final double lx = litLeft ? x : x + w * 0.0095;
      canvas.drawRect(Rect.fromLTWH(lx, gy - ch, w * 0.0045, ch), stoneLit);
      canvas.drawPath(
          Path()
            ..moveTo(x - w * 0.004, gy - ch)
            ..quadraticBezierTo(x + w * 0.007, gy - ch - h * 0.018,
                x + w * 0.018, gy - ch)
            ..close(),
          stone);
    }
    canvas.drawRect(
        Rect.fromLTWH(w * 0.580, gy - ch - h * 0.024, w * 0.158, h * 0.012),
        stone);
    canvas.drawRect(
        Rect.fromLTWH(w * 0.576, gy - ch - h * 0.031, w * 0.166, h * 0.007),
        stoneLit);

    // Obélisque au sommet doré
    final double ox = w * 0.545;
    final double ow = w * 0.018;
    final double oh = h * 0.19;
    canvas.drawPath(
        Path()
          ..moveTo(ox, gy)
          ..lineTo(ox + ow * 0.15, gy - oh)
          ..lineTo(ox + ow * 0.85, gy - oh)
          ..lineTo(ox + ow, gy)
          ..close(),
        stone);
    canvas.drawPath(
        Path()
          ..moveTo(ox + ow * 0.15, gy - oh)
          ..lineTo(ox + ow * 0.5, gy - oh - ow * 0.7)
          ..lineTo(ox + ow * 0.85, gy - oh)
          ..close(),
        Paint()..color = Color.lerp(p.lit, _gold, 0.6)!);
  }

  void _palm(Canvas canvas, double x, double base, double ht, Color col,
      double sway) {
    final Paint trunk = Paint()..color = col;
    final Offset tp = Offset(x + ht * 0.12, base - ht);
    canvas.drawPath(
        Path()
          ..moveTo(x - ht * 0.02, base)
          ..quadraticBezierTo(x + ht * 0.02, base - ht * 0.5, tp.dx - 1.5, tp.dy)
          ..lineTo(tp.dx + 2, tp.dy)
          ..quadraticBezierTo(x + ht * 0.06, base - ht * 0.5, x + ht * 0.02, base)
          ..close(),
        trunk);
    final Paint frond = Paint()
      ..color = col
      ..style = PaintingStyle.stroke
      ..strokeWidth = ht * 0.026
      ..strokeCap = StrokeCap.round;
    for (int k = 0; k < 9; k++) {
      final double a = pi + (k + 0.5) * pi / 9;
      final Offset d = Offset(cos(a), sin(a));
      final Offset end = tp + d * ht * 0.36 + Offset(sway, ht * 0.14);
      final Offset ctl = tp + d * ht * 0.20 + Offset(0, -ht * 0.08);
      canvas.drawPath(
          Path()
            ..moveTo(tp.dx, tp.dy)
            ..quadraticBezierTo(ctl.dx, ctl.dy, end.dx, end.dy),
          frond);
    }
  }

  // Felouque aux voiles latines : entre à l'aube, traverse le fleuve, repart
  // au bout d'un cycle complet.
  void _boat(Canvas canvas, double w, double h, double t, _Pal p, double night) {
    final double bl = w * 0.40;
    final double x = -bl * 1.05 + (w + bl * 1.25) * t;
    final double wy = h * 0.805 + _osc(t, 38) * 1.4;
    final double day = 1 - night;

    final Color hull = Color.lerp(p.sil, const Color(0xFF8A5634), 0.55 * day)!;
    final Color sail = Color.lerp(p.lit, Colors.white, 0.15 + 0.40 * day)!;
    final Color sailShade = Color.lerp(p.shade, p.lit, 0.45)!;

    // Reflets
    final Rect refl = Rect.fromLTRB(x + bl * 0.05, wy, x + bl * 0.95, wy + bl * 0.22);
    canvas.drawRect(
        refl,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [hull.withOpacity(0.55), hull.withOpacity(0)],
          ).createShader(refl));
    final Rect rs = Rect.fromLTRB(x + bl * 0.2, wy + 2, x + bl * 0.85, wy + bl * 0.34);
    canvas.drawRect(
        rs,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [sail.withOpacity(0.18), sail.withOpacity(0)],
          ).createShader(rs));

    // Léger roulis
    canvas.save();
    final Offset pivot = Offset(x + bl * 0.5, wy);
    canvas.translate(pivot.dx, pivot.dy);
    canvas.rotate(_osc(t, 30, 1.0) * 0.012);
    canvas.translate(-pivot.dx, -pivot.dy);

    void sailAt(double ox, double scale) {
      final double sbl = bl * scale;
      final Path sp = Path()
        ..moveTo(x + ox, wy - sbl * 0.08)
        ..quadraticBezierTo(x + ox + sbl * 0.18, wy - sbl * 0.42,
            x + ox + sbl * 0.46, wy - sbl * 0.78)
        ..quadraticBezierTo(x + ox + sbl * 0.70, wy - sbl * 0.38,
            x + ox + sbl * 0.84, wy - sbl * 0.10)
        ..quadraticBezierTo(
            x + ox + sbl * 0.45, wy - sbl * 0.02, x + ox, wy - sbl * 0.08)
        ..close();
      final Rect box =
      Rect.fromLTWH(x + ox, wy - sbl * 0.78, sbl * 0.84, sbl * 0.7);
      canvas.drawPath(
          sp,
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [sail, sailShade],
            ).createShader(box));
      final Paint wood = Paint()
        ..color = hull
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(x + ox - sbl * 0.03, wy - sbl * 0.07),
          Offset(x + ox + sbl * 0.50, wy - sbl * 0.82), wood);
      canvas.drawLine(Offset(x + ox + sbl * 0.45, wy - sbl * 0.02),
          Offset(x + ox + sbl * 0.45, wy - sbl * 0.40), wood);
    }

    sailAt(bl * 0.30, 0.72);
    sailAt(bl * 0.06, 1.0);

    // Coque, proue relevée
    canvas.drawPath(
        Path()
          ..moveTo(x, wy - bl * 0.08)
          ..quadraticBezierTo(x + bl * 0.5, wy + bl * 0.12, x + bl, wy - bl * 0.15)
          ..lineTo(x + bl * 0.965, wy - bl * 0.15)
          ..quadraticBezierTo(
              x + bl * 0.5, wy - bl * 0.01, x + bl * 0.03, wy - bl * 0.08)
          ..close(),
        Paint()..color = hull);
    canvas.drawPath(
        Path()
          ..moveTo(x + bl * 0.03, wy - bl * 0.08)
          ..quadraticBezierTo(
              x + bl * 0.5, wy - bl * 0.01, x + bl * 0.965, wy - bl * 0.15),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6
          ..color = _gold.withOpacity(0.95));

    // Lanterne à la proue
    if (night > 0.02) {
      final Offset lp = Offset(x + bl * 0.93, wy - bl * 0.19);
      canvas.drawCircle(
          lp,
          22,
          Paint()
            ..shader = RadialGradient(colors: [
              _gold.withOpacity(0.8 * night),
              _gold.withOpacity(0),
            ]).createShader(Rect.fromCircle(center: lp, radius: 22)));
    }
    canvas.restore();

    // Sillage
    final Paint wake = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withOpacity(0.36);
    canvas.drawPath(
        Path()
          ..moveTo(x + bl * 0.02, wy)
          ..quadraticBezierTo(x - bl * 0.10, wy + 5, x - bl * 0.30, wy + 2),
        wake);
    canvas.drawPath(
        Path()
          ..moveTo(x + bl * 0.05, wy + 3)
          ..quadraticBezierTo(x - bl * 0.10, wy + 12, x - bl * 0.36, wy + 9),
        wake..color = Colors.white.withOpacity(0.16));
  }

  // Poussière d'or, visible tant que le soleil éclaire
  void _dust(Canvas canvas, double w, double h, double t, double sunElev) {
    final double a = (sunElev * 6).clamp(0.0, 1.0) * (0.4 + 0.6 * (1 - sunElev));
    if (a < 0.02) return;
    final Paint dp = Paint();
    for (final _Pt m in _motes) {
      final int k = (m.a * 3).floor().clamp(1, 3);
      final double x = w * ((m.x + t * k) % 1.0);
      final double y = h * (0.10 + m.y * 0.55) + _osc(t, k + 2, m.a * 6) * 9;
      final double tw = 0.4 + 0.6 * _osc(t, 30 + k, m.x * 20).abs();
      dp.color = _gold.withOpacity((0.40 * tw * a).clamp(0.0, 1.0));
      canvas.drawCircle(Offset(x, y), m.s * 0.7, dp);
    }
  }

  void _birds(Canvas canvas, double w, double h, double t, _Pal p, double sunElev) {
    final double a = ((sunElev - 0.1) * 3).clamp(0.0, 1.0);
    if (a < 0.02) return;
    final Paint bp = Paint()
      ..color = p.sil.withOpacity(0.8 * a)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < 5; i++) {
      final double x = w * (((t * 1.2 + i * 0.13) % 1.2) - 0.1);
      final double y = h * (0.22 + i * 0.03) + _osc(t, 12, i.toDouble()) * 5;
      final double f = _osc(t, 75, i.toDouble()) * 2.5;
      canvas.drawPath(
          Path()
            ..moveTo(x - 6, y - f)
            ..quadraticBezierTo(x - 3, y - 4 + f, x, y)
            ..quadraticBezierTo(x + 3, y - 4 + f, x + 6, y - f),
          bp);
    }
  }

  @override
  bool shouldRepaint(covariant _NileScenePainter old) => old.anim != anim;
}
