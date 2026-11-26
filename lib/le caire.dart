import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show FontFeature, ImageFilter;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

// ═════════════════════════════════════════════════════════════
//  PALETTE « MINUIT & OR » : noir bleuté, verre dépoli, or chaud
// ═════════════════════════════════════════════════════════════
class _C {
  // Fonds
  static const bg = Color(0xFF090A0F);
  static const surface = Color(0xFF13151C);
  static const surfaceHi = Color(0xFF1B1E28);

  // Textes
  static const text = Color(0xFFF6F4EF);
  static const textSoft = Color(0xFFA4A8B4);
  static const textDim = Color(0xFF6C707D);

  // Or
  static const gold = Color(0xFFE9BC6E);
  static const goldLight = Color(0xFFF7DDA4);
  static const goldDeep = Color(0xFFC08A35);
  static const onGold = Color(0xFF1A1206);

  // Ciel (carte du soleil)
  static const night = Color(0xFF0B1226);
  static const day = Color(0xFF3A5280);
  static const glow = Color(0xFF9A5A1E);

  // États du quiz
  static const good = Color(0xFF5CCB9B);
  static const bad = Color(0xFFEE6A6A);

  // Filets très fins
  static const line = Color(0x1AFFFFFF);

  static const LinearGradient goldGrad = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[goldLight, gold, goldDeep],
  );
}

class WebScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
  };
}

// ═════════════════════════════════════════════════════════════
//  STYLES
// ═════════════════════════════════════════════════════════════
double _ls(BuildContext c, double v) =>
    Directionality.of(c) == TextDirection.rtl ? 0 : v;

/// Titres : sans-serif épaisse, serrée.
TextStyle _display(BuildContext c, double size,
    {Color color = _C.text,
      FontWeight weight = FontWeight.w700,
      double height = 1.12,
      double ls = -0.6}) =>
    TextStyle(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: _ls(c, ls),
    );

/// Petites étiquettes.
TextStyle _label(BuildContext c,
    {double size = 11.5,
      Color color = _C.textSoft,
      double ls = 0.8,
      FontWeight weight = FontWeight.w600}) =>
    TextStyle(
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: _ls(c, ls),
    );

TextStyle _body(double size,
    {Color color = _C.text,
      double height = 1.6,
      FontWeight weight = FontWeight.w400}) =>
    TextStyle(fontSize: size, color: color, height: height, fontWeight: weight);

/// Chiffres : largeur fixe pour que les horloges ne « tremblent » pas.
TextStyle _num(double size,
    {Color color = _C.text,
      FontWeight weight = FontWeight.w600,
      double ls = 0}) =>
    TextStyle(
      fontSize: size,
      color: color,
      fontWeight: weight,
      letterSpacing: ls,
      height: 1.05,
      fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
    );

// ═════════════════════════════════════════════════════════════
//  HEURE DU CAIRE ET CALCUL DU SOLEIL
// ═════════════════════════════════════════════════════════════

/// Heure d'été égyptienne (depuis 2023) : du dernier vendredi d'avril
/// au dernier jeudi d'octobre, en UTC+3. Sinon UTC+2.
bool _egyptDst(DateTime utc) {
  DateTime lastOf(int month, int weekday) {
    var d = DateTime.utc(utc.year, month + 1, 0);
    while (d.weekday != weekday) {
      d = d.subtract(const Duration(days: 1));
    }
    return d;
  }

  final DateTime start = lastOf(4, DateTime.friday);
  final DateTime end =
  lastOf(10, DateTime.thursday).add(const Duration(days: 1));
  return utc.isAfter(start) && utc.isBefore(end);
}

/// Convertit un instant UTC en heure locale du Caire (fields = heure locale).
DateTime _toCairo(DateTime utc) =>
    utc.add(Duration(hours: _egyptDst(utc) ? 3 : 2));

String _two(int v) => v.toString().padLeft(2, '0');

String _hm(DateTime utc) {
  final DateTime c = _toCairo(utc);
  return '${_two(c.hour)}:${_two(c.minute)}';
}

String _hms(Duration d) {
  final int s = d.inSeconds < 0 ? 0 : d.inSeconds;
  return '${_two(s ~/ 3600)}:${_two((s % 3600) ~/ 60)}:${_two(s % 60)}';
}

class _SunDay {
  final DateTime rise; // instant UTC
  final DateTime set; // instant UTC
  const _SunDay(this.rise, this.set);
}

/// Lever et coucher du soleil au Caire pour une date (algorithme solaire
/// simplifié, précision de quelques minutes).
_SunDay _sunDay(DateTime cairoDate) {
  const double latDeg = 30.0444;
  const double lonDeg = 31.2357;
  final double lat = latDeg * math.pi / 180;
  final DateTime d =
  DateTime.utc(cairoDate.year, cairoDate.month, cairoDate.day);
  final int n = d.difference(DateTime.utc(d.year, 1, 1)).inDays + 1;
  final double g = 2 * math.pi / 365 * (n - 1);
  final double eqTime = 229.18 *
      (0.000075 +
          0.001868 * math.cos(g) -
          0.032077 * math.sin(g) -
          0.014615 * math.cos(2 * g) -
          0.040849 * math.sin(2 * g));
  final double decl = 0.006918 -
      0.399912 * math.cos(g) +
      0.070257 * math.sin(g) -
      0.006758 * math.cos(2 * g) +
      0.000907 * math.sin(2 * g) -
      0.002697 * math.cos(3 * g) +
      0.00148 * math.sin(3 * g);
  final double zen = 90.833 * math.pi / 180;
  final double cosHa = (math.cos(zen) / (math.cos(lat) * math.cos(decl))) -
      math.tan(lat) * math.tan(decl);
  final double haDeg = math.acos(cosHa.clamp(-1.0, 1.0)) * 180 / math.pi;
  final double riseMin = 720 - 4 * (lonDeg + haDeg) - eqTime;
  final double setMin = 720 - 4 * (lonDeg - haDeg) - eqTime;
  return _SunDay(
    d.add(Duration(seconds: (riseMin * 60).round())),
    d.add(Duration(seconds: (setMin * 60).round())),
  );
}

class _Golden {
  final bool live; // heure dorée en cours
  final Duration until; // temps avant la prochaine heure dorée
  final _SunDay today;
  final double dayP; // 0 → 1 entre lever et coucher, -1 la nuit
  const _Golden(this.live, this.until, this.today, this.dayP);
}

_Golden _goldenNow(DateTime nowUtc) {
  final DateTime cairo = _toCairo(nowUtc);
  final _SunDay today = _sunDay(cairo);
  final _SunDay tomorrow = _sunDay(cairo.add(const Duration(days: 1)));
  final DateTime goldToday = today.set.subtract(const Duration(hours: 1));
  final bool isDay =
      !nowUtc.isBefore(today.rise) && nowUtc.isBefore(today.set);
  final double dayP = isDay
      ? nowUtc.difference(today.rise).inSeconds /
      today.set.difference(today.rise).inSeconds
      : -1;
  if (isDay && !nowUtc.isBefore(goldToday)) {
    return _Golden(true, Duration.zero, today, dayP);
  }
  final DateTime nextGold = nowUtc.isBefore(goldToday)
      ? goldToday
      : tomorrow.set.subtract(const Duration(hours: 1));
  return _Golden(false, nextGold.difference(nowUtc), today, dayP);
}

/// Couleur de la carte du soleil : nuit bleue, lueur chaude à l'aube et au
/// crépuscule, bleu profond en plein jour, ambre pendant l'heure dorée.
Color _solarColor(_Golden g, DateTime nowUtc) {
  if (g.dayP < 0) {
    final int mins = math.min(
      nowUtc.difference(g.today.set).inMinutes.abs(),
      nowUtc.difference(g.today.rise).inMinutes.abs(),
    );
    final double glow = (1 - mins / 50).clamp(0.0, 1.0);
    return Color.lerp(_C.night, _C.glow, glow * 0.8)!;
  }
  final double sunHigh = math.sin(math.pi * g.dayP);
  final Color base = Color.lerp(const Color(0xFF1B2440), _C.day, sunHigh)!;
  return g.live ? Color.lerp(base, _C.glow, 0.85)! : base;
}

enum _OptState { idle, right, wrong, faded }

// ═════════════════════════════════════════════════════════════
//  PETITS COMPOSANTS
// ═════════════════════════════════════════════════════════════

/// Effet « ressort » discret quand on appuie : rend tout tactile et vivant.
class _Press extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  const _Press({required this.child, this.onTap, this.scale = 0.96});

  @override
  State<_Press> createState() => _PressState();
}

class _PressState extends State<_Press> {
  bool _down = false;

  void _set(bool v) {
    if (_down != v) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _set(true),
      onTapUp: (_) => _set(false),
      onTapCancel: () => _set(false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? widget.scale : 1,
        duration: const Duration(milliseconds: 130),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}

/// Verre dépoli : flou de l'arrière-plan + voile + filet lumineux.
class _Glass extends StatelessWidget {
  final Widget child;
  final double radius;
  final EdgeInsetsGeometry padding;
  final double blur;
  final Color tint;
  final double? width;
  final double? height;
  const _Glass({
    required this.child,
    this.radius = 20,
    this.padding = EdgeInsets.zero,
    this.blur = 18,
    this.tint = const Color(0x4D000000),
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: tint,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: const Color(0x26FFFFFF), width: 0.8),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Bouton rond (retour, favori…) : verre sur les photos, plein ailleurs.
class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool active;
  final bool solid;
  final double size;
  const _CircleBtn({
    required this.icon,
    required this.onTap,
    this.active = false,
    this.solid = false,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    final Widget ic = AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      transitionBuilder: (Widget c, Animation<double> a) =>
          ScaleTransition(scale: a, child: c),
      child: Icon(
        icon,
        key: ValueKey<IconData>(icon),
        color: active ? _C.gold : _C.text,
        size: size * 0.46,
      ),
    );
    return _Press(
      onTap: onTap,
      child: solid
          ? Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _C.surfaceHi,
          border: Border.all(color: _C.line),
        ),
        child: ic,
      )
          : _Glass(
        radius: size / 2,
        width: size,
        height: size,
        child: Center(child: ic),
      ),
    );
  }
}

/// Bouton principal doré (ou secondaire sombre).
class _GoldButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool filled;
  final double height;
  const _GoldButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.filled = true,
    this.height = 58,
  });

  @override
  Widget build(BuildContext context) {
    final Color fg = filled ? _C.onGold : _C.text;
    return _Press(
      onTap: onTap,
      child: Container(
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          gradient: filled ? _C.goldGrad : null,
          color: filled ? null : _C.surfaceHi,
          borderRadius: BorderRadius.circular(20),
          border: filled ? null : Border.all(color: _C.line),
          boxShadow: filled
              ? <BoxShadow>[
            BoxShadow(
              color: _C.gold.withOpacity(0.28),
              blurRadius: 26,
              offset: const Offset(0, 10),
            ),
          ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, color: fg, size: 21),
            const SizedBox(width: 10),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  softWrap: false,
                  style: TextStyle(
                    color: fg,
                    fontWeight: FontWeight.w700,
                    fontSize: 15.5,
                    letterSpacing: _ls(context, 0.2),
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

/// Zoom très lent sur la photo (effet « cinéma »).
class _KenBurns extends StatefulWidget {
  final Widget child;
  const _KenBurns({required this.child});

  @override
  State<_KenBurns> createState() => _KenBurnsState();
}

class _KenBurnsState extends State<_KenBurns>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 16),
  )..forward();
  late final Animation<double> _a =
  CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: AnimatedBuilder(
        animation: _a,
        child: widget.child,
        builder: (BuildContext _, Widget? ch) =>
            Transform.scale(scale: 1.12 - 0.12 * _a.value, child: ch),
      ),
    );
  }
}

/// Image d'un lieu, avec repli élégant si le fichier manque.
class _PlaceImage extends StatelessWidget {
  final String path;
  const _PlaceImage(this.path);

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      path,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[_C.surfaceHi, _C.surface],
          ),
        ),
        child: Center(
          child: Icon(Icons.landscape_rounded, color: _C.textDim, size: 40),
        ),
      ),
    );
  }
}

/// Titre de section : barre dorée, titre, pastille de compteur.
class _SectionHeader extends StatelessWidget {
  final String title;
  final String count;
  const _SectionHeader({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 30, 0, 16),
      child: Row(
        children: <Widget>[
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              gradient: _C.goldGrad,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title, style: _display(context, 24, ls: -0.5)),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _C.surface,
              borderRadius: BorderRadius.circular(99),
              border: Border.all(color: _C.line),
            ),
            child: Text(count,
                style: _label(context, size: 12, color: _C.textSoft, ls: 0.2)),
          ),
        ],
      ),
    );
  }
}

/// Titre de bloc dans la fiche détaillée.
class _DetailLabel extends StatelessWidget {
  final String text;
  const _DetailLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            gradient: _C.goldGrad,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: _display(context, 21, ls: -0.4))),
      ],
    );
  }
}

/// Arc du soleil : l'astre glisse de l'est à l'ouest, le trajet parcouru
/// se colore en or.
class _ArcPainter extends CustomPainter {
  final double dayP;
  const _ArcPainter(this.dayP);

  @override
  void paint(Canvas canvas, Size size) {
    final double r = math.min(size.width / 2 - 14, size.height - 16);
    final Offset c = Offset(size.width / 2, size.height - 6);
    final Rect rect = Rect.fromCircle(center: c, radius: r);

    final Paint track = Paint()
      ..color = Colors.white.withOpacity(0.13)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawArc(rect, math.pi, math.pi, false, track);
    canvas.drawLine(
      Offset(0, c.dy),
      Offset(size.width, c.dy),
      Paint()
        ..color = Colors.white.withOpacity(0.10)
        ..strokeWidth = 1,
    );

    if (dayP >= 0) {
      final Paint done = Paint()
        ..color = _C.gold
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      canvas.drawArc(rect, math.pi, math.pi * dayP, false, done);

      final double a = math.pi + dayP * math.pi;
      final Offset s = c + Offset(math.cos(a), math.sin(a)) * r;
      canvas.drawCircle(s, 20, Paint()..color = _C.gold.withOpacity(0.14));
      canvas.drawCircle(s, 12, Paint()..color = _C.gold.withOpacity(0.28));
      canvas.drawCircle(s, 6.5, Paint()..color = _C.goldLight);
    }
  }

  @override
  bool shouldRepaint(covariant _ArcPainter old) => old.dayP != dayP;
}

