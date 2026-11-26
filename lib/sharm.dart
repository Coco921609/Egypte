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
//  HEURE DE SHARM EL-SHEIKH ET CALCUL DU SOLEIL
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

/// Convertit un instant UTC en heure locale de Sharm El-Sheikh (fields = heure locale).
DateTime _toLocal(DateTime utc) =>
    utc.add(Duration(hours: _egyptDst(utc) ? 3 : 2));

String _two(int v) => v.toString().padLeft(2, '0');

String _hm(DateTime utc) {
  final DateTime c = _toLocal(utc);
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

/// Lever et coucher du soleil à Sharm El-Sheikh pour une date (algorithme solaire
/// simplifié, précision de quelques minutes).
_SunDay _sunDay(DateTime cairoDate) {
  const double latDeg = 27.9158;
  const double lonDeg = 34.3300;
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
  final DateTime cairo = _toLocal(nowUtc);
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
          Text('27.92°N · 34.33°E',
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
          _KenBurns(child: const _PlaceImage('assets/images/sharm.jpg')),
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
                          child: Text('27.92°N · 34.33°E',
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
class SharmElSheikhPage extends StatefulWidget {
  const SharmElSheikhPage({super.key});

  @override
  State<SharmElSheikhPage> createState() => _SharmElSheikhPageState();
}

class _SharmElSheikhPageState extends State<SharmElSheikhPage> {
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
      'pageTitle': "Sharm El-Sheikh",
      'tagline': "Entre mer Rouge et montagnes du Sinaï",
      'places': "lieux",
      'all': "Tout",
      'favs': "Favoris",
      'noFav': "Aucun favori pour le moment.\nTouche le ♡ pour en ajouter.",
      'discover': "Découvrir",
      'mapsBtn': "Ouvrir dans Google Maps",
      'about': "À propos",
      'overview': "En bref",
      'duration': "Durée conseillée",
      'bestTime': "Meilleur moment",
      'category': "Catégorie",
      'highlights': "Points forts",
      'didYouKnow': "Le saviez-vous ?",
      'tip': "Conseil du voyageur",
      'seeAlso': "À voir aussi",
      'catMonuments': "Monuments & Culture",
      'catMarkets': 'Marchés traditionnels',
      'catHistory': 'Lieux historiques',
      'catArch': 'Architecture',
      'catRelaxation': 'Lieux de détente',
      'catActivities': 'Activités à Sharm El-Sheikh',
      'phaseDawn': 'Aube',
      'phaseDay': 'Journée',
      'phaseDusk': 'Heure dorée',
      'phaseNight': 'Nuit',
      'cairoTime': 'Il est {t} à Sharm El-Sheikh',
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
      'totalTime': 'Temps à Sharm El-Sheikh',
      'hUnit': 'h',
      'mUnit': 'min',
      'btnStamp': 'Tamponner',
      'btnStampDone': 'Tamponné',
      'btnTimer': 'Minuteur',
      'btnMaps': 'Itinéraire',
      'catExcursions': "Excursions incontournables",
      'catSeaNature': "Mer & Nature",
    },
    'en': {
      'pageTitle': "Sharm El-Sheikh",
      'tagline': "Between the Red Sea and the Sinai mountains",
      'places': "places",
      'all': "All",
      'favs': "Favorites",
      'noFav': "No favorites yet.\nTap the ♡ to add some.",
      'discover': "Discover",
      'mapsBtn': "Open in Google Maps",
      'about': "About",
      'overview': "At a glance",
      'duration': "Suggested time",
      'bestTime': "Best time",
      'category': "Category",
      'highlights': "Highlights",
      'didYouKnow': "Did you know?",
      'tip': "Traveller's tip",
      'seeAlso': "Also worth a visit",
      'catMonuments': "Monuments & Culture",
      'catMarkets': 'Traditional Markets',
      'catHistory': 'Historical Sites',
      'catArch': 'Architecture',
      'catRelaxation': 'Relaxation Spots',
      'catActivities': 'Activities in Sharm El-Sheikh',
      'phaseDawn': 'Dawn',
      'phaseDay': 'Daylight',
      'phaseDusk': 'Golden hour',
      'phaseNight': 'Night',
      'cairoTime': 'It is {t} in Sharm El-Sheikh',
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
      'totalTime': 'Time in Sharm El-Sheikh',
      'hUnit': 'h',
      'mUnit': 'min',
      'btnStamp': 'Stamp',
      'btnStampDone': 'Stamped',
      'btnTimer': 'Timer',
      'btnMaps': 'Directions',
      'catExcursions': "Must-See Excursions",
      'catSeaNature': "Sea & Nature",
    },
    'ar': {
      'pageTitle': "شرم الشيخ",
      'tagline': "بين البحر الأحمر وجبال سيناء",
      'places': "مكان",
      'all': "الكل",
      'favs': "المفضلة",
      'noFav': "لا توجد أماكن مفضلة بعد.\nاضغط على ♡ للإضافة.",
      'discover': "اكتشف",
      'mapsBtn': "الفتح في خرائط Google",
      'about': "نبذة",
      'overview': "لمحة سريعة",
      'duration': "المدة المقترحة",
      'bestTime': "أفضل وقت",
      'category': "الفئة",
      'highlights': "أبرز المعالم",
      'didYouKnow': "هل تعلم؟",
      'tip': "نصيحة للمسافر",
      'seeAlso': "اكتشف أيضًا",
      'catMonuments': "المعالم والثقافة",
      'catMarkets': 'الأسواق التقليدية',
      'catHistory': 'الأماكن التاريخية',
      'catArch': 'العمارة',
      'catRelaxation': 'أماكن الاسترخاء',
      'catActivities': 'أنشطة في شرم الشيخ',
      'phaseDawn': 'الفجر',
      'phaseDay': 'نهار',
      'phaseDusk': 'الساعة الذهبية',
      'phaseNight': 'الليل',
      'cairoTime': 'الساعة {t} في شرم الشيخ',
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
      'totalTime': 'الوقت في شرم الشيخ',
      'hUnit': 'س',
      'mUnit': 'د',
      'btnStamp': 'ختم',
      'btnStampDone': 'تم الختم',
      'btnTimer': 'مؤقت',
      'btnMaps': 'الاتجاهات',
      'catExcursions': "رحلات لا بد منها",
      'catSeaNature': "البحر والطبيعة",
    },
  };

  // --- DONNÉES TRADUITES PAR LANGUE ---
  static const Map<String, List<Map<String, dynamic>>> _localizedSharmData = {
    'fr': [
      {
        "id": "mosque",
        "name": "La mosquée Al Sahaba",
        "sub_category_key": "catMonuments",
        "sub_category": "Monuments & Culture",
        "photo_url": "assets/sharm/mosque.jpeg",
        "description": "Située au cœur de la vieille ville, cette mosquée est un véritable chef-d'œuvre architectural. Alliant avec élégance les styles ottoman, fatimide et mamelouk, elle impressionne par ses détails complexes et sa silhouette imposante. Lorsque la nuit tombe, son éclairage savamment étudié sublime ses façades et ses minarets, créant une atmosphère mystique et majestueuse qui attire les visiteurs du monde entier.",
        "mapsQuery": "Al Sahaba Mosque Sharm El-Sheikh"
      },
      {
        "id": "eglise",
        "name": "L'Église Copte Orthodoxe",
        "sub_category_key": "catMonuments",
        "sub_category": "Monuments & Culture",
        "photo_url": "assets/sharm/eglise.jpg",
        "description": "Cette église est un joyau de sérénité et de beauté spirituelle. Ses vitraux aux couleurs vibrantes projettent des jeux de lumière fascinants à l'intérieur, tandis que ses fresques murales détaillées racontent avec précision la riche tradition copte égyptienne. C'est un havre de paix essentiel pour ceux qui souhaitent découvrir la profondeur culturelle et chrétienne de la région, loin du tumulte balnéaire.",
        "mapsQuery": "Coptic Church Sharm El-Sheikh"
      },
      {
        "id": "hollywood",
        "name": "Hollywood Sharm El-Sheikh",
        "sub_category_key": "catMonuments",
        "sub_category": "Monuments & Culture",
        "photo_url": "assets/sharm/h.jpg",
        "description": "Véritable parc à thème spectaculaire, ce lieu unique transporte les visiteurs dans un univers fantastique. Entre les répliques géantes de statues célèbres, les fontaines dansantes chorégraphiées et les installations lumineuses féeriques, c'est une destination incontournable pour les familles et les amateurs de photographie. L'ambiance y est constamment animée, offrant une expérience ludique et totalement dépaysante.",
        "mapsQuery": "Hollywood Sharm El-Sheikh"
      },
      {
        "id": "old_market",
        "name": "La Vieille Ville",
        "sub_category_key": "catMonuments",
        "sub_category": "Monuments & Culture",
        "photo_url": "assets/sharm/la.jpg",
        "description": "Le Vieux Marché représente le cœur battant et historique de Sharm El-Sheikh. C’est un labyrinthe vivant de ruelles où l'on découvre l'essence même de la culture locale. Entre les étals d'artisanat traditionnel, les épices aux parfums envoûtants et les boutiques de souvenirs, le visiteur s'immerge dans une ambiance authentique. C'est l'endroit rêvé pour goûter à la gastronomie égyptienne et échanger avec les commerçants dans une atmosphère chaleureuse.",
        "mapsQuery": "Old Market Sharm El-Sheikh"
      },
      {
        "id": "saint_catherine",
        "name": "Le monastère Sainte-Catherine",
        "sub_category_key": "catExcursions",
        "sub_category": "Excursions incontournables",
        "photo_url": "assets/sharm/saint.webp",
        "description": "Niché au pied des montagnes grandioses du Sinaï, ce monastère est l'un des plus anciens lieux de culte chrétien encore en activité dans le monde. Classé au patrimoine mondial, il abrite une collection inestimable d'icônes byzantines, de manuscrits anciens et le célèbre 'Buisson Ardent'. Une visite ici est un voyage dans le temps, imprégné de spiritualité et d'une histoire séculaire qui semble figée dans le désert.",
        "mapsQuery": "Saint Catherine's Monastery Sinai"
      },
      {
        "id": "mount_sinai",
        "name": "Le mont Sinaï",
        "sub_category_key": "catExcursions",
        "sub_category": "Excursions incontournables",
        "photo_url": "assets/sharm/mont.jpeg",
        "description": "Lieu chargé d'une puissance symbolique immense, le mont Sinaï est la destination par excellence des pèlerins et randonneurs. L'ascension, traditionnellement effectuée de nuit pour atteindre le sommet avant l'aube, est une épreuve physique récompensée par un lever de soleil spectaculaire. Voir la lumière embraser les cimes désertiques depuis ce sommet historique offre un moment de contemplation rare et une expérience visuelle absolument inoubliable.",
        "mapsQuery": "Mount Sinai Egypt"
      },
      {
        "id": "dahab",
        "name": "Dahab",
        "sub_category_key": "catExcursions",
        "sub_category": "Excursions incontournables",
        "photo_url": "assets/sharm/Dahab.webp",
        "description": "Ancien village de pêcheurs devenu un repaire mythique pour les voyageurs en quête de liberté, Dahab possède une atmosphère bohème unique. Réputée mondialement pour son rythme de vie détendu et ses sites de plongée d'exception, la ville est une étape incontournable. Son mélange de culture bédouine et de mode de vie décontracté en bord de mer, couplé à la proximité de sites naturels grandioses, en fait une destination fascinante.",
        "mapsQuery": "Dahab South Sinai"
      },
      {
        "id": "tiran_island",
        "name": "L’île de Tiran",
        "sub_category_key": "catSeaNature",
        "sub_category": "Mer & Nature",
        "photo_url": "assets/sharm/tirana.jpg",
        "description": "L'île de Tiran est un véritable sanctuaire pour les amoureux de la mer. Située à l'embouchure du golfe d'Aqaba, elle est entourée de récifs coralliens parmi les plus préservés et les plus riches de la mer Rouge. Ses eaux d'une clarté incroyable permettent d'observer une faune marine dense, incluant des tortues marines, des raies et une multitude de poissons tropicaux, faisant de chaque excursion une aventure immersive dans un aquarium naturel à ciel ouvert.",
        "mapsQuery": "Tiran Island Red Sea"
      },
      {
        "id": "red_sea",
        "name": "La mer",
        "sub_category_key": "catSeaNature",
        "sub_category": "Mer & Nature",
        "photo_url": "assets/sharm/mer.jpg",
        "description": "La mer Rouge, véritable joyau de l'Égypte, offre des conditions de baignade et de plongée inégalées. Avec ses eaux turquoise dont la température est idéale toute l'année et une biodiversité marine d'une richesse rare au monde, elle constitue le terrain de jeu favori des plongeurs. Explorer ses fonds marins, c'est plonger dans un univers de coraux colorés et de vie sauvage où le spectacle sous-marin est un émerveillement constant.",
        "mapsQuery": "Red Sea Sharm El-Sheikh"
      },
      {
        "id": "blue_hole",
        "name": "Dahab Blue Hole",
        "sub_category_key": "catSeaNature",
        "sub_category": "Mer & Nature",
        "photo_url": "assets/sharm/ll.jpg",
        "description": "Le Blue Hole de Dahab est un site légendaire qui exerce une fascination magnétique sur tous les plongeurs du globe. Il s'agit d'un gouffre sous-marin naturel d'une profondeur vertigineuse, entouré de récifs coralliens d'une densité incroyable. La transition brutale entre le bleu lagon peu profond et le bleu profond et mystérieux de l'abîme offre un spectacle visuel saisissant, faisant de cet endroit un défi et un rêve pour les passionnés d'exploration sous-marine.",
        "mapsQuery": "Blue Hole Dahab"
      },
    ],
    'en': [
      {
        "id": "mosque",
        "name": "Al Sahaba Mosque",
        "sub_category_key": "catMonuments",
        "sub_category": "Monuments & Culture",
        "photo_url": "assets/sharm/mosque.jpeg",
        "description": "Located in the heart of the Old Town, this mosque is a true architectural masterpiece. Elegantly blending Ottoman, Fatimid, and Mamluk styles, it impresses with intricate details and a grand silhouette. At night, thoughtfully designed lighting highlights its facades and minarets, creating a mystical and majestic atmosphere.",
        "mapsQuery": "Al Sahaba Mosque Sharm El-Sheikh"
      },
      {
        "id": "eglise",
        "name": "Coptic Orthodox Church",
        "sub_category_key": "catMonuments",
        "sub_category": "Monuments & Culture",
        "photo_url": "assets/sharm/eglise.jpg",
        "description": "This church is a sanctuary of serenity and spiritual beauty. Vibrant stained-glass windows cast fascinating light patterns inside, while detailed wall frescoes meticulously tell the rich story of Egyptian Coptic tradition. It offers a peaceful retreat for those wishing to discover the region's deep spiritual heritage.",
        "mapsQuery": "Coptic Church Sharm El-Sheikh"
      },
      {
        "id": "hollywood",
        "name": "Hollywood Sharm El-Sheikh",
        "sub_category_key": "catMonuments",
        "sub_category": "Monuments & Culture",
        "photo_url": "assets/sharm/h.jpg",
        "description": "A spectacular theme park, this unique attraction transports visitors into a world of fantasy. Featuring giant replicas of iconic statues, choreographed dancing fountains, and magical light displays, it is a must-visit for families and photography enthusiasts seeking lively entertainment.",
        "mapsQuery": "Hollywood Sharm El-Sheikh"
      },
      {
        "id": "old_market",
        "name": "Old Town Market",
        "sub_category_key": "catMonuments",
        "sub_category": "Monuments & Culture",
        "photo_url": "assets/sharm/la.jpg",
        "description": "The Old Market is the vibrant, historic heart of Sharm El-Sheikh. A lively maze of alleys where you can experience the true essence of local culture. Surrounded by traditional crafts, fragrant spice stalls, and souvenir shops, visitors immerse themselves in an authentic atmosphere and local cuisine.",
        "mapsQuery": "Old Market Sharm El-Sheikh"
      },
      {
        "id": "saint_catherine",
        "name": "Saint Catherine's Monastery",
        "sub_category_key": "catExcursions",
        "sub_category": "Must-See Excursions",
        "photo_url": "assets/sharm/saint.webp",
        "description": "Nestled at the foot of Mount Sinai, this UNESCO World Heritage site is one of the oldest continuously operating Christian monasteries in the world. It houses an invaluable collection of Byzantine icons, ancient manuscripts, and the famous 'Burning Bush', offering a profound journey through spiritual history.",
        "mapsQuery": "Saint Catherine's Monastery Sinai"
      },
      {
        "id": "mount_sinai",
        "name": "Mount Sinai",
        "sub_category_key": "catExcursions",
        "sub_category": "Must-See Excursions",
        "photo_url": "assets/sharm/mont.jpeg",
        "description": "A site of immense symbolic importance, Mount Sinai is a revered destination for pilgrims and hikers. Typically climbed overnight to reach the summit before dawn, hikers are rewarded with a breathtaking sunrise igniting the desert peaks in a truly unforgettable spectacle.",
        "mapsQuery": "Mount Sinai Egypt"
      },
      {
        "id": "dahab",
        "name": "Dahab",
        "sub_category_key": "catExcursions",
        "sub_category": "Must-See Excursions",
        "photo_url": "assets/sharm/Dahab.webp",
        "description": "Once a quiet fishing village, Dahab has evolved into a famous coastal haven with a unique bohemian vibe. Renowned for its laid-back lifestyle and world-class diving sites, it seamlessly blends Bedouin tradition with relaxed seaside charm.",
        "mapsQuery": "Dahab South Sinai"
      },
      {
        "id": "tiran_island",
        "name": "Tiran Island",
        "sub_category_key": "catSeaNature",
        "sub_category": "Sea & Nature",
        "photo_url": "assets/sharm/tirana.jpg",
        "description": "Tiran Island is a marine sanctuary situated at the mouth of the Gulf of Aqaba. Surrounded by pristine coral reefs teeming with marine life—including sea turtles, rays, and vibrant tropical fish—it offers unparalleled snorkeling and diving in a natural open-air aquarium.",
        "mapsQuery": "Tiran Island Red Sea"
      },
      {
        "id": "red_sea",
        "name": "The Red Sea",
        "sub_category_key": "catSeaNature",
        "sub_category": "Sea & Nature",
        "photo_url": "assets/sharm/mer.jpg",
        "description": "The Red Sea is Egypt's coastal crown jewel, offering world-class swimming, snorkeling, and diving conditions. With warm turquoise waters year-round and rich marine biodiversity, exploring its coral gardens is a constantly breathtaking underwater adventure.",
        "mapsQuery": "Red Sea Sharm El-Sheikh"
      },
      {
        "id": "blue_hole",
        "name": "Dahab Blue Hole",
        "sub_category_key": "catSeaNature",
        "sub_category": "Sea & Nature",
        "photo_url": "assets/sharm/ll.jpg",
        "description": "The Dahab Blue Hole is a world-renowned submarine sinkhole that fascinates divers globally. Dropping into dizzying depths and framed by dense coral walls, the dramatic shift from shallow turquoise lagoon to abyssal deep blue creates a thrilling underwater landmark.",
        "mapsQuery": "Blue Hole Dahab"
      },
    ],
    'ar': [
      {
        "id": "mosque",
        "name": "مسجد الصحابة",
        "sub_category_key": "catMonuments",
        "sub_category": "المعالم والثقافة",
        "photo_url": "assets/sharm/mosque.jpeg",
        "description": "يقع هذا المسجد في قلب المدينة القديمة، ويُعد شاهكاراً معمارياً حقيقياً. يجمع بأناقة بين الأنماط العثمانية والفاطمية والمملوكية، ويثير الإعجاب بتفاصيله المعقدة ومأذنتيه الشامختين. عند حلول الليل، تبرز إضاءته المدروسة بعناية واجهاته ومآذنه، مما يخلق أجواءً ساحرة ومجيدة تجذب الزوار من جميع أنحاء العالم.",
        "mapsQuery": "Al Sahaba Mosque Sharm El-Sheikh"
      },
      {
        "id": "eglise",
        "name": "الكنيسة القبطية الأرثوذكسية",
        "sub_category_key": "catMonuments",
        "sub_category": "المعالم والثقافة",
        "photo_url": "assets/sharm/eglise.jpg",
        "description": "تعتبر هذه الكنيسة جوهرة من الهدوء والجمال الروحي. تعكس زجاجياتها الملونة الزاهية ألعاباً ضوئية ساحرة بالداخل، بينما تحكي جدارياتها المفصلة بدقة التقاليد القبطية المصرية الغنية. إنها واحة من السلام لمن يرغب في اكتشاف العمق الثقافي والروحي للمنطقة.",
        "mapsQuery": "Coptic Church Sharm El-Sheikh"
      },
      {
        "id": "hollywood",
        "name": "هوليوود شرم الشيخ",
        "sub_category_key": "catMonuments",
        "sub_category": "المعالم والثقافة",
        "photo_url": "assets/sharm/h.jpg",
        "description": "متنزّه ترفيهي مذهل ينقل الزوار إلى عالم خيالي حافل بالإثارة. يضم مجسمات عملاقة لتماثيل شهيرة، ونوافير راقصة ومجسمات مضيئة ساحرة، مما يجعله وجهة مثالية للعائلات ومحبي التصوير الفوتوغرافي للاستمتاع بأجواء مليئة بالبهجة والمرح.",
        "mapsQuery": "Hollywood Sharm El-Sheikh"
      },
      {
        "id": "old_market",
        "name": "المدينة القديمة",
        "sub_category_key": "catMonuments",
        "sub_category": "المعالم والثقافة",
        "photo_url": "assets/sharm/la.jpg",
        "description": "يمثل السوق القديم النابض بالحياة القلب التاريخي لشرم الشيخ. إنه متاهة حية من الأزقة المليئة بالمصنوعات اليدوية التقليدية والتوابل العطرة ومتاجر الهدايا التذكارية، حيث ينغمس الزائر في أجواء أصلية ويتذوق أفضل المأكولات المصرية.",
        "mapsQuery": "Old Market Sharm El-Sheikh"
      },
      {
        "id": "saint_catherine",
        "name": "دير سانت كاترين",
        "sub_category_key": "catExcursions",
        "sub_category": "رحلات لا بد منها",
        "photo_url": "assets/sharm/saint.webp",
        "description": "يقع هذا الدير عند قدم جبال سيناء الشامخة، وهو أحد أقدم الأديرة المسيحية المأهولة في العالم. مدرج ضمن التراث العالمي لليونسكو، ويضم مجموعة لا تُقدر بثمن من الأيقونات البيزنطية والمخطوطات القديمة بالإضافة إلى الشجيرة المشتعلة الشهيرة.",
        "mapsQuery": "Saint Catherine's Monastery Sinai"
      },
      {
        "id": "mount_sinai",
        "name": "جبل سيناء",
        "sub_category_key": "catExcursions",
        "sub_category": "رحلات لا بد منها",
        "photo_url": "assets/sharm/mont.jpeg",
        "description": "مكان ذو أهمية رمزية وروحية عظيمة، ويُعد وجهة ممتازة للحجاج ومحبي تسلق الجبال. تتم الصعود عادةً ليلاً للوصول إلى القمة قبل الفجر، حيث يُكافأ الصاعدون بمشهد شروق شمس مذهل يضيء قمم الصحراء في لحظة تأمل لا تُنسى.",
        "mapsQuery": "Mount Sinai Egypt"
      },
      {
        "id": "dahab",
        "name": "دهب",
        "sub_category_key": "catExcursions",
        "sub_category": "رحلات لا بد منها",
        "photo_url": "assets/sharm/Dahab.webp",
        "description": "قرية صيادين سابقة تحولت إلى ملاذ شهير للمسافرين الباحثين عن الهدوء والحرية. تتميز دهب بأجوائها البوهيمية الفريدة وشواطئها الخلابة ومواقع الغوص العالمية، حيث تمزج بين الثقافة البدوية وأسلوب الحياة الاسترخائي على البحر.",
        "mapsQuery": "Dahab South Sinai"
      },
      {
        "id": "tiran_island",
        "name": "جزيرة تيران",
        "sub_category_key": "catSeaNature",
        "sub_category": "البحر والطبيعة",
        "photo_url": "assets/sharm/tirana.jpg",
        "description": "تعتبر جزيرة تيران محمية طبيعية لعشاق البحر. تقع عند مدخل خليج العقبة وتحيط بها شعاب مرجانية من الأجمل والأكثر تنوعاً في البحر الأحمر، حيث تتيح مياهها الكريستالية رؤية السلاحف البحرية والكائنات البحرية الملونة.",
        "mapsQuery": "Tiran Island Red Sea"
      },
      {
        "id": "red_sea",
        "name": "البحر الأحمر",
        "sub_category_key": "catSeaNature",
        "sub_category": "البحر والطبيعة",
        "photo_url": "assets/sharm/mer.jpg",
        "description": "البحر الأحمر هو الجوهرة الساحلية لمصر، ويوفر أروع ظروف السباحة والغوص على مدار العام. بفضل مياهه الفيروزية الدافئة وتنوعه البيولوجي الغني، يُعد الاستكشاف تحت الماء رحلة مذهلة بين الشعاب المرجانية والأحياء البحرية.",
        "mapsQuery": "Red Sea Sharm El-Sheikh"
      },
      {
        "id": "blue_hole",
        "name": "الثقب الأزرق بدهب",
        "sub_category_key": "catSeaNature",
        "sub_category": "البحر والطبيعة",
        "photo_url": "assets/sharm/ll.jpg",
        "description": "يُعد الثقب الأزرق في دهب موقعاً أسطورياً يجذب الغواصين من جميع أنحاء العالم. وهو حفرة عميقة تحت الماء محاطة بالشعاب المرجانية، ويتيح التباين المذهل بين الأزرق الفاتح والأزرق الداكن للعمق تجربة غوص فريدة وساحرة.",
        "mapsQuery": "Blue Hole Dahab"
      },
    ],
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
      _localizedSharmData[_lang] ?? _localizedSharmData['fr']!;

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
                item['mapsQuery'] as String? ?? '${item['name']} Sharm El-Sheikh'),
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
  'mosque': {
    'related': ['old_market', 'eglise', 'hollywood'],
    'fr': {
      'duration': "30 à 45 min",
      'best': "Au crépuscule, quand l'éclairage s'allume",
      'tip': "Portez une tenue couvrante et préparez-vous à vous déchausser. Renseignez-vous sur place sur les horaires de visite, qui s'adaptent aux heures de prière.",
      'fact': "Sharm El-Sheikh n'était qu'un petit village de pêcheurs il y a quelques décennies : la mosquée, de construction récente, reprend l'élégance des grandes mosquées historiques d'Égypte.",
      'hl': [
        {'t': "Un mélange de styles", 'd': "Ses lignes empruntent aux traditions ottomane, fatimide et mamelouke, avec une profusion de détails."},
        {'t': "Des minarets illuminés", 'd': "À la nuit tombée, l'éclairage dessine la silhouette de la mosquée sur le ciel."},
        {'t': "Au cœur de la vieille ville", 'd': "Elle se visite facilement avec une balade dans les ruelles voisines."},
      ],
    },
    'en': {
      'duration': "30 to 45 minutes",
      'best': "At dusk, when the lighting comes on",
      'tip': "Wear modest clothing and be ready to remove your shoes. Ask on site about visiting hours, which adapt to prayer times.",
      'fact': "Sharm El-Sheikh was just a small fishing village a few decades ago: the mosque, recently built, echoes the elegance of Egypt's great historic mosques.",
      'hl': [
        {'t': "A blend of styles", 'd': "Its lines draw on Ottoman, Fatimid and Mamluk traditions, with a wealth of detail."},
        {'t': "Illuminated minarets", 'd': "At nightfall, the lighting traces the mosque's silhouette against the sky."},
        {'t': "In the heart of the old town", 'd': "It is easily combined with a stroll through the neighbouring lanes."},
      ],
    },
    'ar': {
      'duration': "من 30 إلى 45 دقيقة",
      'best': "عند الغسق حين تُضاء الأنوار",
      'tip': "ارتدِ ملابس محتشمة واستعد لخلع حذائك. واسأل في الموقع عن مواعيد الزيارة التي تتكيف مع أوقات الصلاة.",
      'fact': "كانت شرم الشيخ قرية صيد صغيرة قبل عقود قليلة، ويستلهم المسجد حديث البناء أناقة المساجد التاريخية الكبرى في مصر.",
      'hl': [
        {'t': "مزيج من الأنماط", 'd': "تستمد خطوطه من التقاليد العثمانية والفاطمية والمملوكية مع وفرة من التفاصيل."},
        {'t': "مآذن مضاءة", 'd': "عند حلول الليل ترسم الإضاءة صورة المسجد على صفحة السماء."},
        {'t': "في قلب المدينة القديمة", 'd': "يسهل جمع زيارته مع جولة في الأزقة المجاورة."},
      ],
    },
  },
  'eglise': {
    'related': ['mosque', 'old_market', 'saint_catherine'],
    'fr': {
      'duration': "30 à 45 min",
      'best': "En matinée, en dehors des offices",
      'tip': "Habillez-vous avec respect (épaules et genoux couverts) et renseignez-vous sur les horaires d'ouverture, qui varient selon les offices.",
      'fact': "Selon la tradition, l'Église d'Égypte aurait été fondée par saint Marc au Ier siècle ; l'Église copte orthodoxe est aujourd'hui la principale communauté chrétienne du pays.",
      'hl': [
        {'t': "Des vitraux colorés", 'd': "La lumière du jour les traverse et dessine des taches de couleurs sur les murs."},
        {'t': "Des fresques détaillées", 'd': "Les peintures murales racontent des épisodes de la tradition copte."},
        {'t': "Un havre de paix", 'd': "Un lieu calme, à l'écart de l'animation balnéaire."},
      ],
    },
    'en': {
      'duration': "30 to 45 minutes",
      'best': "Mid-morning, outside services",
      'tip': "Dress respectfully (shoulders and knees covered) and check opening hours, which vary with services.",
      'fact': "According to tradition, the Church of Egypt was founded by Saint Mark in the 1st century; the Coptic Orthodox Church is today the country's main Christian community.",
      'hl': [
        {'t': "Coloured stained glass", 'd': "Daylight passes through them and paints patches of colour on the walls."},
        {'t': "Detailed frescoes", 'd': "The wall paintings recount episodes from the Coptic tradition."},
        {'t': "A haven of peace", 'd': "A calm place, away from the seaside bustle."},
      ],
    },
    'ar': {
      'duration': "من 30 إلى 45 دقيقة",
      'best': "في الصباح بعيدًا عن أوقات القداس",
      'tip': "ارتدِ ملابس محتشمة تغطي الكتفين والركبتين، واسأل عن مواعيد الفتح التي تختلف بحسب القداسات.",
      'fact': "وفق التقليد أسس القديس مرقس الكنيسة في مصر في القرن الأول، وتُعد الكنيسة القبطية الأرثوذكسية اليوم أكبر طائفة مسيحية في البلاد.",
      'hl': [
        {'t': "زجاج ملون", 'd': "يخترقه ضوء النهار ويرسم بقعًا من الألوان على الجدران."},
        {'t': "جداريات مفصلة", 'd': "تروي اللوحات الجدارية مشاهد من التقاليد القبطية."},
        {'t': "واحة من السكينة", 'd': "مكان هادئ بعيد عن صخب الساحل."},
      ],
    },
  },
  'hollywood': {
    'related': ['old_market', 'mosque', 'red_sea'],
    'fr': {
      'duration': "2 h à 3 h",
      'best': "En soirée, pour les fontaines et les lumières",
      'tip': "L'endroit s'anime surtout à la nuit tombée : vérifiez les horaires des spectacles et les tarifs sur place avant de venir.",
      'fact': "Le soleil brille presque toute l'année à Sharm El-Sheikh, ce qui en fait une station balnéaire ouverte en toutes saisons, avec des animations tard dans la soirée.",
      'hl': [
        {'t': "Des statues géantes", 'd': "Des répliques monumentales de statues célèbres offrent un décor idéal pour les photos."},
        {'t': "Des fontaines dansantes", 'd': "Jeux d'eau et de lumière sont chorégraphiés sur de la musique."},
        {'t': "Une sortie en famille", 'd': "Une ambiance festive et ludique qui plaît aux petits comme aux grands."},
      ],
    },
    'en': {
      'duration': "2 to 3 hours",
      'best': "In the evening, for the fountains and lights",
      'tip': "The place comes alive mostly after dark: check show times and prices on site before you go.",
      'fact': "The sun shines almost all year round in Sharm El-Sheikh, making it a resort open in every season, with entertainment late into the evening.",
      'hl': [
        {'t': "Giant statues", 'd': "Monumental replicas of famous statues make an ideal backdrop for photos."},
        {'t': "Dancing fountains", 'd': "Water and light displays are choreographed to music."},
        {'t': "A family outing", 'd': "A festive, playful atmosphere that appeals to young and old."},
      ],
    },
    'ar': {
      'duration': "من ساعتين إلى 3 ساعات",
      'best': "في المساء لمشاهدة النوافير والأضواء",
      'tip': "يزدهر المكان خاصة بعد حلول الظلام، فتحقق من مواعيد العروض والأسعار في الموقع قبل المجيء.",
      'fact': "تسطع الشمس تقريبًا طوال العام في شرم الشيخ، مما يجعلها منتجعًا مفتوحًا في كل الفصول مع فعاليات تمتد حتى ساعات متأخرة.",
      'hl': [
        {'t': "تماثيل عملاقة", 'd': "نسخ ضخمة لتماثيل شهيرة تصنع خلفية مثالية للصور."},
        {'t': "نوافير راقصة", 'd': "عروض ماء وضوء منسقة على إيقاع الموسيقى."},
        {'t': "نزهة عائلية", 'd': "أجواء احتفالية ومرحة تناسب الكبار والصغار."},
      ],
    },
  },
  'old_market': {
    'related': ['mosque', 'hollywood', 'eglise'],
    'fr': {
      'duration': "1 h 30 à 2 h",
      'best': "En soirée, quand l'air se rafraîchit",
      'tip': "Marchandez avec le sourire et faites une pause pour un thé à la menthe ou un jus de canne à sucre pressé devant vous.",
      'fact': "Le mot arabe « sharm » désigne une baie ou une crique : Sharm El-Sheikh signifie littéralement « la baie du cheikh ».",
      'hl': [
        {'t': "Épices et parfums", 'd': "Les étals de safran, de cumin et d'huiles parfumées embaument les ruelles."},
        {'t': "Artisanat et souvenirs", 'd': "Lanternes, papyrus, bijoux et textiles se côtoient dans les petites boutiques."},
        {'t': "Gastronomie locale", 'd': "Restaurants et stands proposent une cuisine égyptienne généreuse."},
      ],
    },
    'en': {
      'duration': "1.5 to 2 hours",
      'best': "In the evening, as the air cools",
      'tip': "Haggle with a smile and stop for a mint tea or a sugarcane juice pressed in front of you.",
      'fact': "The Arabic word “sharm” means a bay or cove: Sharm El-Sheikh literally means “the sheikh's bay”.",
      'hl': [
        {'t': "Spices and perfumes", 'd': "Stalls of saffron, cumin and scented oils perfume the alleys."},
        {'t': "Crafts and souvenirs", 'd': "Lanterns, papyrus, jewellery and textiles sit side by side in small shops."},
        {'t': "Local cuisine", 'd': "Restaurants and stalls serve hearty Egyptian food."},
      ],
    },
    'ar': {
      'duration': "من ساعة ونصف إلى ساعتين",
      'best': "في المساء حين يبرد الهواء",
      'tip': "فاصِل بابتسامة وخذ استراحة لشرب شاي بالنعناع أو عصير قصب يُعصر أمامك.",
      'fact': "كلمة «شرم» العربية تعني الخليج الصغير أو الخور، ومعنى شرم الشيخ حرفيًا «خليج الشيخ».",
      'hl': [
        {'t': "التوابل والعطور", 'd': "تعطر أكشاك الزعفران والكمون والزيوت العطرية الأزقة."},
        {'t': "حرف وهدايا تذكارية", 'd': "تتجاور الفوانيس والبردي والمجوهرات والمنسوجات في المتاجر الصغيرة."},
        {'t': "المطبخ المحلي", 'd': "تقدم المطاعم والأكشاك أطباقًا مصرية سخية."},
      ],
    },
  },
  'saint_catherine': {
    'related': ['mount_sinai', 'dahab', 'eglise'],
    'fr': {
      'duration': "1 h 30 sur place (environ 3 h de route depuis Sharm)",
      'best': "En matinée",
      'tip': "Le monastère n'est ouvert aux visiteurs que quelques heures le matin et pas tous les jours : vérifiez avant de partir. Une tenue couvrante est exigée.",
      'fact': "Édifié au VIe siècle sous l'empereur Justinien, le monastère est inscrit à l'UNESCO depuis 2002. Il conserve l'une des plus riches bibliothèques de manuscrits anciens au monde.",
      'hl': [
        {'t': "Le Buisson ardent", 'd': "Selon la tradition, il s'agit du buisson dont parle la Bible dans l'épisode de Moïse."},
        {'t': "Une collection d'icônes", 'd': "Le monastère garde des icônes byzantines parmi les plus anciennes qui subsistent."},
        {'t': "Des manuscrits précieux", 'd': "La bibliothèque abrite des milliers de manuscrits, dont des textes très anciens."},
      ],
    },
    'en': {
      'duration': "1.5 hours on site (about 3 hours' drive from Sharm)",
      'best': "Mid-morning",
      'tip': "The monastery is open to visitors only a few hours in the morning and not every day: check before setting out. Modest dress is required.",
      'fact': "Built in the 6th century under Emperor Justinian, the monastery has been a UNESCO site since 2002. It holds one of the richest libraries of ancient manuscripts in the world.",
      'hl': [
        {'t': "The Burning Bush", 'd': "By tradition, this is the bush mentioned in the Bible in the story of Moses."},
        {'t': "A collection of icons", 'd': "The monastery keeps some of the oldest Byzantine icons that survive."},
        {'t': "Precious manuscripts", 'd': "The library houses thousands of manuscripts, including very ancient texts."},
      ],
    },
    'ar': {
      'duration': "ساعة ونصف في الموقع (نحو 3 ساعات بالسيارة من شرم الشيخ)",
      'best': "في الصباح",
      'tip': "لا يفتح الدير للزوار إلا بضع ساعات صباحًا وليس كل الأيام، فتحقق قبل الانطلاق. ويُشترط ارتداء ملابس محتشمة.",
      'fact': "شُيّد الدير في القرن السادس في عهد الإمبراطور جستنيان، وهو مدرج لدى اليونسكو منذ عام 2002. ويحتفظ بواحدة من أغنى مكتبات المخطوطات القديمة في العالم.",
      'hl': [
        {'t': "العليقة المشتعلة", 'd': "وفق التقليد هي الشجيرة التي ورد ذكرها في الكتاب المقدس في قصة موسى."},
        {'t': "مجموعة من الأيقونات", 'd': "يحتفظ الدير بأيقونات بيزنطية من أقدم ما بقي."},
        {'t': "مخطوطات نفيسة", 'd': "تضم المكتبة آلاف المخطوطات ومنها نصوص قديمة جدًا."},
      ],
    },
  },
  'mount_sinai': {
    'related': ['saint_catherine', 'dahab', 'blue_hole'],
    'fr': {
      'duration': "3 à 4 h de montée, départ en pleine nuit",
      'best': "Avant l'aube, pour le lever du soleil",
      'tip': "Emportez une lampe frontale, des vêtements chauds même en été (il fait froid au sommet), de l'eau et de bonnes chaussures. Un chameau peut vous aider sur une partie du chemin.",
      'fact': "Le sommet culmine à environ 2 285 mètres. Au dernier tronçon, on gravit environ 3 750 marches taillées dans la roche, surnommées l'escalier de la Pénitence.",
      'hl': [
        {'t': "Le chemin des chameaux", 'd': "Un sentier plus doux, emprunté à pied ou à dos de chameau, mène vers les pentes supérieures."},
        {'t': "L'escalier de la Pénitence", 'd': "Les marches de pierre conduisent au sommet dans l'obscurité, éclairées par les lampes frontales."},
        {'t': "Le lever du soleil", 'd': "La lumière embrase les cimes rocheuses et dévoile un océan de montagnes."},
      ],
    },
    'en': {
      'duration': "3 to 4 hours' climb, starting in the middle of the night",
      'best': "Before dawn, for sunrise",
      'tip': "Bring a headlamp, warm clothes even in summer (it is cold at the summit), water and good shoes. A camel can help you along part of the route.",
      'fact': "The summit peaks at about 2,285 metres. On the last stretch, you climb some 3,750 steps cut into the rock, nicknamed the Steps of Penance.",
      'hl': [
        {'t': "The camel path", 'd': "A gentler trail, walked or ridden by camel, leads toward the upper slopes."},
        {'t': "The Steps of Penance", 'd': "Stone steps lead to the summit in the dark, lit by headlamps."},
        {'t': "The sunrise", 'd': "Light sets the rocky peaks ablaze and reveals a sea of mountains."},
      ],
    },
    'ar': {
      'duration': "من 3 إلى 4 ساعات صعودًا، والانطلاق في منتصف الليل",
      'best': "قبل الفجر لمشاهدة الشروق",
      'tip': "احمل مصباحًا للرأس وملابس دافئة حتى في الصيف (فالجو بارد عند القمة) والماء وحذاءً جيدًا. ويمكن لجمل أن يساعدك في جزء من الطريق.",
      'fact': "يبلغ ارتفاع القمة نحو 2285 مترًا. وفي المرحلة الأخيرة تصعد نحو 3750 درجة منحوتة في الصخر تُعرف بسلم التوبة.",
      'hl': [
        {'t': "درب الجمال", 'd': "مسار أخف يُسلك مشيًا أو على ظهر جمل ويقود إلى المنحدرات العليا."},
        {'t': "سلم التوبة", 'd': "تقود درجات الحجر إلى القمة في الظلام على ضوء المصابيح."},
        {'t': "شروق الشمس", 'd': "يشعل الضوء القمم الصخرية ويكشف بحرًا من الجبال."},
      ],
    },
  },
  'dahab': {
    'related': ['blue_hole', 'mount_sinai', 'red_sea'],
    'fr': {
      'duration': "Une journée",
      'best': "Toute l'année, avec une préférence pour le printemps et l'automne",
      'tip': "Promenez-vous sur le front de mer, où cafés et restaurants se partagent la plage, et profitez-en pour tester le snorkeling depuis le rivage.",
      'fact': "Dahab signifie « or » en arabe, en référence au sable doré de sa baie.",
      'hl': [
        {'t': "Le front de mer d'Assalah", 'd': "Cafés, boutiques et restaurants bordent la plage dans une ambiance détendue."},
        {'t': "Plongée et snorkeling", 'd': "Les récifs se trouvent tout près du rivage, accessibles dès les premiers mètres."},
        {'t': "Vent et kitesurf", 'd': "Les conditions de vent attirent aussi les amateurs de glisse."},
      ],
    },
    'en': {
      'duration': "A day",
      'best': "Year round, with a preference for spring and autumn",
      'tip': "Stroll along the seafront, where cafés and restaurants share the beach, and take the chance to try snorkelling from the shore.",
      'fact': "Dahab means “gold” in Arabic, in reference to the golden sand of its bay.",
      'hl': [
        {'t': "The Assalah seafront", 'd': "Cafés, shops and restaurants line the beach in a relaxed atmosphere."},
        {'t': "Diving and snorkelling", 'd': "The reefs lie close to the shore, reachable from the first few metres."},
        {'t': "Wind and kitesurfing", 'd': "The wind conditions also attract watersports fans."},
      ],
    },
    'ar': {
      'duration': "يوم واحد",
      'best': "على مدار العام مع تفضيل الربيع والخريف",
      'tip': "تجول على الواجهة البحرية حيث تتقاسم المقاهي والمطاعم الشاطئ، وانتهز الفرصة لتجربة الغطس السطحي من الشاطئ.",
      'fact': "تعني «دهب» الذهب بالعربية في إشارة إلى رمال خليجها الذهبية.",
      'hl': [
        {'t': "الواجهة البحرية في أسالة", 'd': "تصطف المقاهي والمتاجر والمطاعم على الشاطئ في أجواء مريحة."},
        {'t': "الغوص والغطس السطحي", 'd': "الشعاب قريبة من الشاطئ ويمكن الوصول إليها من الأمتار الأولى."},
        {'t': "الرياح والكايت سيرفينغ", 'd': "تجذب ظروف الرياح أيضًا عشاق الرياضات المائية."},
      ],
    },
  },
  'tiran_island': {
    'related': ['red_sea', 'blue_hole', 'dahab'],
    'fr': {
      'duration': "Une journée (6 à 8 h)",
      'best': "Le matin, quand la mer est calme",
      'tip': "Les excursions partent en bateau depuis Sharm et se concentrent sur les récifs du détroit, avec plusieurs arrêts de snorkeling. Respectez les règles de protection du corail.",
      'fact': "Le détroit de Tiran, entre le golfe d'Aqaba et la mer Rouge, abrite des récifs célèbres : Jackson, Woodhouse, Thomas et Gordon.",
      'hl': [
        {'t': "Des récifs coralliens préservés", 'd': "Murs de coraux colorés et jardins sous-marins s'étendent à perte de vue."},
        {'t': "Tortues et raies", 'd': "Les eaux claires permettent d'observer une faune marine variée."},
        {'t': "Une journée en mer", 'd': "Traversée en bateau, snorkeling et déjeuner à bord rythment l'excursion."},
      ],
    },
    'en': {
      'duration': "A day (6 to 8 hours)",
      'best': "In the morning, when the sea is calm",
      'tip': "Excursions leave by boat from Sharm and focus on the reefs of the strait, with several snorkelling stops. Follow the coral protection rules.",
      'fact': "The Strait of Tiran, between the Gulf of Aqaba and the Red Sea, hosts famous reefs: Jackson, Woodhouse, Thomas and Gordon.",
      'hl': [
        {'t': "Pristine coral reefs", 'd': "Walls of coloured coral and underwater gardens stretch as far as the eye can see."},
        {'t': "Turtles and rays", 'd': "The clear waters let you observe a varied marine fauna."},
        {'t': "A day at sea", 'd': "A boat crossing, snorkelling and lunch on board punctuate the excursion."},
      ],
    },
    'ar': {
      'duration': "يوم كامل (من 6 إلى 8 ساعات)",
      'best': "في الصباح حين يكون البحر هادئًا",
      'tip': "تنطلق الرحلات بالقارب من شرم الشيخ وتركز على شعاب المضيق مع عدة محطات للغطس السطحي. التزم بقواعد حماية المرجان.",
      'fact': "يضم مضيق تيران بين خليج العقبة والبحر الأحمر شعابًا شهيرة هي جاكسون ووودهاوس وتوماس وغوردون.",
      'hl': [
        {'t': "شعاب مرجانية محفوظة", 'd': "جدران من المرجان الملون وحدائق تحت الماء تمتد على مد البصر."},
        {'t': "سلاحف وأسماك الراي", 'd': "تتيح المياه الصافية مشاهدة حياة بحرية متنوعة."},
        {'t': "يوم في البحر", 'd': "تتخلل الرحلة عبور بالقارب وغطس سطحي وغداء على متن المركب."},
      ],
    },
  },
  'red_sea': {
    'related': ['tiran_island', 'blue_hole', 'dahab'],
    'fr': {
      'duration': "Selon l'activité : de 2 h à une journée",
      'best': "Toute l'année : l'eau reste douce en toute saison",
      'tip': "Choisissez un centre de plongée agréé, ne touchez pas et ne piétinez pas le corail, et utilisez une crème solaire respectueuse des récifs.",
      'fact': "La mer Rouge abrite plus d'un millier d'espèces de poissons, dont de nombreuses ne se trouvent nulle part ailleurs. Le parc national de Ras Mohammed, à la pointe du Sinaï, est tout proche de Sharm.",
      'hl': [
        {'t': "Des eaux turquoise", 'd': "Claires et chaudes, elles se prêtent à la baignade comme au snorkeling toute l'année."},
        {'t': "Des jardins de corail", 'd': "Coraux colorés et poissons tropicaux se découvrent près du rivage."},
        {'t': "Le parc de Ras Mohammed", 'd': "Un site protégé réputé, à la pointe sud du Sinaï, à courte distance de Sharm."},
      ],
    },
    'en': {
      'duration': "Depending on the activity: from 2 hours to a full day",
      'best': "Year round: the water stays warm in every season",
      'tip': "Choose a licensed dive centre, don't touch or stand on the coral, and use reef-safe sunscreen.",
      'fact': "The Red Sea is home to more than a thousand species of fish, many found nowhere else. Ras Mohammed National Park, at the tip of the Sinai, is close to Sharm.",
      'hl': [
        {'t': "Turquoise waters", 'd': "Clear and warm, they suit swimming and snorkelling all year long."},
        {'t': "Coral gardens", 'd': "Coloured corals and tropical fish can be found close to shore."},
        {'t': "Ras Mohammed Park", 'd': "A renowned protected site at the southern tip of the Sinai, a short distance from Sharm."},
      ],
    },
    'ar': {
      'duration': "بحسب النشاط: من ساعتين إلى يوم كامل",
      'best': "على مدار العام فالماء دافئ في كل الفصول",
      'tip': "اختر مركز غوص مرخصًا، ولا تلمس المرجان ولا تقف عليه، واستخدم واقيًا من الشمس صديقًا للشعاب.",
      'fact': "يضم البحر الأحمر أكثر من ألف نوع من الأسماك، كثير منها لا يوجد في مكان آخر. ويقع متنزه رأس محمد الوطني عند طرف سيناء قرب شرم الشيخ.",
      'hl': [
        {'t': "مياه فيروزية", 'd': "صافية ودافئة، تصلح للسباحة والغطس السطحي طوال العام."},
        {'t': "حدائق مرجانية", 'd': "يمكن اكتشاف المرجان الملون والأسماك الاستوائية قرب الشاطئ."},
        {'t': "متنزه رأس محمد", 'd': "موقع محمي شهير عند الطرف الجنوبي لسيناء على مسافة قصيرة من شرم الشيخ."},
      ],
    },
  },
  'blue_hole': {
    'related': ['dahab', 'red_sea', 'tiran_island'],
    'fr': {
      'duration': "2 h à 3 h",
      'best': "Le matin, avant l'arrivée des groupes",
      'tip': "Les plongées profondes sont réservées aux plongeurs expérimentés et encadrés. Le snorkeling le long du bord est accessible à tous et donne déjà un bel aperçu du site.",
      'fact': "Le gouffre descend à plus de 100 mètres. Une arche sous-marine, vers 55 mètres de profondeur, en a fait un site célèbre mais exigeant, qui ne pardonne pas les erreurs.",
      'hl': [
        {'t': "Un gouffre sous-marin", 'd': "Le fond tombe à pic, depuis le lagon turquoise vers un bleu profond."},
        {'t': "Des récifs denses", 'd': "Les parois du gouffre sont couvertes de coraux et de poissons."},
        {'t': "Le snorkeling depuis le bord", 'd': "On entre depuis la plage et on flotte au-dessus du vide, sans plonger profond."},
      ],
    },
    'en': {
      'duration': "2 to 3 hours",
      'best': "In the morning, before the groups arrive",
      'tip': "Deep dives are reserved for experienced, supervised divers. Snorkelling along the edge is open to everyone and already gives a fine overview of the site.",
      'fact': "The sinkhole drops to more than 100 metres. An underwater arch, around 55 metres deep, has made it a famous but demanding site that does not forgive mistakes.",
      'hl': [
        {'t': "An underwater sinkhole", 'd': "The bottom falls away sharply, from the turquoise lagoon into deep blue."},
        {'t': "Dense reefs", 'd': "The walls of the sinkhole are covered in corals and fish."},
        {'t': "Snorkelling from the edge", 'd': "You enter from the beach and float above the void, without diving deep."},
      ],
    },
    'ar': {
      'duration': "من ساعتين إلى 3 ساعات",
      'best': "في الصباح قبل وصول المجموعات",
      'tip': "الغوص العميق مخصص للغواصين ذوي الخبرة وتحت الإشراف. أما الغطس السطحي على الحافة فمتاح للجميع ويمنح لمحة جيدة عن الموقع.",
      'fact': "ينحدر الثقب إلى أكثر من 100 متر. وقد جعله قوس تحت الماء على عمق نحو 55 مترًا موقعًا شهيرًا لكنه صعب لا يرحم الأخطاء.",
      'hl': [
        {'t': "حفرة عميقة تحت الماء", 'd': "ينحدر القاع فجأة من البحيرة الفيروزية إلى زرقة عميقة."},
        {'t': "شعاب كثيفة", 'd': "تغطي جدران الحفرة المرجانيات والأسماك."},
        {'t': "الغطس السطحي من الحافة", 'd': "تدخل من الشاطئ وتطفو فوق الفراغ دون غوص عميق."},
      ],
    },
  },
};