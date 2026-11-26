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
//  HEURE DE LOUXOR ET CALCUL DU SOLEIL
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

/// Convertit un instant UTC en heure locale de Louxor (fields = heure locale).
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

/// Lever et coucher du soleil à Louxor pour une date (algorithme solaire
/// simplifié, précision de quelques minutes).
_SunDay _sunDay(DateTime cairoDate) {
  const double latDeg = 25.6872;
  const double lonDeg = 32.6396;
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
          Text('25.69°N · 32.64°E',
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
          _KenBurns(child: const _PlaceImage('assets/louxor/k.jpg')),
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
                          child: Text('25.69°N · 32.64°E',
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
class LouxorPage extends StatefulWidget {
  const LouxorPage({super.key});

  @override
  State<LouxorPage> createState() => _LouxorPageState();
}

class _LouxorPageState extends State<LouxorPage> {
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
      'pageTitle': 'Louxor',
      'tagline': 'Le plus grand musée à ciel ouvert du monde',
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
      'catActivities': 'Activités à Louxor',
      'phaseDawn': 'Aube',
      'phaseDay': 'Journée',
      'phaseDusk': 'Heure dorée',
      'phaseNight': 'Nuit',
      'cairoTime': 'Il est {t} à Louxor',
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
      'totalTime': 'Temps à Louxor',
      'hUnit': 'h',
      'mUnit': 'min',
      'btnStamp': 'Tamponner',
      'btnStampDone': 'Tamponné',
      'btnTimer': 'Minuteur',
      'btnMaps': 'Itinéraire',
      'catValleyKings': 'Vallée des Rois & Reines',
      'catValleyArtisans': 'Vallée des artisans',
      'catCulture': 'Culture et savoir',
    },
    'en': {
      'pageTitle': 'Luxor',
      'tagline': "The world's greatest open-air museum",
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
      'catHistory': 'Historical Places',
      'catArch': 'Architecture',
      'catRelaxation': 'Relaxation Spots',
      'catActivities': 'Activities in Luxor',
      'phaseDawn': 'Dawn',
      'phaseDay': 'Daylight',
      'phaseDusk': 'Golden hour',
      'phaseNight': 'Night',
      'cairoTime': 'It is {t} in Luxor',
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
      'totalTime': 'Time in Luxor',
      'hUnit': 'h',
      'mUnit': 'min',
      'btnStamp': 'Stamp',
      'btnStampDone': 'Stamped',
      'btnTimer': 'Timer',
      'btnMaps': 'Directions',
      'catValleyKings': 'Valley of the Kings & Queens',
      'catValleyArtisans': 'Valley of the Artisans',
      'catCulture': 'Culture and knowledge',
    },
    'ar': {
      'pageTitle': 'الأقصر',
      'tagline': 'أكبر متحف مفتوح في العالم',
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
      'catHistory': 'أماكن تاريخية',
      'catArch': 'العمارة',
      'catRelaxation': 'أماكن الاسترخاء',
      'catActivities': 'أنشطة في الأقصر',
      'phaseDawn': 'الفجر',
      'phaseDay': 'نهار',
      'phaseDusk': 'الساعة الذهبية',
      'phaseNight': 'الليل',
      'cairoTime': 'الساعة {t} في الأقصر',
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
      'totalTime': 'الوقت في الأقصر',
      'hUnit': 'س',
      'mUnit': 'د',
      'btnStamp': 'ختم',
      'btnStampDone': 'تم الختم',
      'btnTimer': 'مؤقت',
      'btnMaps': 'الاتجاهات',
      'catValleyKings': 'وادي الملوك والملكات',
      'catValleyArtisans': 'وادي العمال',
      'catCulture': 'الثقافة والمعرفة',
    },
  };

  // --- DONNÉES TRADUITES PAR LANGUE ---
  static const Map<String, List<Map<String, dynamic>>> _localizedLouxorData = {
    'fr': [
      {
        "id": "karnak_temple",
        "name": "Le temple de Karnak",
        "sub_category_key": "catMonuments",
        "sub_category": "Monuments",
        "photo_url": "assets/louxor/k.jpg",
        "description": "Le plus vaste complexe religieux de l'Antiquité, véritable cité de temples où chaque génération de pharaons a laissé son empreinte. La salle hypostyle, avec ses 134 colonnes monumentales, est une prouesse architecturale qui laisse le visiteur sans voix face à l'immensité de la foi des anciens Égyptiens.",
        "mapsQuery": "Karnak Temple Luxor"
      },
      {
        "id": "karnak_open_air_museum",
        "name": "Le musée en plein air de Karnak",
        "sub_category_key": "catMonuments",
        "sub_category": "Monuments",
        "photo_url": "assets/louxor/temple.jpg",
        "description": "Situé dans l'enceinte de Karnak, ce musée rassemble des éléments architecturaux reconstitués avec soin, comme la chapelle blanche de Sésostris Ier. C'est une étape incontournable pour comprendre l'évolution artistique et technique des constructions religieuses égyptiennes.",
        "mapsQuery": "Open Air Museum Karnak Luxor"
      },
      {
        "id": "luxor_temple",
        "name": "Le temple de Louxor",
        "sub_category_key": "catMonuments",
        "sub_category": "Monuments",
        "photo_url": "assets/louxor/l.jpg",
        "description": "Situé au cœur de la ville moderne, ce temple était dédié au renouveau du pouvoir royal. Magnifiquement éclairé à la tombée de la nuit, il se distingue par ses colosses de Ramsès II, son obélisque solitaire et son atmosphère mystique qui semble défier le temps et l'agitation urbaine environnante.",
        "mapsQuery": "Luxor Temple"
      },
      {
        "id": "royal_tomb",
        "name": "Une tombe royale",
        "sub_category_key": "catValleyKings",
        "sub_category": "Vallée des Rois & Reines",
        "photo_url": "assets/louxor/tombe.jpg",
        "description": "Plongez dans l'intimité des souverains défunts. Les tombes royales offrent une traversée unique vers l'au-delà, où chaque paroi est recouverte de textes sacrés et de fresques aux couleurs éclatantes, protégeant le roi et la reine dans leur voyage éternel.",
        "mapsQuery": "Valley of the Kings Luxor"
      },
      {
        "id": "valley_kings_queens",
        "name": "La vallée des Rois et des Reines",
        "sub_category_key": "catValleyKings",
        "sub_category": "Vallée des Rois & Reines",
        "photo_url": "assets/louxor/rois.jpg",
        "description": "Le site le plus prestigieux de la nécropole thébaine. Entre les montagnes arides de la rive ouest, les pharaons et leurs épouses ont fait creuser leurs demeures secrètes, loin des regards, pour assurer la pérennité de leur règne dans le monde des dieux.",
        "mapsQuery": "Valley of the Kings Luxor"
      },
      {
        "id": "colossi_memnon",
        "name": "Les colosses de Memnon",
        "sub_category_key": "catMonuments",
        "sub_category": "Monuments",
        "photo_url": "assets/louxor/me.jpg",
        "description": "Deux statues monumentales en grès qui trônent fièrement dans la plaine. Bien que le temple funéraire d'Amenhotep III dont elles faisaient partie ait disparu, ces colosses restent des sentinelles impressionnantes, témoins de la grandeur démesurée des constructions impériales de l'époque.",
        "mapsQuery": "Colossi of Memnon Luxor"
      },
      {
        "id": "medinet_habu",
        "name": "Le temple de Medinet Habu",
        "sub_category_key": "catMonuments",
        "sub_category": "Monuments",
        "photo_url": "assets/louxor/habu.jpg",
        "description": "Un temple funéraire d'une richesse exceptionnelle, où les reliefs racontent les batailles victorieuses de Ramsès III contre les peuples de la mer. C'est l'un des rares endroits où la peinture originale des reliefs est encore visible, offrant un contraste saisissant entre la pierre brute et la finesse du détail artistique.",
        "mapsQuery": "Medinet Habu Temple Luxor"
      },
      {
        "id": "deir_el_medina",
        "name": "Deir el Medina",
        "sub_category_key": "catValleyArtisans",
        "sub_category": "Vallée des artisans",
        "photo_url": "assets/louxor/deir.jpg",
        "description": "Le village des artisans qui ont sculpté et peint les chefs-d'œuvre de la Vallée des Rois. Ce lieu offre un regard rare et émouvant sur la vie quotidienne des anciens égyptiens, loin des fastes royaux, avec leurs maisons, leurs ateliers et leurs propres sépultures familiales décorées.",
        "mapsQuery": "Deir el Medina Luxor"
      },
      {
        "id": "hot_air_balloon",
        "name": "Louxor en montgolfière",
        "sub_category_key": "catActivities",
        "sub_category": "Activités à Louxor",
        "photo_url": "assets/louxor/m.jpg",
        "description": "Une expérience aérienne inoubliable au lever du soleil. Survolez le Nil et les sites antiques pour réaliser la grandeur du plan architectural thébain, avec d'un côté la luxuriance des terres fertiles et de l'autre, l'immensité silencieuse des plateaux désertiques.",
        "mapsQuery": "Hot Air Balloon Luxor"
      },
      {
        "id": "nile_boat_ride",
        "name": "Louxor en bateau",
        "sub_category_key": "catActivities",
        "sub_category": "Activités à Louxor",
        "photo_url": "assets/louxor/b.jpg",
        "description": "La navigation sur le Nil, le fleuve nourricier, est l'âme même de Louxor. Que ce soit sur une felouque traditionnelle ou un bateau de croisière, le Nil offre une perspective apaisante et différente sur les rivages, là où la vie agricole continue à suivre le rythme des saisons depuis des millénaires.",
        "mapsQuery": "Felucca ride Luxor Nile"
      },
    ],
    'en': [
      {
        "id": "karnak_temple",
        "name": "Karnak Temple",
        "sub_category_key": "catMonuments",
        "sub_category": "Monuments",
        "photo_url": "assets/louxor/k.jpg",
        "description": "The largest religious complex of antiquity, a true city of temples where every generation of pharaohs left its mark. The hypostyle hall, with its 134 monumental columns, is an architectural feat that leaves visitors awestruck by the scale of ancient Egyptian faith.",
        "mapsQuery": "Karnak Temple Luxor"
      },
      {
        "id": "karnak_open_air_museum",
        "name": "Karnak Open Air Museum",
        "sub_category_key": "catMonuments",
        "sub_category": "Monuments",
        "photo_url": "assets/louxor/temple.jpg",
        "description": "Located within the Karnak precinct, this museum features carefully reconstructed architectural elements, such as the White Chapel of Senusret I. It is an essential stop for understanding the artistic and technical evolution of Egyptian religious buildings.",
        "mapsQuery": "Open Air Museum Karnak Luxor"
      },
      {
        "id": "luxor_temple",
        "name": "Luxor Temple",
        "sub_category_key": "catMonuments",
        "sub_category": "Monuments",
        "photo_url": "assets/louxor/l.jpg",
        "description": "Located in the heart of the modern city, this temple was dedicated to the renewal of royal power. Beautifully illuminated at nightfall, it features colossi of Ramesses II, a solitary obelisk, and a mystical atmosphere that defies time and urban bustle.",
        "mapsQuery": "Luxor Temple"
      },
      {
        "id": "royal_tomb",
        "name": "A Royal Tomb",
        "sub_category_key": "catValleyKings",
        "sub_category": "Valley of the Kings & Queens",
        "photo_url": "assets/louxor/tombe.jpg",
        "description": "Immerse yourself in the sanctuary of deceased rulers. The royal tombs offer a unique journey into the afterlife, where every wall is adorned with sacred texts and brightly colored frescoes protecting the king and queen on their eternal journey.",
        "mapsQuery": "Valley of the Kings Luxor"
      },
      {
        "id": "valley_kings_queens",
        "name": "Valley of the Kings and Queens",
        "sub_category_key": "catValleyKings",
        "sub_category": "Valley of the Kings & Queens",
        "photo_url": "assets/louxor/rois.jpg",
        "description": "The most prestigious site of the Theban necropolis. Among the arid mountains of the West Bank, pharaohs and their wives carved out secret eternal resting places to ensure their reign in the world of the gods.",
        "mapsQuery": "Valley of the Kings Luxor"
      },
      {
        "id": "colossi_memnon",
        "name": "Colossi of Memnon",
        "sub_category_key": "catMonuments",
        "sub_category": "Monuments",
        "photo_url": "assets/louxor/me.jpg",
        "description": "Two monumental sandstone statues standing proudly in the plain. Although the mortuary temple of Amenhotep III they guarded has vanished, these colossi remain impressive sentinels testifying to the grandeur of imperial building projects.",
        "mapsQuery": "Colossi of Memnon Luxor"
      },
      {
        "id": "medinet_habu",
        "name": "Medinet Habu Temple",
        "sub_category_key": "catMonuments",
        "sub_category": "Monuments",
        "photo_url": "assets/louxor/habu.jpg",
        "description": "An exceptionally rich mortuary temple whose reliefs depict the victorious battles of Ramesses III against the Sea Peoples. It is one of the few places where original painted reliefs remain visible, contrasting raw stone with exquisite artistic detail.",
        "mapsQuery": "Medinet Habu Temple Luxor"
      },
      {
        "id": "deir_el_medina",
        "name": "Deir el Medina",
        "sub_category_key": "catValleyArtisans",
        "sub_category": "Valley of the Artisans",
        "photo_url": "assets/louxor/deir.jpg",
        "description": "The village of artisans who carved and painted the masterpieces of the Valley of the Kings. This site offers a rare and moving glimpse into daily life in ancient Egypt, complete with houses, workshops, and beautifully decorated family tombs.",
        "mapsQuery": "Deir el Medina Luxor"
      },
      {
        "id": "hot_air_balloon",
        "name": "Luxor Hot Air Balloon",
        "sub_category_key": "catActivities",
        "sub_category": "Activities in Luxor",
        "photo_url": "assets/louxor/m.jpg",
        "description": "An unforgettable sunrise aerial experience. Soar above the Nile and ancient sites to grasp the grandeur of Thebes' architectural layout, with lush fertile green fields on one side and silent desert plateaus on the other.",
        "mapsQuery": "Hot Air Balloon Luxor"
      },
      {
        "id": "nile_boat_ride",
        "name": "Luxor Boat Tour",
        "sub_category_key": "catActivities",
        "sub_category": "Activities in Luxor",
        "photo_url": "assets/louxor/b.jpg",
        "description": "Sailing on the life-giving Nile is the very soul of Luxor. Whether on a traditional felucca or a cruise boat, the Nile offers a soothing perspective on the banks, where agricultural life has followed the rhythm of seasons for millennia.",
        "mapsQuery": "Felucca ride Luxor Nile"
      },
    ],
    'ar': [
      {
        "id": "karnak_temple",
        "name": "معبد الكرنك",
        "sub_category_key": "catMonuments",
        "sub_category": "المعالم الأثرية",
        "photo_url": "assets/louxor/k.jpg",
        "description": "أكبر مجمع ديني في العصور القديمة، وهو مدينة حقيقية من المعابد حيث تركت كل أجيال الفراعنة بصمتها. قاعة الأعمدة الكبرى، التي تضم 134 عموداً ضخماً، تُعد إنجازاً معمارياً يذهل الزوار أمام عظمة إيمان المصريين القدماء.",
        "mapsQuery": "معبد الكرنك الأقصر"
      },
      {
        "id": "karnak_open_air_museum",
        "name": "متحف الكرنك المفتوح",
        "sub_category_key": "catMonuments",
        "sub_category": "المعالم الأثرية",
        "photo_url": "assets/louxor/temple.jpg",
        "description": "يقع داخل حرم معبد الكرنك، ويضم عناصر معمارية أعيد ترميمها بعناية، مثل المقاصة البيضاء لسنوسرت الأول. يُعد محطة أساسية لفهم التطور الفني والتقني للمباني الدينية المصرية.",
        "mapsQuery": "المتحف المفتوح بالكرنك الأقصر"
      },
      {
        "id": "luxor_temple",
        "name": "معبد الأقصر",
        "sub_category_key": "catMonuments",
        "sub_category": "المعالم الأثرية",
        "photo_url": "assets/louxor/l.jpg",
        "description": "يقع في قلب المدينة الحديثة، وكان مكرساً لتجديد السلطة الملكية. يتميز بإضاءته الساحرة في الليل، وتماثيل رمسيس الثاني الضخمة، والمسلة المنفردة، وأجوائه الصوفية التي تتحدى الزمن وصخب المدينة.",
        "mapsQuery": "معبد الأقصر"
      },
      {
        "id": "royal_tomb",
        "name": "مقبرة ملكية",
        "sub_category_key": "catValleyKings",
        "sub_category": "وادي الملوك والملكات",
        "photo_url": "assets/louxor/tombe.jpg",
        "description": "استكشف الأجواء الخاصة للملوك الراحلين. تقدم المقابر الملكية رحلة فريدة إلى العالم الآخر، حيث تغطي كل جدار نصوص مقدسة وجداريات بألوان زاهية تحمي الملك والملكة في رحلتهما الأبدية.",
        "mapsQuery": "وادي الملوك الأقصر"
      },
      {
        "id": "valley_kings_queens",
        "name": "وادي الملوك والملكات",
        "sub_category_key": "catValleyKings",
        "sub_category": "وادي الملوك والملكات",
        "photo_url": "assets/louxor/rois.jpg",
        "description": "الموقع الأكثر شهرة في جبانة طيبة. بين الجبال الجافة بالبر الغربي، حفر الفراعنة وزوجاتهم مقابرهم السرية بعيداً عن الأعين لضمان خلودهم في عالم الآلهة.",
        "mapsQuery": "وادي الملوك والملكات الأقصر"
      },
      {
        "id": "colossi_memnon",
        "name": "تمثالا ممنون",
        "sub_category_key": "catMonuments",
        "sub_category": "المعالم الأثرية",
        "photo_url": "assets/louxor/me.jpg",
        "description": "تمثالان ضخمان من الحجر الرملي يقفان بشموخ في السهل. رغم اختفاء معبد أمينحتب الثالث الجنائزي الذي كانا يحرسانه، يظل هذان التمثالان شاهدين على العظمة الفائقة للمباني الإمبراطورية في ذلك العصر.",
        "mapsQuery": "تمثالا ممنون الأقصر"
      },
      {
        "id": "medinet_habu",
        "name": "معبد مدينة هابو",
        "sub_category_key": "catMonuments",
        "sub_category": "المعالم الأثرية",
        "photo_url": "assets/louxor/habu.jpg",
        "description": "معبد جنائزي غني للغاية، حيث تحكي نقوشه الملونة المعارك المنتصرة لرمسيس الثالث ضد شعوب البحر. إنه من الأماكن النادرة التي لا تزال فيها الألوان الأصلية للنقوش واضحة ومحتفظة برونقها.",
        "mapsQuery": "معبد مدينة هابو الأقصر"
      },
      {
        "id": "deir_el_medina",
        "name": "دير المدينة",
        "sub_category_key": "catValleyArtisans",
        "sub_category": "وادي العمال",
        "photo_url": "assets/louxor/deir.jpg",
        "description": "قرية العمال والحرفيين الذين نحتوا ولونوا تحف وادي الملوك. يقدم هذا الموقع نظرة نادرة ومؤثرة على الحياة اليومية للمصريين القدماء، مع منازلهم وورشهم ومقابرهم العائلية المزخرفة.",
        "mapsQuery": "دير المدينة الأقصر"
      },
      {
        "id": "hot_air_balloon",
        "name": "الأقصر بالمنطاد الطائر",
        "sub_category_key": "catActivities",
        "sub_category": "أنشطة في الأقصر",
        "photo_url": "assets/louxor/m.jpg",
        "description": "تجربة جوية لا تُنسى عند شروق الشمس. تحليق فوق النيل والمواقع الأثرية لاستيعاب روعة التخطيط المعماري لطيبة، حيث الخضرة الخصبة من جهة وامتداد الصحراء الهادئ من جهة أخرى.",
        "mapsQuery": "منطاد الأقصر"
      },
      {
        "id": "nile_boat_ride",
        "name": "الأقصر بالقارب",
        "sub_category_key": "catActivities",
        "sub_category": "أنشطة في الأقصر",
        "photo_url": "assets/louxor/b.jpg",
        "description": "الإبحار في نهر النيل هو شريان الحياة والروح الحقيقية للأقصر. سواء على متن الفلوكة التقليدية أو سفينة سياحية، يوفر النيل إطلالة مريحة على الضفاف حيث تستمر الحياة الزراعية على إيقاع الفصول منذ آلاف السنين.",
        "mapsQuery": "جولة فلوكة النيل الأقصر"
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
      _localizedLouxorData[_lang] ?? _localizedLouxorData['fr']!;

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
                item['mapsQuery'] as String? ?? '${item['name']} Louxor'),
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
  'karnak_temple': {
    'related': ['karnak_open_air_museum', 'luxor_temple', 'valley_kings_queens'],
    'fr': {
      'duration': "3 à 4 h",
      'best': "Dès l'ouverture, tôt le matin",
      'tip': "Arrivez à l'ouverture pour profiter de la fraîcheur et d'un site encore calme ; prévoyez de l'eau, un chapeau et de bonnes chaussures.",
      'fact': "Le complexe a été agrandi et remanié pendant environ deux mille ans ; la salle hypostyle à elle seule couvre près de 5 000 m², et ses douze colonnes centrales dépassent 20 mètres de haut.",
      'hl': [
        {'t': "La salle hypostyle", 'd': "Une forêt de 134 colonnes couvertes de hiéroglyphes, où la lumière tombe en rais depuis les fenêtres hautes de la nef centrale."},
        {'t': "L'obélisque d'Hatchepsout", 'd': "Taillé dans un seul bloc de granit, il s'élève à près de 30 mètres : l'un des plus hauts obélisques antiques encore debout."},
        {'t': "Le lac sacré", 'd': "Réservé aux purifications des prêtres, il est dominé par un grand scarabée de pierre autour duquel la tradition veut qu'on tourne pour porter chance."},
      ],
    },
    'en': {
      'duration': "3 to 4 hours",
      'best': "First thing in the morning",
      'tip': "Arrive at opening time to enjoy the cool air and a still-quiet site; bring water, a hat and sturdy shoes.",
      'fact': "The complex was enlarged and reworked over some two thousand years; the hypostyle hall alone covers nearly 5,000 m², and its twelve central columns stand over 20 metres tall.",
      'hl': [
        {'t': "The Hypostyle Hall", 'd': "A forest of 134 columns covered in hieroglyphs, where light falls in shafts from the high windows of the central nave."},
        {'t': "Hatshepsut's obelisk", 'd': "Carved from a single block of granite, it rises nearly 30 metres: one of the tallest ancient obelisks still standing."},
        {'t': "The Sacred Lake", 'd': "Used for the priests' purification rituals, it is overlooked by a great stone scarab that, by tradition, visitors walk around for good luck."},
      ],
    },
    'ar': {
      'duration': "من 3 إلى 4 ساعات",
      'best': "في الصباح الباكر عند الافتتاح",
      'tip': "احرص على الوصول عند الافتتاح لتستمتع بالأجواء المنعشة والموقع الهادئ، وخذ معك الماء وقبعة وحذاءً مريحًا.",
      'fact': "توسّع المجمع وأُعيد تشكيله على مدى نحو ألفي عام؛ وتغطي قاعة الأعمدة الكبرى وحدها قرابة 5000 متر مربع، وتتجاوز أعمدتها الاثنا عشر الوسطى 20 مترًا ارتفاعًا.",
      'hl': [
        {'t': "قاعة الأعمدة الكبرى", 'd': "غابة من 134 عمودًا مغطاة بالنقوش الهيروغليفية، يتسلل الضوء بينها من النوافذ العالية للصحن الأوسط."},
        {'t': "مسلة حتشبسوت", 'd': "نُحتت من كتلة واحدة من الجرانيت ويقارب ارتفاعها 30 مترًا، وهي من أعلى المسلات القديمة التي لا تزال قائمة."},
        {'t': "البحيرة المقدسة", 'd': "كانت مخصصة لطقوس تطهّر الكهنة، ويشرف عليها جعران حجري ضخم يدور حوله الزوار طلبًا للحظ، وفق التقليد."},
      ],
    },
  },
  'karnak_open_air_museum': {
    'related': ['karnak_temple', 'luxor_temple', 'medinet_habu'],
    'fr': {
      'duration': "1 h",
      'best': "En fin de visite de Karnak, quand les groupes sont partis",
      'tip': "Vérifiez à la billetterie si un billet distinct de celui de Karnak est nécessaire, et gardez-lui un peu de temps : les détails se lisent mieux sans se presser.",
      'fact': "Les blocs de la chapelle blanche de Sésostris Ier avaient été réemployés comme remplissage dans un pylône voisin ; ils ont été retrouvés puis remontés au XXe siècle, comme un immense puzzle.",
      'hl': [
        {'t': "La chapelle blanche de Sésostris Ier", 'd': "Un petit sanctuaire en calcaire blanc, aux reliefs d'une finesse remarquable, considéré comme l'un des joyaux de l'art du Moyen Empire."},
        {'t': "La chapelle d'albâtre d'Amenhotep Ier", 'd': "Un édifice de calcite luisante, reconstitué avec soin, qui servait de reposoir à la barque sacrée."},
        {'t': "Les blocs d'Akhenaton", 'd': "Des milliers de petits blocs décorés, issus des monuments de l'époque amarnienne, permettent de lire un style artistique à part."},
      ],
    },
    'en': {
      'duration': "1 hour",
      'best': "At the end of your Karnak visit, once the tour groups have left",
      'tip': "Check at the ticket office whether a ticket separate from Karnak's is required, and give it some time: the details reward a slower pace.",
      'fact': "The blocks of Senusret I's White Chapel had been reused as filling in a neighbouring pylon; they were found and reassembled in the 20th century, like an immense puzzle.",
      'hl': [
        {'t': "Senusret I's White Chapel", 'd': "A small white limestone shrine with remarkably fine reliefs, regarded as one of the jewels of Middle Kingdom art."},
        {'t': "Amenhotep I's Alabaster Chapel", 'd': "A gleaming calcite building, carefully reconstructed, which served as a resting place for the sacred barque."},
        {'t': "The Akhenaten blocks", 'd': "Thousands of small decorated blocks from Amarna-period monuments reveal a strikingly different artistic style."},
      ],
    },
    'ar': {
      'duration': "ساعة",
      'best': "في نهاية زيارة الكرنك بعد انصراف المجموعات السياحية",
      'tip': "اسأل في شباك التذاكر إن كانت هناك تذكرة منفصلة عن الكرنك، وخصّص له بعض الوقت فتفاصيله تستحق التمهّل.",
      'fact': "أُعيد استخدام كتل المقصورة البيضاء لسنوسرت الأول كحشو داخل صرح مجاور، ثم عُثر عليها وأُعيد تركيبها في القرن العشرين كأنها أحجية ضخمة.",
      'hl': [
        {'t': "المقصورة البيضاء لسنوسرت الأول", 'd': "مزار صغير من الحجر الجيري الأبيض ذو نقوش بالغة الدقة، ويُعد من درر فن الدولة الوسطى."},
        {'t': "مقصورة الألباستر لأمنحتب الأول", 'd': "بناء من الكالسيت اللامع أُعيد تركيبه بعناية، وكان مخصصًا لاستراحة المركب المقدس."},
        {'t': "كتل إخناتون", 'd': "آلاف الكتل الصغيرة المزخرفة من آثار عصر العمارنة تكشف عن أسلوب فني مختلف تمامًا."},
      ],
    },
  },
  'luxor_temple': {
    'related': ['karnak_temple', 'nile_boat_ride', 'colossi_memnon'],
    'fr': {
      'duration': "1 h à 1 h 30",
      'best': "À la tombée de la nuit, lorsque le temple s'illumine",
      'tip': "Venez en fin d'après-midi : vous verrez la pierre dorée au soleil couchant, puis les projecteurs prendre le relais, sans avoir à revenir.",
      'fact': "L'obélisque jumeau de celui qui se dresse ici se trouve place de la Concorde, à Paris, où il a été érigé en 1836.",
      'hl': [
        {'t': "Les colosses de Ramsès II", 'd': "Assis ou debout devant le pylône, ils veillent sur l'entrée depuis plus de 3 000 ans."},
        {'t': "Une mosquée dans le temple", 'd': "La mosquée d'Abou el-Haggag, construite au sein même du temple, témoigne de siècles de continuité religieuse."},
        {'t': "L'allée des sphinx", 'd': "Longue d'environ 2,7 km, elle reliait autrefois le temple de Louxor à celui de Karnak lors des grandes processions."},
      ],
    },
    'en': {
      'duration': "1 to 1.5 hours",
      'best': "At nightfall, when the temple is lit up",
      'tip': "Come in the late afternoon: you'll see the stone glow gold at sunset, then the floodlights take over, without having to return.",
      'fact': "The twin of the obelisk standing here is in the Place de la Concorde in Paris, where it was erected in 1836.",
      'hl': [
        {'t': "The colossi of Ramesses II", 'd': "Seated and standing before the pylon, they have guarded the entrance for more than 3,000 years."},
        {'t': "A mosque inside the temple", 'd': "The Abu el-Haggag Mosque, built within the temple itself, bears witness to centuries of religious continuity."},
        {'t': "The Avenue of Sphinxes", 'd': "About 2.7 km long, it once linked Luxor Temple to Karnak for the great processions."},
      ],
    },
    'ar': {
      'duration': "من ساعة إلى ساعة ونصف",
      'best': "عند حلول الليل حين يُضاء المعبد",
      'tip': "تعال في أواخر العصر لترى الحجر ذهبيًا عند الغروب ثم تتولى الأضواء الكاشفة المشهد، دون الحاجة للعودة.",
      'fact': "توأم المسلة القائمة هنا يقف في ساحة الكونكورد بباريس حيث نُصب عام 1836.",
      'hl': [
        {'t': "تماثيل رمسيس الثاني", 'd': "جالسة وواقفة أمام الصرح، تحرس المدخل منذ أكثر من 3000 عام."},
        {'t': "مسجد داخل المعبد", 'd': "يشهد مسجد أبي الحجاج المبني داخل المعبد نفسه على قرون من الاستمرارية الدينية."},
        {'t': "طريق الكباش", 'd': "يبلغ طوله نحو 2.7 كم، وكان يربط معبد الأقصر بمعبد الكرنك في الاحتفالات الكبرى."},
      ],
    },
  },
  'royal_tomb': {
    'related': ['valley_kings_queens', 'deir_el_medina', 'hot_air_balloon'],
    'fr': {
      'duration': "30 à 45 min par tombe",
      'best': "Tôt le matin, avant la chaleur",
      'tip': "Le billet d'entrée donne généralement accès à trois tombes au choix ; quelques-unes, comme celle de Toutânkhamon, demandent un billet supplémentaire. Les règles sur les photos varient selon les tombes.",
      'fact': "Les parois reproduisent des textes funéraires, tels que le Livre des Portes ou l'Amdouat, véritables guides du voyage nocturne du roi dans l'au-delà.",
      'hl': [
        {'t': "Des textes sacrés", 'd': "Hiéroglyphes et scènes mythologiques recouvrent les couloirs, comme un mode d'emploi pour l'éternité."},
        {'t': "Des plafonds étoilés", 'd': "Dans plusieurs tombes, la voûte céleste est peinte au plafond de la chambre funéraire."},
        {'t': "Des couleurs préservées", 'd': "À l'abri de la lumière et de l'air pendant des millénaires, les pigments ont gardé un éclat saisissant."},
      ],
    },
    'en': {
      'duration': "30 to 45 minutes per tomb",
      'best': "Early morning, before the heat",
      'tip': "The entry ticket usually covers three tombs of your choice; a few, such as Tutankhamun's, require an extra ticket. Photo rules vary from tomb to tomb.",
      'fact': "The walls reproduce funerary texts, such as the Book of Gates or the Amduat, true guides to the king's nocturnal journey through the afterlife.",
      'hl': [
        {'t': "Sacred texts", 'd': "Hieroglyphs and mythological scenes cover the corridors, like an instruction manual for eternity."},
        {'t': "Starry ceilings", 'd': "In several tombs, the vault of the heavens is painted across the ceiling of the burial chamber."},
        {'t': "Preserved colours", 'd': "Sheltered from light and air for millennia, the pigments have kept a striking brilliance."},
      ],
    },
    'ar': {
      'duration': "من 30 إلى 45 دقيقة لكل مقبرة",
      'best': "في الصباح الباكر قبل اشتداد الحرارة",
      'tip': "تتيح تذكرة الدخول عادةً زيارة ثلاث مقابر من اختيارك، وبعضها مثل مقبرة توت عنخ آمون يتطلب تذكرة إضافية. وتختلف قواعد التصوير من مقبرة إلى أخرى.",
      'fact': "تحمل الجدران نصوصًا جنائزية مثل كتاب البوابات وكتاب إمي دوات، وهي أدلة حقيقية لرحلة الملك الليلية في العالم الآخر.",
      'hl': [
        {'t': "نصوص مقدسة", 'd': "تغطي الهيروغليفية والمشاهد الأسطورية الممرات كأنها دليل للخلود."},
        {'t': "أسقف مرصعة بالنجوم", 'd': "في عدة مقابر تُرسم قبة السماء على سقف حجرة الدفن."},
        {'t': "ألوان محفوظة", 'd': "بقيت الأصباغ زاهية بشكل لافت لأنها كانت بمنأى عن الضوء والهواء آلاف السنين."},
      ],
    },
  },
  'valley_kings_queens': {
    'related': ['royal_tomb', 'deir_el_medina', 'medinet_habu'],
    'fr': {
      'duration': "3 à 4 h",
      'best': "Dès l'ouverture, avant la chaleur",
      'tip': "Emportez de l'eau et un chapeau : il y a peu d'ombre. Une petite navette relie l'entrée aux tombes, et la vallée des Reines se visite à part.",
      'fact': "Howard Carter y a découvert en 1922 la tombe de Toutânkhamon, l'une des rares à avoir été retrouvée presque intacte. Le site fait partie de « Thèbes antique et sa nécropole », inscrite à l'UNESCO en 1979.",
      'hl': [
        {'t': "La tombe de Toutânkhamon", 'd': "Modeste par la taille, elle est célèbre pour avoir livré un trésor funéraire quasi intact."},
        {'t': "La vallée des Reines", 'd': "Épouses et enfants de pharaons y reposent, dont Néfertari, dont la tombe est réputée pour la beauté de ses peintures."},
        {'t': "Un paysage de désert et de falaises", 'd': "La pointe pyramidale de la montagne qui domine la vallée aurait inspiré le choix du lieu."},
      ],
    },
    'en': {
      'duration': "3 to 4 hours",
      'best': "First thing in the morning, before the heat",
      'tip': "Bring water and a hat: there is little shade. A small shuttle runs from the entrance to the tombs, and the Valley of the Queens is visited separately.",
      'fact': "Howard Carter discovered Tutankhamun's tomb here in 1922, one of the few found almost intact. The site is part of “Ancient Thebes with its Necropolis”, inscribed by UNESCO in 1979.",
      'hl': [
        {'t': "Tutankhamun's tomb", 'd': "Modest in size, it is famous for yielding an almost intact funerary treasure."},
        {'t': "The Valley of the Queens", 'd': "Pharaohs' wives and children rest here, including Nefertari, whose tomb is renowned for the beauty of its paintings."},
        {'t': "A landscape of desert and cliffs", 'd': "The pyramid-shaped peak overlooking the valley is said to have inspired the choice of this place."},
      ],
    },
    'ar': {
      'duration': "من 3 إلى 4 ساعات",
      'best': "في الصباح الباكر قبل اشتداد الحرارة",
      'tip': "خذ معك الماء وقبعة فالظل قليل. تنقلك حافلة صغيرة من المدخل إلى المقابر، وتُزار وادي الملكات بشكل منفصل.",
      'fact': "اكتشف هوارد كارتر هنا عام 1922 مقبرة توت عنخ آمون، إحدى المقابر القليلة التي عُثر عليها شبه سليمة. ويُعد الموقع جزءًا من «طيبة القديمة وجبانتها» المدرجة لدى اليونسكو عام 1979.",
      'hl': [
        {'t': "مقبرة توت عنخ آمون", 'd': "صغيرة الحجم لكنها شهيرة لأنها قدمت كنزًا جنائزيًا شبه كامل."},
        {'t': "وادي الملكات", 'd': "تضم زوجات الفراعنة وأبناءهم، ومنهم نفرتاري التي اشتهرت مقبرتها بجمال لوحاتها."},
        {'t': "مشهد من الصحراء والجروف", 'd': "يُقال إن القمة الهرمية التي تعلو الوادي كانت وراء اختيار هذا المكان."},
      ],
    },
  },
  'colossi_memnon': {
    'related': ['medinet_habu', 'valley_kings_queens', 'hot_air_balloon'],
    'fr': {
      'duration': "20 à 30 min",
      'best': "Au lever du soleil",
      'tip': "L'arrêt est bref et se fait souvent en route vers la vallée des Rois ; à l'aube, la lumière rasante sur le grès est superbe pour les photos.",
      'fact': "Chaque statue mesure environ 18 mètres. Après un séisme en 27 av. J.-C., la statue nord se serait mise à « chanter » à l'aube, jusqu'à sa restauration sous l'empereur romain Septime Sévère.",
      'hl': [
        {'t': "Deux géants de 18 mètres", 'd': "Taillés dans des blocs de grès, ils représentent Amenhotep III assis, le regard tourné vers le Nil."},
        {'t': "Le colosse qui chantait", 'd': "Dans l'Antiquité, voyageurs grecs et romains venaient l'entendre, et ont gravé leurs impressions sur ses jambes."},
        {'t': "Un temple disparu", 'd': "Le temple funéraire qu'ils gardaient était l'un des plus vastes d'Égypte ; il n'en reste que des vestiges, que des fouilles continuent de révéler."},
      ],
    },
    'en': {
      'duration': "20 to 30 minutes",
      'best': "At sunrise",
      'tip': "The stop is short and often made on the way to the Valley of the Kings; at dawn, the low light on the sandstone is superb for photos.",
      'fact': "Each statue stands about 18 metres tall. After an earthquake in 27 BC, the northern statue was said to “sing” at dawn, until it was restored under the Roman emperor Septimius Severus.",
      'hl': [
        {'t': "Two 18-metre giants", 'd': "Carved from blocks of sandstone, they depict the seated Amenhotep III, gazing toward the Nile."},
        {'t': "The singing colossus", 'd': "In antiquity, Greek and Roman travellers came to hear it, and carved their impressions on its legs."},
        {'t': "A vanished temple", 'd': "The mortuary temple they guarded was among the largest in Egypt; only remains survive, which excavations continue to reveal."},
      ],
    },
    'ar': {
      'duration': "من 20 إلى 30 دقيقة",
      'best': "عند شروق الشمس",
      'tip': "الوقفة قصيرة وغالبًا ما تكون في الطريق إلى وادي الملوك؛ وعند الفجر يكون الضوء المنخفض على الحجر الرملي رائعًا للتصوير.",
      'fact': "يبلغ ارتفاع كل تمثال نحو 18 مترًا. وبعد زلزال عام 27 ق.م قيل إن التمثال الشمالي كان «يغني» عند الفجر، حتى رمّمه الإمبراطور الروماني سبتيموس سيفيروس.",
      'hl': [
        {'t': "عملاقان بارتفاع 18 مترًا", 'd': "نُحتا من كتل الحجر الرملي ويصوّران أمنحتب الثالث جالسًا ناظرًا نحو النيل."},
        {'t': "التمثال الذي كان يغني", 'd': "في العصور القديمة كان المسافرون اليونانيون والرومان يأتون للاستماع إليه، ونقشوا انطباعاتهم على ساقيه."},
        {'t': "معبد اختفى", 'd': "كان المعبد الجنائزي الذي يحرسانه من أكبر معابد مصر، ولم يتبق منه سوى آثار لا تزال الحفائر تكشف عنها."},
      ],
    },
  },
  'medinet_habu': {
    'related': ['colossi_memnon', 'deir_el_medina', 'valley_kings_queens'],
    'fr': {
      'duration': "1 h 30 à 2 h",
      'best': "Fin d'après-midi, lorsque la lumière dore la pierre",
      'tip': "Bien moins fréquenté que Karnak : prenez le temps de lever les yeux vers les plafonds et les chapiteaux, où les couleurs d'origine subsistent.",
      'fact': "Construit pour Ramsès III il y a environ 3 200 ans, ce temple est l'un des mieux conservés de la rive ouest ; ses murs racontent la victoire sur les peuples de la mer.",
      'hl': [
        {'t': "La bataille contre les peuples de la mer", 'd': "Des reliefs d'un réalisme saisissant montrent navires, guerriers et prisonniers sur les murs extérieurs."},
        {'t': "Des couleurs encore vives", 'd': "Dans les cours et sous les portiques, la polychromie d'origine est restée remarquablement visible."},
        {'t': "La porte fortifiée", 'd': "L'entrée monumentale, inspirée des forteresses syro-palestiniennes, impressionne dès les premiers pas."},
      ],
    },
    'en': {
      'duration': "1.5 to 2 hours",
      'best': "Late afternoon, when the light gilds the stone",
      'tip': "Far less crowded than Karnak: take time to look up at the ceilings and capitals, where the original colours survive.",
      'fact': "Built for Ramesses III some 3,200 years ago, this temple is among the best preserved on the West Bank; its walls recount the victory over the Sea Peoples.",
      'hl': [
        {'t': "The battle against the Sea Peoples", 'd': "Strikingly realistic reliefs show ships, warriors and prisoners on the outer walls."},
        {'t': "Colours still vivid", 'd': "In the courtyards and beneath the porticoes, the original polychromy remains remarkably visible."},
        {'t': "The fortified gateway", 'd': "The monumental entrance, inspired by Syro-Palestinian fortresses, impresses from the very first steps."},
      ],
    },
    'ar': {
      'duration': "من ساعة ونصف إلى ساعتين",
      'best': "وقت العصر حين يضفي الضوء لونًا ذهبيًا على الحجر",
      'tip': "إنه أقل ازدحامًا بكثير من الكرنك، فخذ وقتك لتتأمل الأسقف والتيجان حيث لا تزال الألوان الأصلية باقية.",
      'fact': "شُيّد لرمسيس الثالث قبل نحو 3200 عام، وهو من أفضل معابد البر الغربي حفظًا، وتروي جدرانه الانتصار على شعوب البحر.",
      'hl': [
        {'t': "معركة شعوب البحر", 'd': "نقوش بالغة الواقعية تُظهر السفن والمحاربين والأسرى على الجدران الخارجية."},
        {'t': "ألوان لا تزال زاهية", 'd': "في الأفنية وتحت الأروقة بقيت الألوان الأصلية ظاهرة بشكل لافت."},
        {'t': "البوابة المحصنة", 'd': "يبهر المدخل الضخم المستوحى من الحصون السورية الفلسطينية منذ الخطوات الأولى."},
      ],
    },
  },
  'deir_el_medina': {
    'related': ['valley_kings_queens', 'royal_tomb', 'medinet_habu'],
    'fr': {
      'duration': "1 h 30",
      'best': "Le matin, quand le village est calme",
      'tip': "Prévoyez des chaussures fermées pour les ruelles de pierre ; l'accès à certaines tombes décorées se fait par un billet distinct.",
      'fact': "Vers 1155 av. J.-C., sous Ramsès III, les artisans du village ont cessé le travail faute de ration : c'est l'une des plus anciennes grèves connues de l'histoire.",
      'hl': [
        {'t': "Le village des artisans", 'd': "Plans de maisons, ruelles et ateliers permettent d'imaginer le quotidien de ceux qui décoraient les tombes royales."},
        {'t': "La tombe de Sennedjem", 'd': "Petite mais éblouissante, elle déploie des peintures aux couleurs éclatantes dans une chambre voûtée."},
        {'t': "Le temple d'Hathor", 'd': "Un sanctuaire d'époque ptolémaïque, dédié à Hathor et à Maât, veille sur le village."},
      ],
    },
    'en': {
      'duration': "1.5 hours",
      'best': "Morning, when the village is quiet",
      'tip': "Wear closed shoes for the stone lanes; access to some decorated tombs requires a separate ticket.",
      'fact': "Around 1155 BC, under Ramesses III, the village's craftsmen downed tools over unpaid rations: one of the earliest known strikes in history.",
      'hl': [
        {'t': "The artisans' village", 'd': "House plans, lanes and workshops let you imagine the daily life of those who decorated the royal tombs."},
        {'t': "The tomb of Sennedjem", 'd': "Small but dazzling, it displays brilliantly coloured paintings in a vaulted chamber."},
        {'t': "The Temple of Hathor", 'd': "A Ptolemaic-era sanctuary dedicated to Hathor and Maat watches over the village."},
      ],
    },
    'ar': {
      'duration': "ساعة ونصف",
      'best': "في الصباح حين تكون القرية هادئة",
      'tip': "ارتدِ حذاءً مغلقًا للأزقة الحجرية؛ ويتطلب دخول بعض المقابر المزخرفة تذكرة منفصلة.",
      'fact': "نحو عام 1155 ق.م، في عهد رمسيس الثالث، توقف حرفيو القرية عن العمل بسبب تأخر الحصص الغذائية، وهو من أقدم الإضرابات المعروفة في التاريخ.",
      'hl': [
        {'t': "قرية الحرفيين", 'd': "تتيح مخططات البيوت والأزقة والورش تخيّل الحياة اليومية لمن زيّنوا المقابر الملكية."},
        {'t': "مقبرة سنجم", 'd': "صغيرة لكنها مبهرة، تعرض لوحات بألوان زاهية داخل حجرة مقببة."},
        {'t': "معبد حتحور", 'd': "مزار من العصر البطلمي مكرّس لحتحور وماعت يطل على القرية."},
      ],
    },
  },
  'hot_air_balloon': {
    'related': ['nile_boat_ride', 'valley_kings_queens', 'colossi_memnon'],
    'fr': {
      'duration': "Environ 45 min de vol",
      'best': "Au lever du soleil",
      'tip': "Réservez à l'avance : les vols dépendent de la météo, surtout du vent. Prévoyez une petite veste, car il fait frais avant l'aube.",
      'fact': "Les ballons décollent de la rive ouest peu avant le lever du soleil, quand l'air est calme et stable : c'est ce qui permet de glisser doucement au-dessus des temples.",
      'hl': [
        {'t': "Le soleil sur la vallée du Nil", 'd': "La lumière naissante dore tour à tour le fleuve, les champs et les falaises thébaines."},
        {'t': "Les temples vus d'en haut", 'd': "Colosses, temples funéraires et nécropole se révèlent dans leur plan d'ensemble."},
        {'t': "Le contraste vert et désert", 'd': "Une frontière nette sépare les terres cultivées de l'immensité du désert."},
      ],
    },
    'en': {
      'duration': "About 45 minutes of flight",
      'best': "At sunrise",
      'tip': "Book in advance: flights depend on the weather, especially the wind. Bring a light jacket, as it is cool before dawn.",
      'fact': "The balloons lift off from the West Bank shortly before sunrise, when the air is calm and stable, which lets them drift gently over the temples.",
      'hl': [
        {'t': "Sunrise over the Nile valley", 'd': "The first light gilds the river, the fields and the Theban cliffs in turn."},
        {'t': "Temples from above", 'd': "Colossi, mortuary temples and the necropolis reveal themselves in their overall layout."},
        {'t': "The contrast of green and desert", 'd': "A sharp line separates the cultivated land from the immensity of the desert."},
      ],
    },
    'ar': {
      'duration': "نحو 45 دقيقة من التحليق",
      'best': "عند شروق الشمس",
      'tip': "احجز مسبقًا فالرحلات تعتمد على الطقس وخاصة الرياح. وخذ معك سترة خفيفة فالجو بارد قبل الفجر.",
      'fact': "تقلع المناطيد من البر الغربي قبيل شروق الشمس حين يكون الهواء هادئًا ومستقرًا، مما يتيح الانسياب بلطف فوق المعابد.",
      'hl': [
        {'t': "الشروق فوق وادي النيل", 'd': "يكسو الضوء الأول النهر والحقول وجروف طيبة بلون ذهبي تباعًا."},
        {'t': "المعابد من الأعلى", 'd': "تنكشف التماثيل والمعابد الجنائزية والجبانة في تخطيطها العام."},
        {'t': "تباين الأخضر والصحراء", 'd': "يفصل خط حاد بين الأراضي المزروعة واتساع الصحراء."},
      ],
    },
  },
  'nile_boat_ride': {
    'related': ['hot_air_balloon', 'luxor_temple', 'karnak_temple'],
    'fr': {
      'duration': "1 h (promenade en felouque)",
      'best': "Au coucher du soleil",
      'tip': "Convenez du prix et de la durée avant d'embarquer, et choisissez la fin de journée, quand la brise se lève et que la lumière s'adoucit.",
      'fact': "Les anciens Égyptiens plaçaient les nécropoles sur la rive ouest, là où le soleil se couche, et les villes des vivants sur la rive est, là où il se lève.",
      'hl': [
        {'t': "La felouque au crépuscule", 'd': "Ces voiliers traditionnels glissent presque en silence, au rythme du vent."},
        {'t': "Deux rives, deux mondes", 'd': "La ville animée sur la rive est, les champs et les falaises thébaines sur la rive ouest."},
        {'t': "L'île aux bananes", 'd': "Une escale prisée sur le fleuve, au milieu des cultures, pour une pause fraîcheur."},
      ],
    },
    'en': {
      'duration': "1 hour (felucca ride)",
      'best': "At sunset",
      'tip': "Agree on the price and duration before boarding, and go late in the day when the breeze rises and the light softens.",
      'fact': "The ancient Egyptians placed the necropolises on the west bank, where the sun sets, and the cities of the living on the east bank, where it rises.",
      'hl': [
        {'t': "A felucca at dusk", 'd': "These traditional sailboats glide almost silently, at the pace of the wind."},
        {'t': "Two banks, two worlds", 'd': "The lively city on the east bank, the fields and Theban cliffs on the west bank."},
        {'t': "Banana Island", 'd': "A popular stop on the river, among the crops, for a cool break."},
      ],
    },
    'ar': {
      'duration': "ساعة (جولة بالفلوكة)",
      'best': "عند غروب الشمس",
      'tip': "اتفق على السعر والمدة قبل الركوب، واختر آخر النهار حين يهبّ النسيم ويلين الضوء.",
      'fact': "وضع المصريون القدماء الجبانات على الضفة الغربية حيث تغرب الشمس، ومدن الأحياء على الضفة الشرقية حيث تشرق.",
      'hl': [
        {'t': "فلوكة عند الغسق", 'd': "تنساب هذه المراكب الشراعية التقليدية بصمت تقريبًا على إيقاع الريح."},
        {'t': "ضفتان وعالمان", 'd': "المدينة النابضة على الضفة الشرقية، والحقول وجروف طيبة على الضفة الغربية."},
        {'t': "جزيرة الموز", 'd': "محطة محببة على النهر وسط المزروعات لاستراحة منعشة."},
      ],
    },
  },
};