/// Anneau de progression du minuteur.
class _RingPainter extends CustomPainter {
  final double progress; // 0 → 1
  const _RingPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    const double stroke = 12;
    final Offset c = size.center(Offset.zero);
    final double r = math.min(size.width, size.height) / 2 - stroke / 2;
    final Rect rect = Rect.fromCircle(center: c, radius: r);

    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = Colors.white.withOpacity(0.07)
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke,
    );

    final double p = progress.clamp(0.0, 1.0).toDouble();
    if (p <= 0) return;
    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * p,
      false,
      Paint()
        ..shader = const SweepGradient(
          startAngle: 0,
          endAngle: 2 * math.pi,
          colors: <Color>[_C.goldDeep, _C.gold, _C.goldLight, _C.goldDeep],
          transform: GradientRotation(-math.pi / 2),
        ).createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = stroke,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) => old.progress != progress;
}

Widget _timeCell(
    BuildContext c, IconData icon, String label, String time) {
  return Row(
    children: <Widget>[
      Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.09),
        ),
        child: Icon(icon, color: _C.goldLight, size: 17),
      ),
      const SizedBox(width: 10),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: _label(c, size: 11.5, ls: 0.2)),
          const SizedBox(height: 3),
          Text(time, style: _num(20, weight: FontWeight.w700)),
        ],
      ),
    ],
  );
}

/// Bloc « Heure dorée » : compte à rebours, arc du soleil, lever et coucher.
class _SolarPanel extends StatelessWidget {
  final DateTime nowUtc;
  final _Golden g;
  final String goldenLabel;
  final String nowLabel;
  final String sunriseLabel;
  final String sunsetLabel;
  const _SolarPanel({
    required this.nowUtc,
    required this.g,
    required this.goldenLabel,
    required this.nowLabel,
    required this.sunriseLabel,
    required this.sunsetLabel,
  });

  @override
  Widget build(BuildContext context) {
    final Color base = _solarColor(g, nowUtc);
    final Color end = Color.lerp(base, _C.bg, 0.62)!;
    final String big = g.live ? nowLabel : _hms(g.until);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: Container(
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[base, end],
          ),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: _C.line),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: base.withOpacity(0.35),
              blurRadius: 40,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _C.gold.withOpacity(0.16),
                  ),
                  child: const Icon(Icons.wb_twilight_rounded,
                      color: _C.goldLight, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    goldenLabel,
                    style: _label(context,
                        size: 14, color: _C.text.withOpacity(0.82), ls: 0.1),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: Text(big,
                  softWrap: false,
                  style: _num(52, weight: FontWeight.w700, ls: -1.5)),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 80,
              width: double.infinity,
              child: CustomPaint(painter: _ArcPainter(g.dayP)),
            ),
            const SizedBox(height: 18),
            Row(
              children: <Widget>[
                Expanded(
                  child: _timeCell(context, Icons.arrow_upward_rounded,
                      sunriseLabel, _hm(g.today.rise)),
                ),
                Expanded(
                  child: _timeCell(context, Icons.arrow_downward_rounded,
                      sunsetLabel, _hm(g.today.set)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Grande carte photo d'un lieu : catégorie, cœur, nom, flèche.
class _PlaceCard extends StatelessWidget {
  final int number;
  final String name;
  final String sub;
  final String photo;
  final bool stamped;
  final bool fav;
  final VoidCallback onFav;
  final VoidCallback onTap;

  const _PlaceCard({
    required this.number,
    required this.name,
    required this.sub,
    required this.photo,
    required this.stamped,
    required this.fav,
    required this.onFav,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _Press(
      onTap: onTap,
      scale: 0.975,
      child: Container(
        height: 232,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: _C.line),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withOpacity(0.45),
              blurRadius: 32,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(29),
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              _PlaceImage(photo),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[
                      Colors.black.withOpacity(0.30),
                      Colors.transparent,
                      Colors.black.withOpacity(0.35),
                      Colors.black.withOpacity(0.86),
                    ],
                    stops: const <double>[0, 0.30, 0.58, 1],
                  ),
                ),
              ),
              PositionedDirectional(
                top: 14,
                start: 14,
                end: 14,
                child: Row(
                  children: <Widget>[
                    Flexible(
                      child: _Glass(
                        radius: 99,
                        blur: 14,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 7),
                        child: Text(
                          sub,
                          style: _label(context,
                              size: 12, color: _C.text, ls: 0.1),
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (stamped) ...<Widget>[
                      Container(
                        width: 34,
                        height: 34,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: _C.goldGrad,
                        ),
                        child: const Icon(Icons.check_rounded,
                            size: 19, color: _C.onGold),
                      ),
                      const SizedBox(width: 8),
                    ],
                    _CircleBtn(
                      icon: fav
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      active: fav,
                      size: 38,
                      onTap: onFav,
                    ),
                  ],
                ),
              ),
              PositionedDirectional(
                bottom: 18,
                start: 20,
                end: 18,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            number.toString().padLeft(2, '0'),
                            style: _num(13,
                                color: _C.gold,
                                weight: FontWeight.w700,
                                ls: 1.5),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            name,
                            style: _display(context, 26, height: 1.08, ls: -0.8),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.16),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.22), width: 0.8),
                      ),
                      child: Icon(
                        Directionality.of(context) == TextDirection.rtl
                            ? Icons.north_west_rounded
                            : Icons.north_east_rounded,
                        color: _C.text,
                        size: 20,
                      ),
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

/// Barre de filtres épinglée, en verre dépoli.
class _FilterDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double topPad;
  _FilterDelegate({required this.child, required this.topPad});

  @override
  double get minExtent => 68 + topPad;

  @override
  double get maxExtent => 68 + topPad;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 68 + topPad,
          padding: EdgeInsets.only(top: topPad),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _C.bg.withOpacity(0.86),
            border: const Border(
              bottom: BorderSide(color: Color(0x0FFFFFFF), width: 0.8),
            ),
          ),
          child: SizedBox(height: 40, child: child),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _FilterDelegate oldDelegate) => true;
}

/// Réponse du quiz : pastille-lettre, texte, état.
class _OptionTile extends StatelessWidget {
  final String letter;
  final String label;
  final _OptState state;
  final VoidCallback onTap;
  const _OptionTile({
    required this.letter,
    required this.label,
    required this.state,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool right = state == _OptState.right;
    final bool wrong = state == _OptState.wrong;
    final Color accent = right ? _C.good : (wrong ? _C.bad : _C.gold);
    final Color fill = right
        ? _C.good.withOpacity(0.12)
        : wrong
        ? _C.bad.withOpacity(0.12)
        : _C.surface;
    final Color stroke = right
        ? _C.good.withOpacity(0.75)
        : wrong
        ? _C.bad.withOpacity(0.75)
        : _C.line;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 250),
      opacity: state == _OptState.faded ? 0.4 : 1,
      child: _Press(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          constraints: const BoxConstraints(minHeight: 66),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: stroke, width: right || wrong ? 1.2 : 0.8),
          ),
          child: Row(
            children: <Widget>[
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: right || wrong ? accent : _C.surfaceHi,
                ),
                child: right || wrong
                    ? Icon(
                  right ? Icons.check_rounded : Icons.close_rounded,
                  color: _C.onGold,
                  size: 20,
                )
                    : Text(letter,
                    style: _label(context,
                        size: 14, color: _C.gold, weight: FontWeight.w700)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: _display(context, 17.5,
                      weight: FontWeight.w600, height: 1.2, ls: -0.2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Vignette d'un lieu lié, dans la fiche détaillée.
class _RelatedTile extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onTap;
  const _RelatedTile({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return _Press(
      onTap: onTap,
      child: Container(
        width: 184,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: _C.line),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              _PlaceImage(item['photo_url'] as String? ?? ''),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[
                      Colors.transparent,
                      Colors.black.withOpacity(0.85),
                    ],
                    stops: const <double>[0.35, 1],
                  ),
                ),
              ),
              PositionedDirectional(
                start: 14,
                end: 14,
                bottom: 14,
                child: Text(
                  '${item['name']}',
                  style: _display(context, 16.5, height: 1.15, ls: -0.3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Un point fort : pastille numérotée dorée, titre, texte.
class _HighlightCard extends StatelessWidget {
  final int number;
  final String title;
  final String desc;
  const _HighlightCard(
      {required this.number, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _C.line),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _C.gold.withOpacity(0.13),
              border: Border.all(color: _C.gold.withOpacity(0.35), width: 0.8),
            ),
            child: Text('$number',
                style: _num(15, color: _C.gold, weight: FontWeight.w700)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: _display(context, 17, height: 1.2, ls: -0.3)),
                const SizedBox(height: 6),
                Text(desc, style: _body(14.5, color: _C.textSoft, height: 1.6)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Case d'information de la fiche (durée, meilleur moment).
class _MetaTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _MetaTile(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _C.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: _C.gold.withOpacity(0.13),
            ),
            child: Icon(icon, color: _C.gold, size: 19),
          ),
          const SizedBox(height: 14),
          Text(label, style: _label(context, size: 12, ls: 0.1)),
          const SizedBox(height: 4),
          Text(value,
              style: _display(context, 16, height: 1.25, ls: -0.2)),
        ],
      ),
    );
  }
}

/// Pied de page discret.
class _Footer extends StatelessWidget {
  final String title;
  const _Footer({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 60),
      child: Column(
        children: <Widget>[
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              gradient: _C.goldGrad,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 22),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              title,
              softWrap: false,
              style: _display(context, 64,
                  color: Colors.white.withOpacity(0.07),
                  weight: FontWeight.w800,
                  ls: -2.5),
            ),
          ),
          const SizedBox(height: 8),
          Text('30.04°N · 31.24°E',
              style: _num(12, color: _C.textDim, ls: 1.4)),
        ],
      ),
    );
  }
}

/// En-tête : photo plein cadre, sélecteur de langue, titre, statut en direct.
class _Masthead extends StatelessWidget {
  final double height;
  final double topPad;
  final String title;
  final String tagline;
  final String countText;
  final String Function(DateTime) liveLine;
  final ValueListenable<DateTime> tick;
  final Widget langs;
  const _Masthead({
    required this.height,
    required this.topPad,
    required this.title,
    required this.tagline,
    required this.countText,
    required this.liveLine,
    required this.tick,
    required this.langs,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          _KenBurns(child: const _PlaceImage('assets/caire/pyramide.jpg')),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  Colors.black.withOpacity(0.55),
                  Colors.black.withOpacity(0.0),
                  _C.bg.withOpacity(0.75),
                  _C.bg,
                ],
                stops: const <double>[0, 0.30, 0.78, 1],
              ),
            ),
          ),
          PositionedDirectional(
            top: topPad + 12,
            start: 20,
            end: 20,
            child: Row(
              children: <Widget>[
                Flexible(
                  child: _Glass(
                    radius: 99,
                    blur: 14,
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const Icon(Icons.place_rounded,
                            color: _C.gold, size: 15),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text('30.04°N · 31.24°E',
                              style: _num(12,
                                  color: _C.text, weight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                langs,
              ],
            ),
          ),
          PositionedDirectional(
            start: 20,
            end: 20,
            bottom: 18,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _C.gold.withOpacity(0.16),
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(
                        color: _C.gold.withOpacity(0.45), width: 0.8),
                  ),
                  child: Text(countText,
                      style: _label(context,
                          size: 12.5, color: _C.goldLight, ls: 0.3)),
                ),
                const SizedBox(height: 14),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    title,
                    softWrap: false,
                    style: _display(context, 68,
                        weight: FontWeight.w800, height: 1.0, ls: -2.6),
                  ),
                ),
                const SizedBox(height: 10),
                Text(tagline,
                    style: _body(17, color: _C.text.withOpacity(0.78), height: 1.35)),
                const SizedBox(height: 18),
                ValueListenableBuilder<DateTime>(
                  valueListenable: tick,
                  builder: (BuildContext c, DateTime now, Widget? _) => _Glass(
                    radius: 99,
                    blur: 14,
                    padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _C.gold,
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: _C.gold.withOpacity(0.7),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(liveLine(now),
                              style: _label(c,
                                  size: 13, color: _C.text, ls: 0.1)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════
//  PAGE PRINCIPALE
// ═════════════════════════════════════════════════════════════
class LeCairePage extends StatefulWidget {
  const LeCairePage({super.key});

  @override
  State<LeCairePage> createState() => _LeCairePageState();
}

class _LeCairePageState extends State<LeCairePage> {
  final ScrollController _scroll = ScrollController();
  final ValueNotifier<DateTime> _tick =
  ValueNotifier<DateTime>(DateTime.now().toUtc());
  Timer? _clock;

  String _lang = 'fr';
  String _filter = 'all'; // 'all' | 'fav' | clé de catégorie
  Set<String> _favs = <String>{};
  Set<String> _stamps = <String>{};
  int _visitMinutes = 0;
  bool _goldenNotified = false;

  // ───────────── Traductions et données (inchangées) ─────────────
  // --- TRADUCTIONS DE L'INTERFACE ---
  static const Map<String, Map<String, String>> _uiTranslations = {
    'fr': {
      'pageTitle': 'Le Caire',
      'tagline': 'La ville aux mille minarets',
      'places': 'lieux',
      'all': 'Tout',
      'favs': 'Favoris',
      'noFav': 'Aucun favori pour le moment.\nTouche le ♡ pour en ajouter.',
      'discover': 'Découvrir',
      'mapsBtn': 'Ouvrir dans Google Maps',
      'about': 'À propos',
      'overview': 'En bref',
      'duration': 'Durée conseillée',
      'bestTime': 'Meilleur moment',
      'category': 'Catégorie',
      'highlights': 'Points forts',
      'didYouKnow': 'Le saviez-vous ?',
      'tip': 'Conseil du voyageur',
      'seeAlso': 'À voir aussi',
      'catMonuments': 'Monuments',
      'catMarkets': 'Marchés traditionnels',
      'catHistory': 'Lieux historiques',
      'catArch': 'Architecture',
      'catRelaxation': 'Lieux de détente',
      'catActivities': 'Activités au Caire',
      'phaseDawn': 'Aube',
      'phaseDay': 'Journée',
      'phaseDusk': 'Heure dorée',
      'phaseNight': 'Nuit',
      'cairoTime': 'Il est {t} au Caire',
      'passport': 'Passeport',
      'passportCount': 'tampons',
      'stampAdd': 'J’y suis · tamponner',
      'stampDone': 'Tamponné · annuler',
      'dailyPick': 'Lieu du jour',
      'resetPassport': 'Remettre à zéro',
      'resetAsk': 'Effacer tous les tampons ?',
      'cancel': 'Annuler',
      'resetYes': 'Effacer',
      'goldenNow': 'En cours',
      'goldenIn': 'Heure dorée dans',
      'sunrise': 'Lever',
      'sunset': 'Coucher',
      'quizTitle': 'Devine le lieu',
      'quizIntro': 'Un fait, trois lieux. Trouve le bon.',
      'quizQ': 'De quel lieu parle ce fait ?',
      'score': 'Score',
      'streak': 'Série',
      'record': 'Record',
      'next': 'Suivant',
      'quizReset': 'Remettre à zéro',
      'quizResetAsk': 'Remettre le score, la série et le record à zéro ?',
      'rightAns': 'Bravo, c’est ça !',
      'wrongAns': 'Raté : c’était {n}',
      'visitTitle': 'Minuteur de visite',
      'start': 'Commencer',
      'stop': 'Arrêter',
      'visitDone': 'Visite terminée, bien joué !',
      'totalTime': 'Temps au Caire',
      'hUnit': 'h',
      'mUnit': 'min',
      'btnStamp': 'Tamponner',
      'btnStampDone': 'Tamponné',
      'btnTimer': 'Minuteur',
      'btnMaps': 'Itinéraire',
    },
    'en': {
      'pageTitle': 'Cairo',
      'tagline': 'The city of a thousand minarets',
      'places': 'places',
      'all': 'All',
      'favs': 'Favorites',
      'noFav': 'No favorites yet.\nTap the ♡ to add some.',
      'discover': 'Discover',
      'mapsBtn': 'Open in Google Maps',
      'about': 'About',
      'overview': 'At a glance',
      'duration': 'Suggested time',
      'bestTime': 'Best time',
      'category': 'Category',
      'highlights': 'Highlights',
      'didYouKnow': 'Did you know?',
      'tip': "Traveller's tip",
      'seeAlso': 'Also worth a visit',
      'catMonuments': 'Monuments',
      'catMarkets': 'Traditional Markets',
      'catHistory': 'Historical Sites',
      'catArch': 'Architecture',
      'catRelaxation': 'Relaxation Spots',
      'catActivities': 'Activities in Cairo',
      'phaseDawn': 'Dawn',
      'phaseDay': 'Daylight',
      'phaseDusk': 'Golden hour',
      'phaseNight': 'Night',
      'cairoTime': 'It is {t} in Cairo',
      'passport': 'Passport',
      'passportCount': 'stamps',
      'stampAdd': 'I was here · stamp it',
      'stampDone': 'Stamped · undo',
      'dailyPick': 'Pick of the day',
      'resetPassport': 'Reset',
      'resetAsk': 'Erase all stamps?',
      'cancel': 'Cancel',
      'resetYes': 'Erase',
      'goldenNow': 'Happening now',
      'goldenIn': 'Golden hour in',
      'sunrise': 'Sunrise',
      'sunset': 'Sunset',
      'quizTitle': 'Guess the place',
      'quizIntro': 'One fact, three places. Find the right one.',
      'quizQ': 'Which place does this fact describe?',
      'score': 'Score',
      'streak': 'Streak',
      'record': 'Record',
      'quizReset': 'Reset to zero',
      'quizResetAsk': 'Reset score, streak and record to zero?',
      'next': 'Next',
      'rightAns': 'Well done, that’s it!',
      'wrongAns': 'Missed: it was {n}',
      'visitTitle': 'Visit timer',
      'start': 'Start',
      'stop': 'Stop',
      'visitDone': 'Visit complete, well done!',
      'totalTime': 'Time in Cairo',
      'hUnit': 'h',
      'mUnit': 'min',
      'btnStamp': 'Stamp',
      'btnStampDone': 'Stamped',
      'btnTimer': 'Timer',
      'btnMaps': 'Directions',
    },
    'ar': {
      'pageTitle': 'القاهرة',
      'tagline': 'مدينة الألف مئذنة',
      'places': 'مكان',
      'all': 'الكل',
      'favs': 'المفضلة',
      'noFav': 'لا توجد أماكن مفضلة بعد.\nاضغط على ♡ للإضافة.',
      'discover': 'اكتشف',
      'mapsBtn': 'الفتح في خرائط Google',
      'about': 'نبذة',
      'overview': 'لمحة سريعة',
      'duration': 'المدة المقترحة',
      'bestTime': 'أفضل وقت',
      'category': 'الفئة',
      'highlights': 'أبرز المعالم',
      'didYouKnow': 'هل تعلم؟',
      'tip': 'نصيحة للمسافر',
      'seeAlso': 'اكتشف أيضًا',
      'catMonuments': 'المعالم الأثرية',
      'catMarkets': 'الأسواق التقليدية',
      'catHistory': 'الأماكن التاريخية',
      'catArch': 'العمارة',
      'catRelaxation': 'أماكن الاسترخاء',
      'catActivities': 'أنشطة في القاهرة',
      'phaseDawn': 'الفجر',
      'phaseDay': 'نهار',
      'phaseDusk': 'الساعة الذهبية',
      'phaseNight': 'الليل',
      'cairoTime': 'الساعة {t} في القاهرة',
      'passport': 'جواز السفر',
      'passportCount': 'أختام',
      'stampAdd': 'كنت هنا · ختم',
      'stampDone': 'تم الختم · تراجع',
      'dailyPick': 'مكان اليوم',
      'resetPassport': 'إعادة الضبط',
      'resetAsk': 'مسح كل الأختام؟',
      'cancel': 'إلغاء',
      'resetYes': 'مسح',
      'goldenNow': 'جارية الآن',
      'goldenIn': 'الساعة الذهبية بعد',
      'sunrise': 'الشروق',
      'sunset': 'الغروب',
      'quizTitle': 'خمّن المكان',
      'quizIntro': 'حقيقة واحدة، ثلاثة أماكن. اعثر على الصحيح.',
      'quizQ': 'عن أي مكان تتحدث هذه الحقيقة؟',
      'score': 'النتيجة',
      'streak': 'سلسلة',
      'record': 'الأفضل',
      'quizReset': 'إعادة التعيين إلى الصفر',
      'quizResetAsk': 'إعادة النتيجة والسلسلة والرقم القياسي إلى الصفر؟',
      'next': 'التالي',
      'rightAns': 'أحسنت، هذا صحيح!',
      'wrongAns': 'خطأ: كان {n}',
      'visitTitle': 'مؤقت الزيارة',
      'start': 'ابدأ',
      'stop': 'توقف',
      'visitDone': 'انتهت الزيارة، أحسنت!',
      'totalTime': 'الوقت في القاهرة',
      'hUnit': 'س',
      'mUnit': 'د',
      'btnStamp': 'ختم',
      'btnStampDone': 'تم الختم',
      'btnTimer': 'مؤقت',
      'btnMaps': 'الاتجاهات',
    },
  };

  // --- DONNÉES TRADUITES PAR LANGUE ---
  static const Map<String, List<Map<String, dynamic>>> _localizedCaireData = {
    'fr': [
      {
        "id": "tour_caire",
        "name": "La Tour du Caire",
        "sub_category_key": "catActivities",
        "sub_category": "Activités au Caire",
        "photo_url": "assets/caire/tour.jpg",
        "description": "Culminant à 187 mètres, la Tour du Caire est une icône moderne de la ville, véritable Tour Eiffel version égyptienne. Construite en béton armé sous la forme d'un moucharabieh, elle offre une plateforme d'observation à 360 degrés. C'est l'endroit idéal pour contempler l'immensité de la capitale, le méandre du Nil et, par temps clair, les pyramides de Gizeh à l'horizon.",
        "mapsQuery": "Tour du Caire"
      },
      {
        "id": "pyramides_gizeh",
        "name": "Pyramides de Gizeh",
        "sub_category_key": "catMonuments",
        "sub_category": "Monuments",
        "photo_url": "assets/caire/pyramide.jpg",
        "description": "Seules merveilles du monde antique encore debout, les pyramides de Khéops, Khéphren et Mykérinos sont le symbole ultime de l'Égypte. Ce site archéologique monumental, gardé par le majestueux Sphinx, témoigne du génie architectural et de la dévotion religieuse des pharaons de l'Ancien Empire. Explorer ce plateau, c'est marcher sur les traces de l'histoire humaine millénaire au cœur d'un désert qui a préservé ces trésors pour l'éternité.",
        "mapsQuery": "Pyramides de Gizeh Le Caire"
      },
      {
        "id": "citadelle_saladin",
        "name": "La Citadelle de Saladin",
        "sub_category_key": "catMonuments",
        "sub_category": "Monuments",
        "photo_url": "assets/caire/saladin.jpg",
        "description": "Dominant la ville depuis les hauteurs des collines de Mokattam, cette forteresse médiévale, construite par Saladin au XIIe siècle, est un joyau de l'architecture islamique. Elle abrite la célèbre Mosquée d'Albâtre (Mosquée de Mohamed Ali) dont les minarets élancés sont visibles de partout au Caire. Ses fortifications offrent non seulement un aperçu historique sur les défenses médiévales, mais aussi l'un des plus beaux panoramas sur la ville.",
        "mapsQuery": "Citadelle de Saladin Le Caire"
      },
      {
        "id": "quartier_copte",
        "name": "Le Quartier Copte",
        "sub_category_key": "catHistory",
        "sub_category": "Lieux historiques",
        "photo_url": "assets/caire/copte.jpg",
        "description": "Le Vieux-Caire cache en son sein le quartier copte, véritable sanctuaire de spiritualité. C'est ici que se trouve l'église suspendue, bâtie au-dessus des portes de la forteresse romaine de Babylone, ainsi que la synagogue Ben Ezra et l'église Saint-Serge, où, selon la tradition, la Sainte Famille aurait trouvé refuge lors de sa fuite en Égypte. Un lieu calme, chargé d'histoire, loin du tumulte urbain.",
        "mapsQuery": "Quartier Copte Le Caire"
      },
      {
        "id": "grand_musee_egyptien",
        "name": "Le Grand Musée Égyptien",
        "sub_category_key": "catHistory",
        "sub_category": "Lieux historiques",
        "photo_url": "assets/caire/musee.jpg",
        "description": "L'un des plus grands musées au monde dédiés à une seule civilisation. Un chef-d'œuvre architectural moderne abritant des trésors inestimables de l'histoire égyptienne, situé à proximité des pyramides.",
        "mapsQuery": "Grand Musée Égyptien Gizeh"
      },
      {
        "id": "khan_el_khalili",
        "name": "Khan el-Khalili",
        "sub_category_key": "catMarkets",
        "sub_category": "Marchés traditionnels",
        "photo_url": "assets/caire/khan.jpg",
        "description": "Plongez dans l'effervescence du plus célèbre souk du Caire. Vieux de plus de 600 ans, ce dédale de ruelles étroites regorge d'ateliers d'artisans, de boutiques d'épices, de parfums, d'objets en cuivre et de bijoux artisanaux. C'est un voyage sensoriel où les cris des marchands, l'odeur du café à la cardamome et le cliquetis du métal créent une ambiance unique au monde, parfaite pour une immersion totale dans la culture cairote.",
        "mapsQuery": "Khan el-Khalili Le Caire"
      },
      {
        "id": "souk_el_fustat",
        "name": "Souk El-Fustat",
        "sub_category_key": "catMarkets",
        "sub_category": "Marchés traditionnels",
        "photo_url": "assets/caire/fustat.jpg",
        "description": "Situé près du musée national de la civilisation égyptienne, le Souk El-Fustat est le paradis de l'artisanat contemporain et traditionnel. Moins frénétique que Khan el-Khalili, ce marché met en avant la qualité du travail manuel égyptien, notamment la poterie, le textile et la verrerie soufflée.",
        "mapsQuery": "Souk El-Fustat Le Caire"
      },
      {
        "id": "palais_baron",
        "name": "Palais Baron Empain",
        "sub_category_key": "catArch",
        "sub_category": "Architecture",
        "photo_url": "assets/caire/baron.jpg",
        "description": "Un palais spectaculaire d'inspiration hindoue situé à Héliopolis. Son architecture unique et son histoire mystérieuse en font un lieu incontournable du Caire moderne.",
        "mapsQuery": "Palais Baron Empain Héliopolis"
      },
      {
        "id": "parc_al_azhar",
        "name": "Parc Al-Azhar",
        "sub_category_key": "catRelaxation",
        "sub_category": "Lieux de détente",
        "photo_url": "assets/caire/al.jpg",
        "description": "Un havre de paix verdoyant offrant une vue magnifique sur la Citadelle et le vieux Caire. Parfait pour une promenade relaxante loin du tumulte.",
        "mapsQuery": "Parc Al-Azhar Le Caire"
      },
      {
        "id": "le_nil",
        "name": "Le Nil",
        "sub_category_key": "catHistory",
        "sub_category": "Lieux historiques",
        "photo_url": "assets/caire/nil.jpg",
        "description": "Artère vitale de l'Égypte depuis l'Antiquité, le Nil est le cœur battant du Caire. Fleuve mythique, il a permis le développement de la civilisation pharaonique et continue aujourd'hui d'offrir des promenades en felouque inoubliables au coucher du soleil.",
        "mapsQuery": "Le Nil Le Caire"
      },
    ],
    'en': [
      {
        "id": "tour_caire",
        "name": "Cairo Tower",
        "sub_category_key": "catActivities",
        "sub_category": "Activities in Cairo",
        "photo_url": "assets/caire/tour.jpg",
        "description": "Standing 187 meters tall, the Cairo Tower is a modern icon of the city, often considered Egypt's equivalent of the Eiffel Tower. Built in reinforced concrete shaped like a lattice mashrabiya, it offers a 360-degree observation deck. It is the perfect location to admire the vastness of the capital, the winding Nile, and on a clear day, the Giza Pyramids on the horizon.",
        "mapsQuery": "Cairo Tower"
      },
      {
        "id": "pyramides_gizeh",
        "name": "Pyramids of Giza",
        "sub_category_key": "catMonuments",
        "sub_category": "Monuments",
        "photo_url": "assets/caire/pyramide.jpg",
        "description": "The only surviving Wonder of the Ancient World, the Pyramids of Khufu, Khafre, and Menkaure are the ultimate symbol of Egypt. Guarded by the majestic Great Sphinx, this monumental archaeological site stands as a testament to the architectural brilliance and religious devotion of Old Kingdom Pharaohs.",
        "mapsQuery": "Pyramids of Giza Cairo"
      },
      {
        "id": "citadelle_saladin",
        "name": "Citadel of Saladin",
        "sub_category_key": "catMonuments",
        "sub_category": "Monuments",
        "photo_url": "assets/caire/saladin.jpg",
        "description": "Dominating the skyline from the heights of the Mokattam Hills, this medieval fortress built by Saladin in the 12th century is a masterpiece of Islamic architecture. It houses the famous Alabaster Mosque (Mosque of Muhammad Ali) and offers one of the best panoramic views over the entire city.",
        "mapsQuery": "Citadel of Saladin Cairo"
      },
      {
        "id": "quartier_copte",
        "name": "Coptic Quarter",
        "sub_category_key": "catHistory",
        "sub_category": "Historical Sites",
        "photo_url": "assets/caire/copte.jpg",
        "description": "Old Cairo houses the Coptic Quarter, a peaceful sanctuary rich in spiritual heritage. Here you will find the Hanging Church built over the Roman Fortress of Babylon, Ben Ezra Synagogue, and St. Sergius Church, where tradition holds the Holy Family sheltered during their flight to Egypt.",
        "mapsQuery": "Coptic Cairo"
      },
      {
        "id": "grand_musee_egyptien",
        "name": "Grand Egyptian Museum",
        "sub_category_key": "catHistory",
        "sub_category": "Historical Sites",
        "photo_url": "assets/caire/musee.jpg",
        "description": "One of the largest museum complexes in the world dedicated to a single civilization. A modern architectural masterpiece housing priceless treasures of Egyptian history, located near the Pyramids.",
        "mapsQuery": "Grand Egyptian Museum Giza"
      },
      {
        "id": "khan_el_khalili",
        "name": "Khan el-Khalili",
        "sub_category_key": "catMarkets",
        "sub_category": "Traditional Markets",
        "photo_url": "assets/caire/khan.jpg",
        "description": "Immerse yourself in the bustling atmosphere of Cairo's most famous bazaar. Over 600 years old, this labyrinth of narrow alleyways is filled with artisan workshops, spice shops, perfumes, copperware, and handcrafted jewelry, offering an authentic cultural immersion.",
        "mapsQuery": "Khan el-Khalili Cairo"
      },
      {
        "id": "souk_el_fustat",
        "name": "Souk El-Fustat",
        "sub_category_key": "catMarkets",
        "sub_category": "Traditional Markets",
        "photo_url": "assets/caire/fustat.jpg",
        "description": "Located near the National Museum of Egyptian Civilization, Souk El-Fustat is a center for traditional and modern Egyptian handicrafts. Quieter than Khan el-Khalili, it highlights fine handiwork such as pottery, textiles, and blown glass.",
        "mapsQuery": "Souk El-Fustat Cairo"
      },
      {
        "id": "palais_baron",
        "name": "Baron Empain Palace",
        "sub_category_key": "catArch",
        "sub_category": "Architecture",
        "photo_url": "assets/caire/baron.jpg",
        "description": "A striking Hindu-inspired mansion located in Heliopolis. Its unique architecture and intriguing history make it a fascinating landmark in modern Cairo.",
        "mapsQuery": "Baron Empain Palace Heliopolis"
      },
      {
        "id": "parc_al_azhar",
        "name": "Al-Azhar Park",
        "sub_category_key": "catRelaxation",
        "sub_category": "Relaxation Spots",
        "photo_url": "assets/caire/al.jpg",
        "description": "A lush, green haven of tranquility offering magnificent views of the Citadel and Historic Cairo. Perfect for a relaxing stroll away from the urban bustle.",
        "mapsQuery": "Al-Azhar Park Cairo"
      },
      {
        "id": "le_nil",
        "name": "The Nile",
        "sub_category_key": "catHistory",
        "sub_category": "Historical Sites",
        "photo_url": "assets/caire/nil.jpg",
        "description": "The vital lifeline of Egypt since ancient times, the Nile River is the beating heart of Cairo. This legendary river nurtured Pharaonic civilization and continues to offer unforgettable sunset felucca rides today.",
        "mapsQuery": "Nile River Cairo"
      },
    ],
    'ar': [
      {
        "id": "tour_caire",
        "name": "برج القاهرة",
        "sub_category_key": "catActivities",
        "sub_category": "أنشطة في القاهرة",
        "photo_url": "assets/caire/tour.jpg",
        "description": "يبلغ ارتفاع برج القاهرة 187 متراً، وهو رمز حديث للمدينة وشبيه ببرج إيفل بنكهة مصرية. تم بناؤه من الخرسانة المسلحة على شكل مشربية مصممة بعناية، ويضم منصة مراقبة بـ 360 درجة، مما يجعله المكان المثالي لمشاهدة النيل العظيم والأهرامات في الأفق.",
        "mapsQuery": "برج القاهرة"
      },
      {
        "id": "pyramides_gizeh",
        "name": "أهرامات الجيزة",
        "sub_category_key": "catMonuments",
        "sub_category": "المعالم الأثرية",
        "photo_url": "assets/caire/pyramide.jpg",
        "description": "العجيبة الوحيدة المتبقية من عجائب العالم القديم، أهرامات خوفو وخفرع ومنقرع هي الرمز الأسمى لمصر. يحرس هذا الموقع الأثري المهيب تمثال أبو الهول، ليشهد على عبقرية العمارة والروحانية لدى الفراعنة.",
        "mapsQuery": "أهرامات الجيزة القاهرة"
      },
      {
        "id": "citadelle_saladin",
        "name": "قلعة صلاح الدين",
        "sub_category_key": "catMonuments",
        "sub_category": "المعالم الأثرية",
        "photo_url": "assets/caire/saladin.jpg",
        "description": "تطل هذه القلعة التي بناها صلاح الدين الأيوبي في القرن الثاني عشر على المدينة من أعالي تلال المقطم. وهي تحفة من تحف العمارة الإسلامية، وتضم مسجد محمد علي الشهير وتوفر إحدى أروع الإطلالات البانورامية على القاهرة.",
        "mapsQuery": "قلعة صلاح الدين القاهرة"
      },
      {
        "id": "quartier_copte",
        "name": "مجمع الأديان (الحي القبطي)",
        "sub_category_key": "catHistory",
        "sub_category": "الأماكن التاريخية",
        "photo_url": "assets/caire/copte.jpg",
        "description": "تخفي مصر القديمة في قلبها الحي القبطي التاريخي. يحتوي على الكنيسة المعلقة المبنية فوق حصن بابليون الروماني، وكنيسة أبي سرجة حيث أوت العائلة المقدسة، ومعبد بن عزرا اليهودي.",
        "mapsQuery": "الحي القبطي القاهرة"
      },
      {
        "id": "grand_musee_egyptien",
        "name": "المتحف المصري الكبير",
        "sub_category_key": "catHistory",
        "sub_category": "الأماكن التاريخية",
        "photo_url": "assets/caire/musee.jpg",
        "description": "أحد أكبر المتاحف في العالم المخصصة لحضارة واحدة. تحفة معمارية حديثة تضم كنوزاً لا تُقدر بثمن من التاريخ المصري بالقرب من أهرامات الجيزة.",
        "mapsQuery": "المتحف المصري الكبير الجيزة"
      },
      {
        "id": "khan_el_khalili",
        "name": "خان الخليلي",
        "sub_category_key": "catMarkets",
        "sub_category": "الأسواق التقليدية",
        "photo_url": "assets/caire/khan.jpg",
        "description": "انغمس في صخب أشهر سوق في القاهرة يعود تاريخه لأكثر من 600 عام. زقاق حافل بالورش الحرفية والمقاهي التاريخية والمجوهرات والمصنوعات النحاسية والتوابل والعطور.",
        "mapsQuery": "خان الخليلي القاهرة"
      },
      {
        "id": "souk_el_fustat",
        "name": "سوق الفسطاط",
        "sub_category_key": "catMarkets",
        "sub_category": "الأسواق التقليدية",
        "photo_url": "assets/caire/fustat.jpg",
        "description": "يقع بالقرب من المتحف القومي للحضارة المصرية، ويدعم الحرف اليدوية التقليدية والمعاصرة مثل الفخار والسيراميك والمنسوجات والزجاج المنفوخ.",
        "mapsQuery": "سوق الفسطاط القاهرة"
      },
      {
        "id": "palais_baron",
        "name": "قصر البارون إمبان",
        "sub_category_key": "catArch",
        "sub_category": "العمارة",
        "photo_url": "assets/caire/baron.jpg",
        "description": "قصر فريد مستوحى من المعابد الهندوسية يقع في حي مصر الجديدة. معمار أنيق وتاريخ ساحر يجعله معلماً استثنائياً في القاهرة.",
        "mapsQuery": "قصر البارون مصر الجديدة"
      },
      {
        "id": "parc_al_azhar",
        "name": "حديقة الأزهر",
        "sub_category_key": "catRelaxation",
        "sub_category": "أماكن الاسترخاء",
        "photo_url": "assets/caire/al.jpg",
        "description": "واحة خضراء هادئة توفر إطلالة ساحرة على قلعة صلاح الدين والقاهرة التاريخية، وتعتبر مكاناً مثالياً للتنزه والاسترخاء بعيداً عن صخب المدينة.",
        "mapsQuery": "حديقة الأزهر القاهرة"
      },
      {
        "id": "le_nil",
        "name": "نهر النيل",
        "sub_category_key": "catHistory",
        "sub_category": "الأماكن التاريخية",
        "photo_url": "assets/caire/nil.jpg",
        "description": "شريان الحياة في مصر منذ أقدم العصور والقلب النابض للقاهرة. جولات الفلوكة النيلية وقت غروب الشمس توفر تجربة لا تُنسى.",
        "mapsQuery": "نهر النيل القاهرة"
      },
    ]
  };

  // ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _goldenNotified = _goldenNow(DateTime.now().toUtc()).live;
    _clock = Timer.periodic(const Duration(seconds: 1), (Timer _) {
      final DateTime nowUtc = DateTime.now().toUtc();
      final bool live = _goldenNow(nowUtc).live;
      if (live && !_goldenNotified) {
        _goldenNotified = true;
        HapticFeedback.heavyImpact();
      } else if (!live) {
        _goldenNotified = false;
      }
      _tick.value = nowUtc;
    });
    _chargerPrefs();
  }

  @override
  void dispose() {
    _clock?.cancel();
    _tick.dispose();
    _scroll.dispose();
    super.dispose();
  }

  // ───────────── Préférences ─────────────

  Future<void> _chargerPrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? lang = prefs.getString('selected_language');
    if (!mounted) return;
    setState(() {
      if (lang != null && _uiTranslations.containsKey(lang)) _lang = lang;
      _favs = (prefs.getStringList('favorite_places') ?? <String>[]).toSet();
      _stamps = (prefs.getStringList('stamped_places') ?? <String>[]).toSet();
      _visitMinutes = prefs.getInt('visit_minutes') ?? 0;
    });
  }

  Future<void> _changerLangue(String code) async {
    if (code == _lang) return;
    HapticFeedback.selectionClick();
    setState(() => _lang = code);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_language', code);
  }

  Future<void> _toggleFav(String id) async {
    HapticFeedback.lightImpact();
    setState(() {
      if (!_favs.remove(id)) _favs.add(id);
    });
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorite_places', _favs.toList());
  }

  Future<void> _toggleStamp(String id) async {
    setState(() {
      if (!_stamps.remove(id)) _stamps.add(id);
    });
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('stamped_places', _stamps.toList());
  }

  Future<void> _addVisit(int minutes) async {
    if (minutes <= 0) return;
    setState(() => _visitMinutes += minutes);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('visit_minutes', _visitMinutes);
  }


  Future<void> _confirmResetStamps() async {
    if (_stamps.isEmpty) return;
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => Directionality(
        textDirection: _lang == 'ar' ? TextDirection.rtl : TextDirection.ltr,
        child: AlertDialog(
          backgroundColor: _C.surface,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: _C.line),
            borderRadius: BorderRadius.circular(28),
          ),
          title: Text(_t('resetAsk'),
              style: _display(ctx, 21, height: 1.2, ls: -0.4)),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(_t('cancel'),
                  style: const TextStyle(
                      color: _C.textSoft, fontWeight: FontWeight.w600)),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(_t('resetYes'),
                  style: const TextStyle(
                      color: _C.gold, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
    if (ok != true) return;
    HapticFeedback.mediumImpact();
    setState(() => _stamps.clear());
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('stamped_places');
  }

  Future<void> _ouvrirMaps(String query) async {
    final Uri url = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}');
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Erreur ouverture Maps : $e');
    }
  }

  // ───────────── Accès aux données ─────────────

  String _t(String key) =>
      _uiTranslations[_lang]?[key] ?? _uiTranslations['fr']![key] ?? key;

  List<Map<String, dynamic>> get _data =>
      _localizedCaireData[_lang] ?? _localizedCaireData['fr']!;

  Map<String, dynamic>? _extraFor(String id) {
    final Map<String, dynamic>? all = _placeExtras[id];
    if (all == null) return null;
    final Object? l = all[_lang] ?? all['fr'];
    return l is Map<String, dynamic> ? l : null;
  }

  Map<String, String> _facts() {
    final Map<String, String> m = <String, String>{};
    for (final Map<String, dynamic> it in _data) {
      final Object? f = _extraFor(it['id'] as String)?['fact'];
      if (f is String) m[it['id'] as String] = f;
    }
    return m;
  }

  String _durStr(Duration d) {
    final int h = d.inHours;
    final int m = d.inMinutes % 60;
    if (h == 0) return '$m ${_t('mUnit')}';
    return '$h ${_t('hUnit')}${m > 0 ? ' ${_two(m)}' : ''}';
  }

  String _liveLine(DateTime utc) {
    final _Golden g = _goldenNow(utc);
    final String phase = g.live
        ? _t('phaseDusk')
        : (g.dayP >= 0 ? _t('phaseDay') : _t('phaseNight'));
    return '$phase · ${_t('cairoTime').replaceAll('{t}', _hm(utc))}';
  }

  // ───────────── Navigation ─────────────

  void _openDetail(Map<String, dynamic> item) {
    HapticFeedback.selectionClick();
    final String id = item['id'] as String;
    final List<String> relIds =
    ((_placeExtras[id]?['related'] as List?) ?? const <dynamic>[]).cast<String>();
    final List<Map<String, dynamic>> related = <Map<String, dynamic>>[
      for (final String r in relIds) ..._data.where((Map<String, dynamic> e) => e['id'] == r),
    ];
    final Map<String, String> labels = <String, String>{
      for (final String k in const <String>[
        'about', 'overview', 'duration', 'bestTime', 'category', 'highlights',
        'didYouKnow', 'tip', 'seeAlso', 'btnStamp', 'btnStampDone', 'btnTimer',
        'btnMaps', 'visitTitle', 'start', 'stop', 'visitDone', 'hUnit', 'mUnit',
        'close', 'totalTime', 'goldenNow',
      ])
        k: _t(k),
    };
    final bool isRtl = _lang == 'ar';
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 520),
        reverseTransitionDuration: const Duration(milliseconds: 420),
        pageBuilder: (_, __, ___) => Directionality(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          child: _PlaceDetailPage(
            item: item,
            extra: _extraFor(id),
            labels: labels,
            related: related,
            isFav: _favs.contains(id),
            isStamped: _stamps.contains(id),
            onFav: () => _toggleFav(id),
            onStamp: () => _toggleStamp(id),
            onVisitDone: _addVisit,
            onMaps: () => _ouvrirMaps(
                item['mapsQuery'] as String? ?? '${item['name']} Le Caire'),
            onOpenRelated: _openDetail,
          ),
        ),
        transitionsBuilder: (_, a, __, child) {
          final Animation<double> curved =
          CurvedAnimation(parent: a, curve: Curves.easeOutCubic);
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.035),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  void _openQuiz() {
    HapticFeedback.selectionClick();
    final bool isRtl = _lang == 'ar';
    final Map<String, String> labels = <String, String>{
      for (final String k in const <String>[
        'quizTitle', 'quizIntro', 'quizQ', 'score', 'streak', 'record', 'next',
        'rightAns', 'wrongAns', 'quizReset', 'quizResetAsk', 'cancel', 'resetYes',
      ])
        k: _t(k),
    };
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => Directionality(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          child: _QuizPage(places: _data, facts: _facts(), labels: labels),
        ),
      ),
    );
  }


  // ───────────── Construction de la page ─────────────

  Widget _buildLangs() {
    const List<String> codes = <String>['fr', 'en', 'ar'];
    const List<String> labels = <String>['FR', 'EN', 'AR'];
    return _Glass(
      radius: 99,
      blur: 14,
      padding: const EdgeInsets.all(3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (int i = 0; i < codes.length; i++)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _changerLangue(codes[i]),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOutCubic,
                padding:
                const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
                decoration: BoxDecoration(
                  gradient: _lang == codes[i] ? _C.goldGrad : null,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  labels[i],
                  style: _num(12,
                      color: _lang == codes[i] ? _C.onGold : _C.text,
                      weight: FontWeight.w700,
                      ls: 0.6),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildChips(List<String> catKeys) {
    final List<MapEntry<String, String>> items = <MapEntry<String, String>>[
      MapEntry<String, String>('all', _t('all')),
      MapEntry<String, String>('fav', _t('favs')),
      for (final String k in catKeys) MapEntry<String, String>(k, _t(k)),
    ];
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: items.length,
      separatorBuilder: (BuildContext _, int __) => const SizedBox(width: 8),
      itemBuilder: (BuildContext c, int i) {
        final String key = items[i].key;
        final bool on = _filter == key;
        final Color fg = on ? _C.onGold : _C.textSoft;
        return _Press(
          scale: 0.94,
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _filter = key);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              gradient: on ? _C.goldGrad : null,
              color: on ? null : _C.surface,
              borderRadius: BorderRadius.circular(99),
              border: on ? null : Border.all(color: _C.line),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (key == 'fav') ...<Widget>[
                  Icon(Icons.favorite_rounded, size: 15, color: fg),
                  const SizedBox(width: 6),
                ],
                Text(
                  items[i].value,
                  style: _label(c,
                      size: 13.5,
                      color: on ? _C.onGold : _C.text.withOpacity(0.85),
                      ls: 0.1,
                      weight: on ? FontWeight.w700 : FontWeight.w600),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSolar(DateTime nowUtc) {
    final _Golden g = _goldenNow(nowUtc);
    return _SolarPanel(
      nowUtc: nowUtc,
      g: g,
      goldenLabel: g.live ? _t('phaseDusk') : _t('goldenIn'),
      nowLabel: _t('goldenNow'),
      sunriseLabel: _t('sunrise'),
      sunsetLabel: _t('sunset'),
    );
  }

  Widget _buildPlayRow(Map<String, dynamic> daily) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: SizedBox(
        height: 140,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Quiz
            Expanded(
              child: _Press(
                onTap: _openQuiz,
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: <Color>[_C.surfaceHi, _C.surface],
                    ),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: _C.line),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          gradient: _C.goldGrad,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.psychology_alt_rounded,
                            color: _C.onGold, size: 25),
                      ),
                      const Spacer(),
                      Text(
                        _t('quizTitle'),
                        style: _display(context, 17, height: 1.15, ls: -0.3),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Lieu du jour
            Expanded(
              child: _Press(
                onTap: () => _openDetail(daily),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: _C.line),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(27),
                    child: Stack(
                      fit: StackFit.expand,
                      children: <Widget>[
                        _PlaceImage(daily['photo_url'] as String? ?? ''),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: <Color>[
                                Colors.black.withOpacity(0.35),
                                Colors.black.withOpacity(0.05),
                                Colors.black.withOpacity(0.85),
                              ],
                              stops: const <double>[0, 0.4, 1],
                            ),
                          ),
                        ),
                        PositionedDirectional(
                          top: 14,
                          start: 14,
                          end: 14,
                          child: Row(
                            children: <Widget>[
                              const Icon(Icons.wb_sunny_rounded,
                                  color: _C.gold, size: 15),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  _t('dailyPick'),
                                  style: _label(context,
                                      size: 12,
                                      color: _C.goldLight,
                                      ls: 0.2),
                                ),
                              ),
                            ],
                          ),
                        ),
                        PositionedDirectional(
                          start: 14,
                          end: 14,
                          bottom: 14,
                          child: Text(
                            '${daily['name']}',
                            style: _display(context, 16.5, height: 1.15, ls: -0.3),
                          ),
                        ),
                      ],
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

  Widget _buildPassport(List<bool> flags) {
    final int got = flags.where((bool f) => f).length;
    final double frac = flags.isEmpty ? 0 : got / flags.length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _C.surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: _C.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(13),
                    color: _C.gold.withOpacity(0.13),
                  ),
                  child: const Icon(Icons.verified_rounded,
                      color: _C.gold, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(_t('passport'),
                      style: _display(context, 18, ls: -0.3)),
                ),
                Text('$got / ${flags.length}',
                    style: _num(15, color: _C.gold, weight: FontWeight.w700)),
                const SizedBox(width: 6),
                Text(_t('passportCount'),
                    style: _label(context, size: 12.5, ls: 0.1)),
              ],
            ),
            const SizedBox(height: 18),
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: Container(
                height: 7,
                color: Colors.white.withOpacity(0.07),
                alignment: AlignmentDirectional.centerStart,
                child: AnimatedFractionallySizedBox(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutCubic,
                  alignment: AlignmentDirectional.centerStart,
                  widthFactor: frac.clamp(0.0, 1.0).toDouble(),
                  child: Container(
                    decoration: const BoxDecoration(gradient: _C.goldGrad),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                for (int i = 0; i < flags.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: flags[i] ? _C.goldGrad : null,
                      border: flags[i]
                          ? null
                          : Border.all(
                          color: Colors.white.withOpacity(0.16), width: 1),
                    ),
                    child: flags[i]
                        ? const Icon(Icons.check_rounded,
                        size: 16, color: _C.onGold)
                        : null,
                  ),
              ],
            ),
            const SizedBox(height: 18),
            Container(height: 0.8, color: _C.line),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                const Icon(Icons.timer_outlined,
                    size: 17, color: _C.textSoft),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${_t('totalTime')} · ${_durStr(Duration(minutes: _visitMinutes))}',
                    style: _label(context,
                        size: 13, color: _C.text.withOpacity(0.85), ls: 0.1),
                  ),
                ),
                if (got > 0)
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _confirmResetStamps,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Text(
                        _t('resetPassport'),
                        style: _label(context,
                            size: 13, color: _C.gold, ls: 0.1),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(Map<String, dynamic> it, int n) {
    final String id = it['id'] as String;
    return _Reveal(
      delay: Duration(milliseconds: 60 * (n > 5 ? 5 : n)),
      dy: 28,
      child: _PlaceCard(
        number: n,
        name: it['name'] as String? ?? '',
        sub: (it['sub_category'] ?? '').toString(),
        photo: it['photo_url'] as String? ?? '',
        stamped: _stamps.contains(id),
        fav: _favs.contains(id),
        onFav: () => _toggleFav(id),
        onTap: () => _openDetail(it),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> data = _data;
    final bool rtl = _lang == 'ar';
    final double h = MediaQuery.of(context).size.height;
    final double topPad = MediaQuery.of(context).padding.top;

    final List<String> catKeys = <String>[];
    for (final Map<String, dynamic> it in data) {
      final String k = it['sub_category_key'] as String? ?? 'catHistory';
      if (!catKeys.contains(k)) catKeys.add(k);
    }

    final List<Map<String, dynamic>> visible =
    data.where((Map<String, dynamic> it) {
      if (_filter == 'all') return true;
      if (_filter == 'fav') return _favs.contains(it['id']);
      return it['sub_category_key'] == _filter;
    }).toList();

    final Map<String, dynamic> daily = data[
    DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays %
        data.length];

    final List<bool> flags = <bool>[
      for (final Map<String, dynamic> it in data) _stamps.contains(it['id']),
    ];

    final List<Widget> rows = <Widget>[];
    int n = 0;
    if (_filter == 'all') {
      for (final String k in catKeys) {
        final List<Map<String, dynamic>> items = visible
            .where((Map<String, dynamic> it) => it['sub_category_key'] == k)
            .toList();
        rows.add(_SectionHeader(
            title: _t(k), count: '${items.length} ${_t('places')}'));
        for (final Map<String, dynamic> it in items) {
          n++;
          rows.add(_row(it, n));
        }
      }
    } else {
      rows.add(const SizedBox(height: 18));
      for (final Map<String, dynamic> it in visible) {
        n++;
        rows.add(_row(it, n));
      }
    }
    if (visible.isEmpty) {
      rows.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 30),
        child: Column(
          children: <Widget>[
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _C.surface,
                border: Border.all(color: _C.line),
              ),
              child: const Icon(Icons.favorite_border_rounded,
                  color: _C.gold, size: 30),
            ),
            const SizedBox(height: 20),
            Text(_t('noFav'),
                textAlign: TextAlign.center,
                style: _body(16, color: _C.textSoft, height: 1.6)),
          ],
        ),
      ));
    }

    return Directionality(
      textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: _C.bg,
          body: ScrollConfiguration(
            behavior: WebScrollBehavior(),
            child: CustomScrollView(
              controller: _scroll,
              physics: const BouncingScrollPhysics(),
              slivers: <Widget>[
                SliverToBoxAdapter(
                  child: _Masthead(
                    height: (h * 0.60).clamp(460.0, 640.0).toDouble(),
                    topPad: topPad,
                    title: _t('pageTitle'),
                    tagline: _t('tagline'),
                    countText: '${data.length} ${_t('places')}',
                    liveLine: _liveLine,
                    tick: _tick,
                    langs: _buildLangs(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: ValueListenableBuilder<DateTime>(
                    valueListenable: _tick,
                    builder: (BuildContext c, DateTime now, Widget? _) =>
                        _buildSolar(now),
                  ),
                ),
                SliverToBoxAdapter(child: _buildPlayRow(daily)),
                SliverToBoxAdapter(child: _buildPassport(flags)),
                const SliverToBoxAdapter(child: SizedBox(height: 18)),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _FilterDelegate(
                    child: _buildChips(catKeys),
                    topPad: topPad,
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  sliver: SliverList(delegate: SliverChildListDelegate(rows)),
                ),
                SliverToBoxAdapter(child: _Footer(title: _t('pageTitle'))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════
//  FICHE DÉTAILLÉE
// ═════════════════════════════════════════════════════════════

/// Bouton secondaire de la barre du bas de la fiche.
class _BarAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _BarAction({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _Press(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: active ? _C.gold.withOpacity(0.16) : Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? _C.gold.withOpacity(0.55) : _C.line,
            width: 0.9,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 20, color: active ? _C.gold : _C.text),
            const SizedBox(width: 6),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  softWrap: false,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: active ? _C.goldLight : _C.text,
                    letterSpacing: _ls(context, 0.1),
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

class _PlaceDetailPage extends StatefulWidget {
  final Map<String, dynamic> item;
  final Map<String, dynamic>? extra;
  final Map<String, String> labels;
  final List<Map<String, dynamic>> related;
  final bool isFav;
  final bool isStamped;
  final VoidCallback onFav;
  final VoidCallback onStamp;
  final ValueChanged<int> onVisitDone;
  final VoidCallback onMaps;
  final ValueChanged<Map<String, dynamic>> onOpenRelated;

  const _PlaceDetailPage({
    required this.item,
    required this.extra,
    required this.labels,
    required this.related,
    required this.isFav,
    required this.isStamped,
    required this.onFav,
    required this.onStamp,
    required this.onVisitDone,
    required this.onMaps,
    required this.onOpenRelated,
  });

  @override
  State<_PlaceDetailPage> createState() => _PlaceDetailPageState();
}

class _PlaceDetailPageState extends State<_PlaceDetailPage> {
  late bool _fav = widget.isFav;
  late bool _stamped = widget.isStamped;

  String _l(String k) => widget.labels[k] ?? k;

  void _toggleFavLocal() {
    HapticFeedback.selectionClick();
    setState(() => _fav = !_fav);
    widget.onFav();
  }

  void _toggleStampLocal() {
    HapticFeedback.mediumImpact();
    setState(() => _stamped = !_stamped);
    widget.onStamp();
  }

  void _openTimer() {
    final bool rtl = Directionality.of(context) == TextDirection.rtl;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext _) => Directionality(
        textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
        child: _VisitSheet(
          name: '${widget.item['name']}',
          labels: widget.labels,
          onFinished: widget.onVisitDone,
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double h, bool rtl) {
    final double imgH = (h * 0.54).clamp(380.0, 560.0).toDouble();
    final double top = MediaQuery.of(context).padding.top;
    return SizedBox(
      height: imgH,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          _KenBurns(
              child: _PlaceImage(widget.item['photo_url'] as String? ?? '')),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  Colors.black.withOpacity(0.55),
                  Colors.transparent,
                  _C.bg.withOpacity(0.85),
                  _C.bg,
                ],
                stops: const <double>[0, 0.28, 0.80, 1],
              ),
            ),
          ),
          PositionedDirectional(
            top: top + 12,
            start: 18,
            child: _CircleBtn(
              icon: rtl
                  ? Icons.arrow_forward_ios_rounded
                  : Icons.arrow_back_ios_new_rounded,
              onTap: () => Navigator.of(context).pop(),
            ),
          ),
          PositionedDirectional(
            top: top + 12,
            end: 18,
            child: _CircleBtn(
              icon: _fav
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              active: _fav,
              onTap: _toggleFavLocal,
            ),
          ),
          PositionedDirectional(
            start: 20,
            end: 20,
            bottom: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _Glass(
                  radius: 99,
                  blur: 14,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle, color: _C.gold),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          '${widget.item['sub_category'] ?? ''}',
                          style: _label(context,
                              size: 12.5, color: _C.text, ls: 0.1),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  '${widget.item['name']}',
                  style: _display(context, 40,
                      weight: FontWeight.w800, height: 1.02, ls: -1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(double bottomPad) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 12 + bottomPad),
      child: _Glass(
        radius: 30,
        blur: 28,
        tint: _C.bg.withOpacity(0.62),
        padding: const EdgeInsets.all(8),
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 3,
              child: _BarAction(
                icon: _stamped
                    ? Icons.verified_rounded
                    : Icons.verified_outlined,
                label: _stamped ? _l('btnStampDone') : _l('btnStamp'),
                active: _stamped,
                onTap: _toggleStampLocal,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 3,
              child: _BarAction(
                icon: Icons.timer_outlined,
                label: _l('btnTimer'),
                active: false,
                onTap: _openTimer,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 4,
              child: _GoldButton(
                label: _l('btnMaps'),
                icon: Icons.near_me_rounded,
                height: 54,
                onTap: widget.onMaps,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> it = widget.item;
    final Map<String, dynamic>? ex = widget.extra;
    final double h = MediaQuery.of(context).size.height;
    final double bottomPad = MediaQuery.of(context).padding.bottom;
    final bool rtl = Directionality.of(context) == TextDirection.rtl;
    final List<dynamic> hl = (ex?['hl'] as List?) ?? const <dynamic>[];
    final String? fact = ex?['fact'] as String?;
    final String? tip = ex?['tip'] as String?;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _C.bg,
        body: Stack(
          children: <Widget>[
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: <Widget>[
                SliverToBoxAdapter(child: _buildHeader(context, h, rtl)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Expanded(
                                child: _MetaTile(
                                  icon: Icons.schedule_rounded,
                                  label: _l('duration'),
                                  value: (ex?['duration'] ?? '—').toString(),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _MetaTile(
                                  icon: Icons.wb_twilight_rounded,
                                  label: _l('bestTime'),
                                  value: (ex?['best'] ?? '—').toString(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),
                        Text(it['description'] as String? ?? '',
                            style: _body(16.5,
                                color: const Color(0xFFD3D6DE), height: 1.75)),
                      ],
                    ),
                  ),
                ),
                if (hl.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 40, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          _DetailLabel(text: _l('highlights')),
                          const SizedBox(height: 18),
                          for (int i = 0; i < hl.length; i++)
                            _HighlightCard(
                              number: i + 1,
                              title: '${(hl[i] as Map)['t']}',
                              desc: '${(hl[i] as Map)['d']}',
                            ),
                        ],
                      ),
                    ),
                  ),
                if (fact != null)
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: <Color>[
                            _C.gold.withOpacity(0.17),
                            _C.gold.withOpacity(0.04),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                            color: _C.gold.withOpacity(0.32), width: 0.9),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              const Icon(Icons.auto_awesome_rounded,
                                  color: _C.gold, size: 19),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(_l('didYouKnow'),
                                    style: _label(context,
                                        size: 14,
                                        color: _C.goldLight,
                                        ls: 0.1,
                                        weight: FontWeight.w700)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(fact,
                              style: _display(context, 19.5,
                                  weight: FontWeight.w600,
                                  height: 1.42,
                                  ls: -0.3)),
                        ],
                      ),
                    ),
                  ),
                if (tip != null)
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: _C.surface,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: _C.line),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              const Icon(Icons.lightbulb_outline_rounded,
                                  color: _C.gold, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(_l('tip'),
                                    style: _label(context,
                                        size: 14,
                                        color: _C.gold,
                                        ls: 0.1,
                                        weight: FontWeight.w700)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(tip,
                              style: _body(15.5,
                                  color: const Color(0xFFD3D6DE), height: 1.7)),
                        ],
                      ),
                    ),
                  ),
                if (widget.related.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 40, 20, 18),
                          child: _DetailLabel(text: _l('seeAlso')),
                        ),
                        SizedBox(
                          height: 210,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: widget.related.length,
                            separatorBuilder: (BuildContext _, int __) =>
                            const SizedBox(width: 14),
                            itemBuilder: (BuildContext _, int i) =>
                                _RelatedTile(
                                  item: widget.related[i],
                                  onTap: () =>
                                      widget.onOpenRelated(widget.related[i]),
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                SliverToBoxAdapter(child: SizedBox(height: 120 + bottomPad)),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildBottomBar(bottomPad),
            ),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════
//  MINUTEUR DE VISITE
// ═════════════════════════════════════════════════════════════
class _VisitSheet extends StatefulWidget {
  final String name;
  final Map<String, String> labels;
  final ValueChanged<int> onFinished;
  const _VisitSheet({
    required this.name,
    required this.labels,
    required this.onFinished,
  });

  @override
  State<_VisitSheet> createState() => _VisitSheetState();
}

class _VisitSheetState extends State<_VisitSheet> {
  static const List<int> _options = <int>[30, 60, 90];
  int _mins = 60;
  int _elapsed = 0; // secondes
  bool _running = false;
  bool _done = false;
  Timer? _tm;

  String _l(String k) => widget.labels[k] ?? k;

  @override
  void dispose() {
    _tm?.cancel();
    super.dispose();
  }

  void _start() {
    HapticFeedback.selectionClick();
    _tm?.cancel();
    setState(() {
      _running = true;
      _done = false;
      _elapsed = 0;
    });
    _tm = Timer.periodic(const Duration(seconds: 1), (Timer _) {
      if (!mounted) return;
      setState(() => _elapsed++);
      if (_elapsed >= _mins * 60) _finish(true);
    });
  }

  void _finish(bool completed) {
    _tm?.cancel();
    final int spent = completed ? _mins : _elapsed ~/ 60;
    HapticFeedback.heavyImpact();
    setState(() {
      _running = false;
      _done = completed;
    });
    if (spent > 0) widget.onFinished(spent);
  }

  @override
  Widget build(BuildContext context) {
    final int total = _mins * 60;
    final int left = (total - _elapsed).clamp(0, total).toInt();
    final String clock = '${_two(left ~/ 60)}:${_two(left % 60)}';
    final double bottom = MediaQuery.of(context).padding.bottom;
    final double progress = (_running || _done) ? _elapsed / total : 0.0;
    return Container(
      padding: EdgeInsets.fromLTRB(24, 12, 24, 24 + bottom),
      decoration: const BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
        border: Border(top: BorderSide(color: Color(0x1FFFFFFF), width: 0.8)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(_l('visitTitle'),
                        style: _label(context,
                            size: 13, color: _C.gold, ls: 0.2)),
                    const SizedBox(height: 6),
                    Text(widget.name,
                        style: _display(context, 24, height: 1.1, ls: -0.6)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _CircleBtn(
                icon: Icons.close_rounded,
                solid: true,
                size: 40,
                onTap: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 26),
          Center(
            child: SizedBox(
              width: 236,
              height: 236,
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Positioned.fill(
                    child: CustomPaint(painter: _RingPainter(progress)),
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(clock,
                        softWrap: false,
                        style: _num(56, weight: FontWeight.w700, ls: -1.5)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 24,
            child: Center(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _done ? 1 : 0,
                child: Text(_l('visitDone'),
                    style: _body(14.5, color: _C.gold, weight: FontWeight.w600)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          IgnorePointer(
            ignoring: _running,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 250),
              opacity: _running ? 0.0 : 1.0,
              child: Row(
                children: <Widget>[
                  for (int i = 0; i < _options.length; i++) ...<Widget>[
                    if (i > 0) const SizedBox(width: 10),
                    Expanded(
                      child: _Press(
                        scale: 0.94,
                        onTap: () => setState(() => _mins = _options[i]),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 240),
                          height: 48,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            gradient: _mins == _options[i] ? _C.goldGrad : null,
                            color: _mins == _options[i] ? null : _C.surfaceHi,
                            borderRadius: BorderRadius.circular(16),
                            border: _mins == _options[i]
                                ? null
                                : Border.all(color: _C.line),
                          ),
                          child: Text(
                            '${_options[i]} ${_l('mUnit')}',
                            style: TextStyle(
                              color: _mins == _options[i]
                                  ? _C.onGold
                                  : _C.textSoft,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          _GoldButton(
            label: _running ? _l('stop') : _l('start'),
            icon: _running ? Icons.stop_rounded : Icons.play_arrow_rounded,
            filled: !_running,
            onTap: _running ? () => _finish(false) : _start,
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════
//  JEU : DEVINE LE LIEU
// ═════════════════════════════════════════════════════════════

/// Petite tuile de statistique (score, série, record).
class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool hot;
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    this.hot = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: hot ? _C.gold.withOpacity(0.10) : _C.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: hot ? _C.gold.withOpacity(0.35) : _C.line,
          width: 0.9,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(icon, size: 14, color: hot ? _C.gold : _C.textDim),
              const SizedBox(width: 6),
              Expanded(
                child: Text(label,
                    style: _label(context, size: 11.5, ls: 0.1)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(value,
              style: _num(22,
                  color: hot ? _C.goldLight : _C.text,
                  weight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _QuizPage extends StatefulWidget {
  final List<Map<String, dynamic>> places;
  final Map<String, String> facts;
  final Map<String, String> labels;
  const _QuizPage({
    required this.places,
    required this.facts,
    required this.labels,
  });

  @override
  State<_QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<_QuizPage> {
  final math.Random _rng = math.Random();
  Map<String, dynamic>? _target;
  List<Map<String, dynamic>> _options = <Map<String, dynamic>>[];
  String? _picked;
  int _score = 0;
  int _streak = 0;
  int _best = 0;

  String _l(String k) => widget.labels[k] ?? k;

  @override
  void initState() {
    super.initState();
    _loadBest();
    _next();
  }

  Future<void> _loadBest() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => _best = prefs.getInt('quiz_best') ?? 0);
  }

  void _next() {
    final List<Map<String, dynamic>> pool = widget.places
        .where((Map<String, dynamic> p) => widget.facts.containsKey(p['id']))
        .toList();
    if (pool.length < 3) return;
    pool.shuffle(_rng);
    final Map<String, dynamic> target = pool.first;
    final List<Map<String, dynamic>> opts = <Map<String, dynamic>>[
      target,
      pool[1],
      pool[2],
    ]..shuffle(_rng);
    setState(() {
      _target = target;
      _options = opts;
      _picked = null;
    });
  }

  Future<void> _answer(Map<String, dynamic> o) async {
    if (_picked != null || _target == null) return;
    final bool ok = o['id'] == _target!['id'];
    HapticFeedback.mediumImpact();
    setState(() {
      _picked = o['id'] as String;
      if (ok) {
        _score++;
        _streak++;
      } else {
        _streak = 0;
      }
      if (_streak > _best) _best = _streak;
    });
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('quiz_best', _best);
  }

  Future<void> _confirmResetQuiz() async {
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => Directionality(
        textDirection: Directionality.of(context),
        child: AlertDialog(
          backgroundColor: _C.surface,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: _C.line),
            borderRadius: BorderRadius.circular(28),
          ),
          title: Text(_l('quizResetAsk'),
              style: _display(ctx, 21, height: 1.2, ls: -0.4)),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(_l('cancel'),
                  style: const TextStyle(
                      color: _C.textSoft, fontWeight: FontWeight.w600)),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(_l('resetYes'),
                  style: const TextStyle(
                      color: _C.gold, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
    if (ok != true || !mounted) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _score = 0;
      _streak = 0;
      _best = 0;
    });
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('quiz_best');
  }

  _OptState _stateOf(Map<String, dynamic> o) {
    if (_picked == null) return _OptState.idle;
    if (o['id'] == _target?['id']) return _OptState.right;
    if (o['id'] == _picked) return _OptState.wrong;
    return _OptState.faded;
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? target = _target;
    final String fact =
    target == null ? '' : (widget.facts[target['id']] ?? '');
    final bool answered = _picked != null;
    final bool ok = answered && _picked == target?['id'];
    final String targetName = target == null ? '' : '${target['name']}';
    final double bottom = MediaQuery.of(context).padding.bottom;
    final bool rtl = Directionality.of(context) == TextDirection.rtl;
    final List<String> letters = rtl
        ? const <String>['أ', 'ب', 'ج']
        : const <String>['A', 'B', 'C'];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _C.bg,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 10, 20, 16),
                child: Row(
                  children: <Widget>[
                    _CircleBtn(
                      icon: rtl
                          ? Icons.arrow_forward_ios_rounded
                          : Icons.arrow_back_ios_new_rounded,
                      solid: true,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(_l('quizTitle'),
                          style: _display(context, 22, ls: -0.5)),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: _StatTile(
                        icon: Icons.star_rounded,
                        label: _l('score'),
                        value: '$_score',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatTile(
                        icon: Icons.local_fire_department_rounded,
                        label: _l('streak'),
                        value: '$_streak',
                        hot: _streak >= 2,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatTile(
                        icon: Icons.emoji_events_rounded,
                        label: _l('record'),
                        value: '$_best',
                      ),
                    ),
                  ],
                ),
              ),
              if (_score > 0 || _streak > 0 || _best > 0)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _confirmResetQuiz,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Text(
                          _l('quizReset'),
                          style: _label(context,
                              size: 13, color: _C.gold, ls: 0.1),
                        ),
                      ),
                    ),
                  ),
                ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(20, 12, 20, 24 + bottom),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(_l('quizIntro'),
                          style: _body(15, color: _C.textSoft)),
                      const SizedBox(height: 16),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 350),
                        switchInCurve: Curves.easeOutCubic,
                        transitionBuilder: (Widget c, Animation<double> a) =>
                            FadeTransition(
                              opacity: a,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0, 0.04),
                                  end: Offset.zero,
                                ).animate(a),
                                child: c,
                              ),
                            ),
                        child: Container(
                          key: ValueKey<Object?>(target?['id']),
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(22, 16, 22, 24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: <Color>[
                                _C.gold.withOpacity(0.17),
                                _C.gold.withOpacity(0.04),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                                color: _C.gold.withOpacity(0.32), width: 0.9),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const Icon(Icons.format_quote_rounded,
                                  color: _C.gold, size: 40),
                              const SizedBox(height: 4),
                              Text(
                                fact,
                                style: _display(context, 21,
                                    weight: FontWeight.w600,
                                    height: 1.42,
                                    ls: -0.3),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 26),
                      Text(_l('quizQ'),
                          style: _label(context,
                              size: 13, color: _C.textSoft, ls: 0.1)),
                      const SizedBox(height: 12),
                      for (int i = 0; i < _options.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _OptionTile(
                            letter: letters[i],
                            label: '${_options[i]['name']}',
                            state: _stateOf(_options[i]),
                            onTap: () => _answer(_options[i]),
                          ),
                        ),
                      if (answered) ...<Widget>[
                        const SizedBox(height: 8),
                        Row(
                          children: <Widget>[
                            Icon(
                              ok
                                  ? Icons.check_circle_rounded
                                  : Icons.info_rounded,
                              color: ok ? _C.good : _C.gold,
                              size: 22,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                ok
                                    ? _l('rightAns')
                                    : _l('wrongAns')
                                    .replaceAll('{n}', targetName),
                                style: _display(context, 17.5,
                                    weight: FontWeight.w600,
                                    height: 1.3,
                                    ls: -0.2),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _GoldButton(
                          label: _l('next'),
                          icon: Icons.arrow_forward_rounded,
                          onTap: _next,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════
//  ANIMATION D'APPARITION
// ═════════════════════════════════════════════════════════════
/// Apparition douce : fondu + glissement vers le haut, avec délai.
class _Reveal extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final double dy;
  const _Reveal({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.dy = 36,
  });

  @override
  State<_Reveal> createState() => _RevealState();
}

class _RevealState extends State<_Reveal> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _a;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 750));
    _a = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);
    if (widget.delay == Duration.zero) {
      _c.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _c.forward();
      });
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _a,
      child: widget.child,
      builder: (_, child) => Opacity(
        opacity: _a.value.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, widget.dy * (1 - _a.value)),
          child: child,
        ),
      ),
    );
  }
}

const Map<String, Map<String, dynamic>> _placeExtras = {
  'tour_caire': {
    'related': ['le_nil', 'pyramides_gizeh', 'parc_al_azhar'],
    'fr': {
      'duration': "1 h à 1 h 30",
      'best': "Au coucher du soleil",
      'tip': "Arrivez une heure avant le crépuscule : vous verrez la ville en pleine lumière, puis illuminée, sans avoir à monter deux fois.",
      'fact': "Inaugurée en 1961 et conçue par l'architecte Naoum Shebib, la tour a un treillis qui évoque la tige d'un lotus, symbole de l'Égypte antique.",
      'hl': [
        {'t': "Panorama à 360°", 'd': "La plateforme dévoile Le Caire d'un seul regard : îles du Nil, minarets, ponts et, par temps clair, les pyramides."},
        {'t': "Une icône de l'île de Gezira", 'd': "Elle s'élève au cœur de l'île, entourée de jardins et à quelques pas de l'Opéra du Caire."},
        {'t': "Un dîner avec vue", 'd': "Un restaurant panoramique au sommet permet de dîner tandis que toute la ville scintille en contrebas."},
      ],
    },
    'en': {
      'duration': "1 to 1.5 hours",
      'best': "At sunset",
      'tip': "Arrive an hour before dusk: you'll see the city in daylight, then lit up, without having to go up twice.",
      'fact': "Opened in 1961 and designed by architect Naoum Shebib, the tower's lattice evokes the stem of a lotus, a symbol of ancient Egypt.",
      'hl': [
        {'t': "360° panorama", 'd': "The viewing platform takes in all of Cairo at once: Nile islands, minarets, bridges and, on a clear day, the pyramids."},
        {'t': "An icon of Gezira Island", 'd': "It rises in the heart of the island, surrounded by gardens and a short walk from the Cairo Opera House."},
        {'t': "Dining with a view", 'd': "A panoramic restaurant at the top lets you enjoy a meal while the whole city glitters below."},
      ],
    },
    'ar': {
      'duration': "من ساعة إلى ساعة ونصف",
      'best': "عند غروب الشمس",
      'tip': "احرص على الوصول قبل الغروب بساعة لتشاهد المدينة في ضوء النهار ثم وهي مضاءة، دون الحاجة إلى الصعود مرتين.",
      'fact': "افتُتح البرج عام 1961 وصممه المهندس نعوم شبيب، وتذكّر شبكته الهيكلية بساق زهرة اللوتس، رمز مصر القديمة.",
      'hl': [
        {'t': "إطلالة بانورامية 360°", 'd': "تكشف المنصة القاهرة بأكملها: جزر النيل والمآذن والجسور، وفي الأيام الصافية الأهرامات."},
        {'t': "رمز جزيرة الزمالك", 'd': "يقع في قلب الجزيرة وسط الحدائق، على بُعد خطوات من دار الأوبرا المصرية."},
        {'t': "عشاء مع إطلالة", 'd': "في الأعلى مطعم بانورامي يتيح لك تناول الطعام بينما تتلألأ المدينة تحت قدميك."},
      ],
    },
  },
  'pyramides_gizeh': {
    'related': ['grand_musee_egyptien', 'tour_caire', 'le_nil'],
    'fr': {
      'duration': "3 à 4 h",
      'best': "Dès l'ouverture, tôt le matin",
      'tip': "Emportez de l'eau, un chapeau et de la crème solaire, et convenez toujours du prix avant une balade à dos de chameau ou de cheval.",
      'fact': "La Grande Pyramide de Khéops, érigée vers 2560 av. J.-C., est restée la plus haute construction du monde pendant environ 3 800 ans.",
      'hl': [
        {'t': "La Grande Pyramide", 'd': "Haute d'environ 139 mètres aujourd'hui (146 à l'origine), elle est composée de plus de deux millions de blocs de pierre."},
        {'t': "Le Grand Sphinx", 'd': "Sculpté dans le roc, il mesure environ 73 mètres de long pour 20 mètres de haut et veille sur le plateau depuis plus de 4 500 ans."},
        {'t': "Un site classé à l'UNESCO", 'd': "Le plateau de Gizeh fait partie du site « Memphis et sa nécropole », inscrit au patrimoine mondial depuis 1979."},
      ],
    },
    'en': {
      'duration': "3 to 4 hours",
      'best': "First thing in the morning",
      'tip': "Bring water, a hat and sunscreen, and always agree on a price before a camel or horse ride.",
      'fact': "The Great Pyramid of Khufu, built around 2560 BC, remained the tallest structure in the world for about 3,800 years.",
      'hl': [
        {'t': "The Great Pyramid", 'd': "About 139 metres tall today (146 originally), it is made of more than two million blocks of stone."},
        {'t': "The Great Sphinx", 'd': "Carved from bedrock, it is about 73 metres long and 20 metres high, and has watched over the plateau for more than 4,500 years."},
        {'t': "A UNESCO World Heritage Site", 'd': "The Giza plateau belongs to the “Memphis and its Necropolis” site, inscribed on the World Heritage List in 1979."},
      ],
    },
    'ar': {
      'duration': "من 3 إلى 4 ساعات",
      'best': "في الصباح الباكر عند الافتتاح",
      'tip': "خذ معك الماء وقبعة وواقيًا من الشمس، واتفق دائمًا على السعر قبل ركوب الجمل أو الحصان.",
      'fact': "ظل هرم خوفو الأكبر، الذي شُيّد نحو عام 2560 ق.م، أعلى بناء في العالم لنحو 3800 عام.",
      'hl': [
        {'t': "الهرم الأكبر", 'd': "يبلغ ارتفاعه اليوم نحو 139 مترًا (146 مترًا في الأصل)، ويتألف من أكثر من مليوني كتلة حجرية."},
        {'t': "أبو الهول", 'd': "منحوت في الصخر، يبلغ طوله نحو 73 مترًا وارتفاعه 20 مترًا، ويحرس الهضبة منذ أكثر من 4500 عام."},
        {'t': "موقع في قائمة اليونسكو", 'd': "تنتمي هضبة الجيزة إلى موقع «منف ومقبرتها» المدرج في قائمة التراث العالمي منذ عام 1979."},
      ],
    },
  },
  'citadelle_saladin': {
    'related': ['parc_al_azhar', 'khan_el_khalili', 'quartier_copte'],
    'fr': {
      'duration': "2 à 3 h",
      'best': "Fin d'après-midi, pour la lumière dorée",
      'tip': "Pour entrer dans la mosquée de Mohamed Ali, portez une tenue couvrante (épaules et genoux) ; on se déchausse à l'entrée.",
      'fact': "Mohamed Ali a fait bâtir sa mosquée entre 1830 et 1848, en s'inspirant des grandes mosquées d'Istanbul. Son surnom d'« Albâtre » vient de la pierre qui revêt ses murs et sa cour.",
      'hl': [
        {'t': "La mosquée de Mohamed Ali", 'd': "Son dôme central et ses deux minarets effilés dominent la silhouette du Caire."},
        {'t': "Un panorama exceptionnel", 'd': "Depuis les terrasses, le regard embrasse la ville et, par temps clair, jusqu'aux pyramides."},
        {'t': "Plus de huit siècles d'histoire", 'd': "Fondée au XIIe siècle, la citadelle fut le siège du pouvoir pendant des siècles et abrite aujourd'hui plusieurs musées."},
      ],
    },
    'en': {
      'duration': "2 to 3 hours",
      'best': "Late afternoon, for the golden light",
      'tip': "To enter the Mohamed Ali Mosque, wear modest clothing (shoulders and knees covered); shoes are removed at the entrance.",
      'fact': "Mohamed Ali had his mosque built between 1830 and 1848, inspired by the great mosques of Istanbul. Its “Alabaster” nickname comes from the stone that clads its walls and courtyard.",
      'hl': [
        {'t': "The Mohamed Ali Mosque", 'd': "Its central dome and two slender minarets dominate Cairo's skyline."},
        {'t': "An exceptional panorama", 'd': "From the terraces, the view stretches across the city and, on clear days, to the pyramids."},
        {'t': "Over eight centuries of history", 'd': "Founded in the 12th century, the citadel was the seat of power for centuries and now houses several museums."},
      ],
    },
    'ar': {
      'duration': "من ساعتين إلى 3 ساعات",
      'best': "وقت العصر حين يكون الضوء ذهبيًا",
      'tip': "لدخول مسجد محمد علي ارتدِ ملابس محتشمة تغطي الكتفين والركبتين، وتُخلع الأحذية عند المدخل.",
      'fact': "بنى محمد علي مسجده بين عامي 1830 و1848 متأثرًا بمساجد إسطنبول الكبرى، ويعود لقب «الألباستر» إلى الحجر الذي يكسو جدرانه وصحنه.",
      'hl': [
        {'t': "مسجد محمد علي", 'd': "تهيمن قبّته المركزية ومئذنتاه الرشيقتان على أفق القاهرة."},
        {'t': "إطلالة استثنائية", 'd': "من الشرفات تمتد الرؤية فوق المدينة، وحتى الأهرامات في الأيام الصافية."},
        {'t': "أكثر من ثمانية قرون من التاريخ", 'd': "أُسست القلعة في القرن الثاني عشر وكانت مقرّ الحكم لقرون، وتضم اليوم عدة متاحف."},
      ],
    },
  },
  'quartier_copte': {
    'related': ['souk_el_fustat', 'citadelle_saladin', 'le_nil'],
    'fr': {
      'duration': "2 à 3 h",
      'best': "Le matin, quand le quartier est calme",
      'tip': "Les ruelles sont pavées et les églises demandent une tenue respectueuse : prévoyez des chaussures confortables.",
      'fact': "Les premières communautés chrétiennes d'Égypte remontent aux premiers siècles de notre ère ; le mot « copte » dérive du grec ancien désignant les Égyptiens.",
      'hl': [
        {'t': "L'église suspendue", 'd': "Bâtie sur les bastions d'une forteresse romaine, sa nef semble flotter au-dessus du sol."},
        {'t': "L'église Saint-Serge", 'd': "Selon la tradition, la Sainte Famille se serait abritée dans sa crypte lors de sa fuite en Égypte."},
        {'t': "La synagogue Ben Ezra", 'd': "L'un des plus anciens lieux de culte juifs d'Égypte, célèbre pour la découverte de la Geniza du Caire."},
      ],
    },
    'en': {
      'duration': "2 to 3 hours",
      'best': "In the morning, when the district is quiet",
      'tip': "The lanes are cobbled and the churches call for respectful dress, so bring comfortable shoes.",
      'fact': "Egypt's first Christian communities date back to the first centuries AD; the word “Copt” derives from the ancient Greek word for “Egyptian”.",
      'hl': [
        {'t': "The Hanging Church", 'd': "Built over the bastions of a Roman fortress, its nave seems to float above the ground."},
        {'t': "Saint Sergius Church", 'd': "According to tradition, the Holy Family sheltered in its crypt during the flight into Egypt."},
        {'t': "The Ben Ezra Synagogue", 'd': "One of the oldest Jewish places of worship in Egypt, famous for the discovery of the Cairo Geniza."},
      ],
    },
    'ar': {
      'duration': "من ساعتين إلى 3 ساعات",
      'best': "في الصباح حين يكون الحي هادئًا",
      'tip': "الأزقة مرصوفة بالحجارة والكنائس تتطلب لباسًا محتشمًا، لذا ارتدِ حذاءً مريحًا.",
      'fact': "تعود أولى الجماعات المسيحية في مصر إلى القرون الأولى للميلاد، وكلمة «قبطي» مشتقة من الكلمة اليونانية القديمة التي تعني «مصري».",
      'hl': [
        {'t': "الكنيسة المعلقة", 'd': "شُيّدت فوق أبراج حصن روماني، فيبدو صحنها كأنه معلّق في الهواء."},
        {'t': "كنيسة أبي سرجة", 'd': "وفق التقليد، لجأت العائلة المقدسة إلى سردابها أثناء رحلتها إلى مصر."},
        {'t': "معبد بن عزرا", 'd': "من أقدم المعابد اليهودية في مصر، اشتهر باكتشاف جنيزة القاهرة."},
      ],
    },
  },
  'grand_musee_egyptien': {
    'related': ['pyramides_gizeh', 'tour_caire', 'khan_el_khalili'],
    'fr': {
      'duration': "3 à 5 h",
      'best': "À l'ouverture, en semaine",
      'tip': "Réservez votre billet en ligne à l'avance et associez la visite aux pyramides, qui ne sont qu'à quelques minutes.",
      'fact': "Le musée réunit pour la première fois l'ensemble de la collection de Toutânkhamon, soit plus de 5 000 objets.",
      'hl': [
        {'t': "Le Grand Escalier", 'd': "Des dizaines de statues de pharaons et de divinités jalonnent la montée, comme une galerie sous verrière."},
        {'t': "Ramsès II en majesté", 'd': "Un colosse de plusieurs tonnes accueille les visiteurs dans le grand hall."},
        {'t': "Vue sur les pyramides", 'd': "De larges baies vitrées cadrent les pyramides de Gizeh à l'horizon."},
      ],
    },
    'en': {
      'duration': "3 to 5 hours",
      'best': "At opening time, on a weekday",
      'tip': "Book your ticket online in advance and pair the visit with the pyramids, only a few minutes away.",
      'fact': "The museum brings together, for the first time, the entire Tutankhamun collection: more than 5,000 objects.",
      'hl': [
        {'t': "The Grand Staircase", 'd': "Dozens of statues of pharaohs and gods line the climb, like a gallery under glass."},
        {'t': "Ramesses II in majesty", 'd': "A colossal statue weighing several tonnes greets visitors in the grand hall."},
        {'t': "Views of the pyramids", 'd': "Wide glass walls frame the Giza pyramids on the horizon."},
      ],
    },
    'ar': {
      'duration': "من 3 إلى 5 ساعات",
      'best': "عند الافتتاح في أيام الأسبوع",
      'tip': "احجز تذكرتك عبر الإنترنت مسبقًا، واجمع بين زيارة المتحف والأهرامات القريبة منه بدقائق.",
      'fact': "يجمع المتحف لأول مرة مجموعة توت عنخ آمون كاملة، وتضم أكثر من 5000 قطعة.",
      'hl': [
        {'t': "الدرج العظيم", 'd': "تصطف عشرات التماثيل للفراعنة والآلهة على امتداد الصعود، كأنه معرض تحت سقف زجاجي."},
        {'t': "رمسيس الثاني بكل مهابته", 'd': "يستقبل الزوار تمثال ضخم يزن عدة أطنان في القاعة الكبرى."},
        {'t': "إطلالة على الأهرامات", 'd': "تؤطر الواجهات الزجاجية الواسعة أهرامات الجيزة في الأفق."},
      ],
    },
  },
  'khan_el_khalili': {
    'related': ['citadelle_saladin', 'parc_al_azhar', 'souk_el_fustat'],
    'fr': {
      'duration': "2 à 3 h",
      'best': "En fin de journée, quand la lumière s'adoucit",
      'tip': "Marchandez avec le sourire : le premier prix annoncé est rarement le prix final. Faites une pause thé au café El Fishawy.",
      'fact': "Le bazar a été fondé en 1382 ; le café El Fishawy, installé en son cœur, serait ouvert depuis le XVIIIe siècle.",
      'hl': [
        {'t': "Lanternes et cuivres", 'd': "Des centaines d'ateliers façonnent lanternes, plateaux ciselés et objets en laiton."},
        {'t': "Épices et parfums", 'd': "Hibiscus, safran, cumin, huiles parfumées : les étals embaument les ruelles."},
        {'t': "Le café El Fishawy", 'd': "Une halte mythique, thé à la menthe en main, souvent associée au prix Nobel Naguib Mahfouz."},
      ],
    },
    'en': {
      'duration': "2 to 3 hours",
      'best': "Late in the day, as the light softens",
      'tip': "Haggle with a smile: the first price is rarely the final one. Stop for tea at El Fishawy café.",
      'fact': "The bazaar was founded in 1382; El Fishawy café, in its heart, is said to have been open since the 18th century.",
      'hl': [
        {'t': "Lanterns and copperware", 'd': "Hundreds of workshops craft lanterns, engraved trays and brass objects."},
        {'t': "Spices and perfumes", 'd': "Hibiscus, saffron, cumin, scented oils: the stalls perfume the alleys."},
        {'t': "El Fishawy café", 'd': "A legendary stop, mint tea in hand, often associated with Nobel laureate Naguib Mahfouz."},
      ],
    },
    'ar': {
      'duration': "من ساعتين إلى 3 ساعات",
      'best': "في نهاية اليوم حين يلين الضوء",
      'tip': "فاصِل بابتسامة، فالسعر الأول نادرًا ما يكون النهائي، وخذ استراحة شاي في مقهى الفيشاوي.",
      'fact': "تأسس الخان عام 1382، ويُقال إن مقهى الفيشاوي في قلبه مفتوح منذ القرن الثامن عشر.",
      'hl': [
        {'t': "الفوانيس والنحاس", 'd': "مئات الورش تصنع الفوانيس والصواني المنقوشة والتحف النحاسية."},
        {'t': "التوابل والعطور", 'd': "الكركديه والزعفران والكمون والزيوت العطرية تملأ الأزقة برائحتها."},
        {'t': "مقهى الفيشاوي", 'd': "محطة أسطورية لشرب الشاي بالنعناع، ارتبط اسمها بالأديب الحائز على نوبل نجيب محفوظ."},
      ],
    },
  },
  'souk_el_fustat': {
    'related': ['quartier_copte', 'khan_el_khalili', 'le_nil'],
    'fr': {
      'duration': "1 h 30 à 2 h 30",
      'best': "Le matin ou en fin d'après-midi",
      'tip': "Combinez-le avec le musée national de la civilisation égyptienne, tout proche, pour une journée mêlant culture et artisanat.",
      'fact': "Fustat, fondée en 641, fut la première capitale de l'Égypte islamique et le berceau de ce qui deviendrait Le Caire.",
      'hl': [
        {'t': "Poterie et céramique", 'd': "Des ateliers présentent des pièces tournées à la main, aux motifs traditionnels et contemporains."},
        {'t': "Verre soufflé", 'd': "Vases et lampes en verre soufflé, façonnés par des artisans égyptiens."},
        {'t': "Textiles tissés", 'd': "Tapis, tissus et broderies mettent en avant un savoir-faire transmis de génération en génération."},
      ],
    },
    'en': {
      'duration': "1.5 to 2.5 hours",
      'best': "Morning or late afternoon",
      'tip': "Combine it with the nearby National Museum of Egyptian Civilization for a day of culture and craftsmanship.",
      'fact': "Fustat, founded in 641, was the first capital of Islamic Egypt and the cradle of what would become Cairo.",
      'hl': [
        {'t': "Pottery and ceramics", 'd': "Workshops present hand-thrown pieces with traditional and contemporary patterns."},
        {'t': "Blown glass", 'd': "Vases and lamps in blown glass, shaped by Egyptian craftspeople."},
        {'t': "Woven textiles", 'd': "Rugs, fabrics and embroidery showcase skills handed down through generations."},
      ],
    },
    'ar': {
      'duration': "من ساعة ونصف إلى ساعتين ونصف",
      'best': "في الصباح أو وقت العصر",
      'tip': "اجمع بين زيارته والمتحف القومي للحضارة المصرية القريب منه لقضاء يوم يجمع الثقافة والحرف.",
      'fact': "كانت الفسطاط، التي تأسست عام 641، أول عاصمة لمصر الإسلامية ومهد ما ستصبح عليه القاهرة.",
      'hl': [
        {'t': "الفخار والخزف", 'd': "تعرض الورش قطعًا مصنوعة يدويًا بزخارف تقليدية ومعاصرة."},
        {'t': "الزجاج المنفوخ", 'd': "مزهريات ومصابيح من الزجاج المنفوخ يصنعها حرفيون مصريون."},
        {'t': "المنسوجات", 'd': "تبرز السجاجيد والأقمشة والتطريز مهارات تنتقل من جيل إلى جيل."},
      ],
    },
  },
  'palais_baron': {
    'related': ['tour_caire', 'khan_el_khalili', 'citadelle_saladin'],
    'fr': {
      'duration': "1 h à 2 h",
      'best': "En fin de journée, à l'heure dorée",
      'tip': "Associez la visite à une balade dans Héliopolis, quartier fondé par le baron Empain et riche en façades néo-mauresques.",
      'fact': "Construit entre 1907 et 1911 pour le baron belge Édouard Empain, le palais s'inspire des temples hindous et d'Angkor, au Cambodge. Le baron est aussi le fondateur d'Héliopolis.",
      'hl': [
        {'t': "Une architecture unique", 'd': "Éléphants sculptés, statues d'inspiration hindoue et colonnades : un décor qui détonne au cœur de l'Égypte."},
        {'t': "Un palais entouré de légendes", 'd': "Abandonné pendant des décennies, il a nourri rumeurs et récits de fantômes avant d'être restauré."},
        {'t': "Héliopolis", 'd': "Autour du palais, ce quartier élégant mêle avenues arborées et architecture néo-mauresque."},
      ],
    },
    'en': {
      'duration': "1 to 2 hours",
      'best': "Late in the day, at golden hour",
      'tip': "Pair the visit with a stroll through Heliopolis, the district founded by Baron Empain, rich in neo-Moorish façades.",
      'fact': "Built between 1907 and 1911 for Belgian Baron Édouard Empain, the palace draws on Hindu temples and Cambodia's Angkor. The baron also founded Heliopolis.",
      'hl': [
        {'t': "A unique architecture", 'd': "Carved elephants, Hindu-inspired statues and colonnades: a décor that stands out in the heart of Egypt."},
        {'t': "A palace wrapped in legends", 'd': "Abandoned for decades, it fed rumours and ghost stories before being restored."},
        {'t': "Heliopolis", 'd': "Around the palace, this elegant district blends tree-lined avenues with neo-Moorish architecture."},
      ],
    },
    'ar': {
      'duration': "من ساعة إلى ساعتين",
      'best': "قبيل الغروب في الساعة الذهبية",
      'tip': "أضف إلى زيارتك جولة في مصر الجديدة (هليوبوليس) التي أسسها البارون، وتزخر بواجهات على الطراز المغربي الجديد.",
      'fact': "شُيّد القصر بين عامي 1907 و1911 للبارون البلجيكي إدوارد إمبان، مستلهمًا المعابد الهندوسية وأنغكور في كمبوديا، والبارون هو أيضًا مؤسس هليوبوليس.",
      'hl': [
        {'t': "عمارة فريدة", 'd': "فيلة منحوتة وتماثيل ذات طابع هندوسي وأعمدة: ديكور يبرز وسط مصر."},
        {'t': "قصر تحيط به الأساطير", 'd': "هُجر لعقود فأثار الشائعات وحكايات الأشباح قبل أن يُرمَّم."},
        {'t': "مصر الجديدة", 'd': "حول القصر، حي أنيق يجمع بين الشوارع المشجّرة والعمارة على الطراز المغربي الجديد."},
      ],
    },
  },
  'parc_al_azhar': {
    'related': ['citadelle_saladin', 'khan_el_khalili', 'quartier_copte'],
    'fr': {
      'duration': "1 h à 3 h",
      'best': "Fin d'après-midi, pour la vue sur la ville",
      'tip': "Apportez de quoi pique-niquer ou installez-vous dans un café avec vue sur la Citadelle.",
      'fact': "Aménagé sur d'anciennes collines de gravats et inauguré en 2005 grâce à l'Aga Khan Trust for Culture, le parc s'étend sur une trentaine d'hectares.",
      'hl': [
        {'t': "Des jardins d'inspiration islamique", 'd': "Bassins, fontaines et allées bordées d'arbres rappellent les jardins traditionnels."},
        {'t': "Les remparts ayyoubides", 'd': "Les travaux ont mis au jour un tronçon de l'ancienne muraille médiévale de la ville."},
        {'t': "Vue sur Le Caire historique", 'd': "Minarets, Citadelle et toits du vieux Caire se découvrent depuis les belvédères."},
      ],
    },
    'en': {
      'duration': "1 to 3 hours",
      'best': "Late afternoon, for the view of the city",
      'tip': "Bring a picnic or settle in at a café with a view over the Citadel.",
      'fact': "Created on former mounds of rubble and opened in 2005 thanks to the Aga Khan Trust for Culture, the park covers about thirty hectares.",
      'hl': [
        {'t': "Islamic-inspired gardens", 'd': "Pools, fountains and tree-lined paths recall traditional gardens."},
        {'t': "The Ayyubid walls", 'd': "The works uncovered a stretch of the city's old medieval wall."},
        {'t': "A view of historic Cairo", 'd': "Minarets, the Citadel and the old rooftops unfold from the viewpoints."},
      ],
    },
    'ar': {
      'duration': "من ساعة إلى 3 ساعات",
      'best': "وقت العصر للاستمتاع بإطلالة المدينة",
      'tip': "أحضر نزهة خفيفة أو اجلس في مقهى مطل على القلعة.",
      'fact': "أُقيمت الحديقة فوق تلال من الأنقاض القديمة وافتُتحت عام 2005 بفضل مؤسسة الآغا خان للثقافة، وتمتد على نحو ثلاثين هكتارًا.",
      'hl': [
        {'t': "حدائق مستوحاة من الطراز الإسلامي", 'd': "أحواض ونوافير وممرات تحفّها الأشجار تذكّر بالحدائق التقليدية."},
        {'t': "السور الأيوبي", 'd': "كشفت الأعمال عن جزء من سور المدينة الأيوبي القديم."},
        {'t': "إطلالة على القاهرة التاريخية", 'd': "تتكشف المآذن والقلعة وأسطح القاهرة القديمة من نقاط المشاهدة."},
      ],
    },
  },
  'le_nil': {
    'related': ['tour_caire', 'pyramides_gizeh', 'quartier_copte'],
    'fr': {
      'duration': "1 h (promenade en felouque)",
      'best': "Au coucher du soleil",
      'tip': "Convenez du prix et de la durée avant d'embarquer sur une felouque, et choisissez la fin de journée, quand la brise se lève.",
      'fact': "Avec environ 6 650 km, le Nil est l'un des plus longs fleuves du monde ; la grande majorité des Égyptiens vit encore sur ses rives.",
      'hl': [
        {'t': "La felouque au crépuscule", 'd': "Ces voiliers à voile triangulaire glissent en silence, au rythme du vent, face aux lumières de la ville."},
        {'t': "Berceau de la civilisation", 'd': "Chaque année, la crue du Nil fertilisait ses rives et a permis l'essor de l'Égypte pharaonique."},
        {'t': "La corniche", 'd': "Les quais du Caire, bordés de cafés et de promeneurs, s'animent le soir."},
      ],
    },
    'en': {
      'duration': "1 hour (felucca ride)",
      'best': "At sunset",
      'tip': "Agree on the price and duration before boarding a felucca, and go late in the day when the breeze rises.",
      'fact': "At about 6,650 km, the Nile is one of the longest rivers in the world; the vast majority of Egyptians still live along its banks.",
      'hl': [
        {'t': "A felucca at dusk", 'd': "These triangular-sailed boats glide silently with the wind, facing the city lights."},
        {'t': "Cradle of civilisation", 'd': "Each year the Nile's flood fertilised its banks and allowed pharaonic Egypt to flourish."},
        {'t': "The Corniche", 'd': "Cairo's embankments, lined with cafés and strollers, come alive in the evening."},
      ],
    },
    'ar': {
      'duration': "ساعة (جولة بالفلوكة)",
      'best': "عند غروب الشمس",
      'tip': "اتفق على السعر والمدة قبل ركوب الفلوكة، واختر آخر النهار حين يهبّ النسيم.",
      'fact': "يبلغ طول النيل نحو 6650 كم وهو من أطول أنهار العالم، ولا يزال معظم المصريين يعيشون على ضفافه.",
      'hl': [
        {'t': "فلوكة عند الغسق", 'd': "تنساب هذه المراكب ذات الشراع المثلث بصمت مع الريح أمام أضواء المدينة."},
        {'t': "مهد الحضارة", 'd': "كان فيضان النيل كل عام يخصب ضفافه ومكّن مصر الفرعونية من الازدهار."},
        {'t': "الكورنيش", 'd': "تنبض أرصفة القاهرة، التي تصطف عليها المقاهي والمتنزهون، بالحياة في المساء."},
      ],
    },
  },
};