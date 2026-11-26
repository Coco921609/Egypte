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

/// Convertit un instant UTC en heure locale d'Assouan (fields = heure locale).
DateTime _toAswan(DateTime utc) =>
    utc.add(Duration(hours: _egyptDst(utc) ? 3 : 2));

String _two(int v) => v.toString().padLeft(2, '0');

String _hm(DateTime utc) {
  final DateTime c = _toAswan(utc);
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

/// Lever et coucher du soleil à Assouan pour une date (algorithme solaire
/// simplifié, précision de quelques minutes).
_SunDay _sunDay(DateTime cairoDate) {
  const double latDeg = 24.0889;
  const double lonDeg = 32.8998;
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
  final DateTime cairo = _toAswan(nowUtc);
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
          Text('24.09°N · 32.90°E',
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
          _KenBurns(child: const _PlaceImage('assets/images/assouan.jpg')),
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
                          child: Text('24.09°N · 32.90°E',
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
class AssouanPage extends StatefulWidget {
  const AssouanPage({super.key});

  @override
  State<AssouanPage> createState() => _AssouanPageState();
}

class _AssouanPageState extends State<AssouanPage> {
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
      'pageTitle': 'Assouan',
      'tagline': 'La perle du Nil aux portes de la Nubie',
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
      'catMonuments': 'Monuments majeurs',
      'catMarkets': 'Marchés traditionnels',
      'catHistory': 'Histoire et Culture',
      'catArch': 'Architecture',
      'catRelaxation': 'Lieux de détente',
      'catActivities': 'Activités',
      'phaseDawn': 'Aube',
      'phaseDay': 'Journée',
      'phaseDusk': 'Heure dorée',
      'phaseNight': 'Nuit',
      'cairoTime': 'Il est {t} à Assouan',
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
      'totalTime': 'Temps à Assouan',
      'hUnit': 'h',
      'mUnit': 'min',
      'btnStamp': 'Tamponner',
      'btnStampDone': 'Tamponné',
      'btnTimer': 'Minuteur',
      'btnMaps': 'Itinéraire',
      'catNature': 'Nature et Paysages',
    },
    'en': {
      'pageTitle': 'Aswan',
      'tagline': 'The pearl of the Nile at the gates of Nubia',
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
      'catMonuments': 'Major Monuments',
      'catMarkets': 'Traditional Markets',
      'catHistory': 'History & Culture',
      'catArch': 'Architecture',
      'catRelaxation': 'Relaxation Spots',
      'catActivities': 'Activities',
      'phaseDawn': 'Dawn',
      'phaseDay': 'Daylight',
      'phaseDusk': 'Golden hour',
      'phaseNight': 'Night',
      'cairoTime': 'It is {t} in Aswan',
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
      'totalTime': 'Time in Aswan',
      'hUnit': 'h',
      'mUnit': 'min',
      'btnStamp': 'Stamp',
      'btnStampDone': 'Stamped',
      'btnTimer': 'Timer',
      'btnMaps': 'Directions',
      'catNature': 'Nature & Landscapes',
    },
    'ar': {
      'pageTitle': 'أسوان',
      'tagline': 'لؤلؤة النيل عند أبواب النوبة',
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
      'catMonuments': 'المعالم الرئيسية',
      'catMarkets': 'الأسواق التقليدية',
      'catHistory': 'التاريخ وثقافة',
      'catArch': 'العمارة',
      'catRelaxation': 'أماكن الاسترخاء',
      'catActivities': 'الأنشطة',
      'phaseDawn': 'الفجر',
      'phaseDay': 'نهار',
      'phaseDusk': 'الساعة الذهبية',
      'phaseNight': 'الليل',
      'cairoTime': 'الساعة {t} في أسوان',
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
      'totalTime': 'الوقت في أسوان',
      'hUnit': 'س',
      'mUnit': 'د',
      'btnStamp': 'ختم',
      'btnStampDone': 'تم الختم',
      'btnTimer': 'مؤقت',
      'btnMaps': 'الاتجاهات',
      'catNature': 'الطبيعة والمناظر الطبيعية',
    },
  };

  // --- DONNÉES TRADUITES PAR LANGUE ---
  static const Map<String, List<Map<String, dynamic>>> _localizedAssouanData = {
    'fr': [
      {
        "id": "abou_simbel",
        "name": "Abou Simbel",
        "sub_category_key": "catMonuments",
        "sub_category": "Monuments majeurs",
        "photo_url": "assets/assouan/s.jpg",
        "description": "Situé aux confins du désert, cet ensemble de deux temples creusés dans la roche par Ramsès II est un chef-d'œuvre de l'architecture mondiale. Le déplacement titanesque de ces temples pour les sauver des eaux du barrage est une aventure humaine et technique sans précédent.",
        "mapsQuery": "Abou Simbel"
      },
      {
        "id": "temple_philae",
        "name": "Temple de Philae",
        "sub_category_key": "catMonuments",
        "sub_category": "Monuments majeurs",
        "photo_url": "assets/assouan/phi.webp",
        "description": "Dédié à la déesse Isis, ce temple est un joyau d'élégance situé sur l'île d'Agilkia. Ses colonnades, ses reliefs délicats et sa position au milieu des eaux du Nil en font l'un des lieux les plus poétiques et les mieux conservés de toute la Basse-Nubie.",
        "mapsQuery": "Temple de Philae Assouan"
      },
      {
        "id": "temple_horus",
        "name": "Temple d'Horus",
        "sub_category_key": "catMonuments",
        "sub_category": "Monuments majeurs",
        "photo_url": "assets/assouan/h.jpg",
        "description": "Érigé à Edfou entre Assouan et Louxor, ce temple est l'un des mieux préservés d'Égypte. Dédié au dieu faucon Horus, il se distingue par sa structure complète, ses pylônes imposants et son atmosphère solennelle qui transporte le visiteur directement au cœur de l'époque ptolémaïque.",
        "mapsQuery": "Temple d'Horus Edfou"
      },
      {
        "id": "lac_nasser",
        "name": "Lac Nasser (lac de Nubie)",
        "sub_category_key": "catNature",
        "sub_category": "Nature et Paysages",
        "photo_url": "assets/assouan/nasser.jpg",
        "description": "L'un des plus grands lacs artificiels au monde, créé par la construction du haut barrage. Ses eaux d'un bleu profond contrastent magnifiquement avec l'aridité du désert environnant.",
        "mapsQuery": "Lac Nasser Assouan"
      },
      {
        "id": "monastere_saint_simeon",
        "name": "Le monastère de Saint-Siméon",
        "sub_category_key": "catHistory",
        "sub_category": "Histoire et Culture",
        "photo_url": "assets/assouan/saint.jpeg",
        "description": "Situé sur la rive ouest du Nil, ce monastère fortifié du VIIe siècle est l'un des exemples les mieux conservés de l'architecture copte en Égypte. Isolé dans le paysage désertique, il témoigne de la vie ascétique des moines avec ses impressionnantes murailles en briques crues, ses églises aux fresques anciennes et ses cellules monastiques qui dominent la vallée.",
        "mapsQuery": "Monastère de Saint-Siméon Assouan"
      },
      {
        "id": "ile_elephantine",
        "name": "L’île Éléphantine",
        "sub_category_key": "catHistory",
        "sub_category": "Histoire et Culture",
        "photo_url": "assets/assouan/ile.jpg",
        "description": "Véritable carrefour historique, cette île abrite le temple de Khnoum et un nilomètre antique. Entre ses jardins luxuriants et les maisons traditionnelles du village nubien qui s'y trouve, elle offre une immersion totale dans la vie quotidienne assouanaise.",
        "mapsQuery": "Île Éléphantine Assouan"
      },
      {
        "id": "village_nubien",
        "name": "Le village nubien",
        "sub_category_key": "catHistory",
        "sub_category": "Histoire et Culture",
        "photo_url": "assets/assouan/village.jpeg",
        "description": "Découvrez le mode de vie des Nubiens à travers leurs maisons colorées, leur artisanat raffiné et leur hospitalité. Une escale incontournable pour comprendre l'identité singulière de cette culture.",
        "mapsQuery": "Nubian Village Aswan"
      },
      {
        "id": "jardin_botanique_kitchener",
        "name": "Le jardin botanique de l’île Kitchener",
        "sub_category_key": "catNature",
        "sub_category": "Nature et Paysages",
        "photo_url": "assets/assouan/parc.jpeg",
        "description": "Un paradis verdoyant au milieu du fleuve, rassemblant des espèces exotiques rares issues de tous les continents. C'est l'endroit rêvé pour une pause ombragée.",
        "mapsQuery": "Aswan Botanical Garden Kitchener Island"
      },
      {
        "id": "balade_felouque",
        "name": "Balade en felouque",
        "sub_category_key": "catActivities",
        "sub_category": "Activités",
        "photo_url": "assets/assouan/balade.jpg",
        "description": "Glisser sur le Nil en felouque, sans le bruit d'un moteur, est une expérience sensorielle unique. Le moyen le plus authentique pour explorer les îlots déserts et les paysages fascinants de la Nubie.",
        "mapsQuery": "Felucca ride Aswan"
      },
      {
        "id": "temple_kom_ombo",
        "name": "Temple de Kôm Ombo",
        "sub_category_key": "catMonuments",
        "sub_category": "Monuments majeurs",
        "photo_url": "assets/assouan/ombo.jpeg",
        "description": "Situé sur un promontoire surplombant le Nil, ce temple est une rareté architecturale. Sa conception parfaitement symétrique lui permet d'être dédié simultanément à deux divinités : Sobek, le dieu crocodile, et Haroëris, le dieu faucon. C'est un lieu fascinant pour comprendre la dualité dans la religion égyptienne antique.",
        "mapsQuery": "Temple de Kom Ombo"
      },
    ],
    'en': [
      {
        "id": "abou_simbel",
        "name": "Abu Simbel",
        "sub_category_key": "catMonuments",
        "sub_category": "Major Monuments",
        "photo_url": "assets/assouan/s.jpg",
        "description": "Located at the edge of the desert, this complex of two temples carved into the rock by Ramesses II is a masterpiece of world architecture. The colossal relocation of these temples to save them from dam waters remains an unprecedented human and engineering feat.",
        "mapsQuery": "Abu Simbel"
      },
      {
        "id": "temple_philae",
        "name": "Philae Temple",
        "sub_category_key": "catMonuments",
        "sub_category": "Major Monuments",
        "photo_url": "assets/assouan/phi.webp",
        "description": "Dedicated to the goddess Isis, this elegant temple is located on Agilkia Island. Its colonnades, delicate reliefs, and setting amidst the waters of the Nile make it one of the most poetic and best-preserved sites in Lower Nubia.",
        "mapsQuery": "Philae Temple Aswan"
      },
      {
        "id": "temple_horus",
        "name": "Temple of Horus",
        "sub_category_key": "catMonuments",
        "sub_category": "Major Monuments",
        "photo_url": "assets/assouan/h.jpg",
        "description": "Erected in Edfu between Aswan and Luxor, this temple is one of the best-preserved in Egypt. Dedicated to the falcon god Horus, it stands out for its intact structure, imposing pylons, and solemn atmosphere that transports visitors to the Ptolemaic era.",
        "mapsQuery": "Temple of Horus Edfu"
      },
      {
        "id": "lac_nasser",
        "name": "Lake Nasser (Lake Nubia)",
        "sub_category_key": "catNature",
        "sub_category": "Nature & Landscapes",
        "photo_url": "assets/assouan/nasser.jpg",
        "description": "One of the largest man-made lakes in the world, created by the construction of the High Dam. Its deep blue waters contrast strikingly with the surrounding arid desert.",
        "mapsQuery": "Lake Nasser Aswan"
      },
      {
        "id": "monastere_saint_simeon",
        "name": "Monastery of Saint Simeon",
        "sub_category_key": "catHistory",
        "sub_category": "History & Culture",
        "photo_url": "assets/assouan/saint.jpeg",
        "description": "Located on the west bank of the Nile, this 7th-century fortified monastery is one of the best-preserved examples of Coptic architecture in Egypt. Isolated in the desert landscape, it reflects monastic life with mud-brick walls, ancient frescoes, and cells overlooking the valley.",
        "mapsQuery": "Monastery of Saint Simeon Aswan"
      },
      {
        "id": "ile_elephantine",
        "name": "Elephantine Island",
        "sub_category_key": "catHistory",
        "sub_category": "History & Culture",
        "photo_url": "assets/assouan/ile.jpg",
        "description": "A true historical crossroads, this island houses the Temple of Khnum and an ancient nilometer. Between lush gardens and traditional Nubian village houses, it offers total immersion in local life.",
        "mapsQuery": "Elephantine Island Aswan"
      },
      {
        "id": "village_nubien",
        "name": "Nubian Village",
        "sub_category_key": "catHistory",
        "sub_category": "History & Culture",
        "photo_url": "assets/assouan/village.jpeg",
        "description": "Discover the Nubian lifestyle through colorful houses, refined handicrafts, and legendary hospitality. An essential stop to understand the unique identity of this culture.",
        "mapsQuery": "Nubian Village Aswan"
      },
      {
        "id": "jardin_botanique_kitchener",
        "name": "Aswan Botanical Garden (Kitchener's Island)",
        "sub_category_key": "catNature",
        "sub_category": "Nature & Landscapes",
        "photo_url": "assets/assouan/parc.jpeg",
        "description": "A lush green paradise in the middle of the river, housing rare exotic plant species from all continents. The perfect place for a shaded retreat.",
        "mapsQuery": "Aswan Botanical Garden Kitchener Island"
      },
      {
        "id": "balade_felouque",
        "name": "Felucca Ride",
        "sub_category_key": "catActivities",
        "sub_category": "Activities",
        "photo_url": "assets/assouan/balade.jpg",
        "description": "Gliding down the Nile on a traditional felucca without engine noise is a unique sensory experience. The most authentic way to explore deserted islets and Nubia's captivating landscapes.",
        "mapsQuery": "Felucca ride Aswan"
      },
      {
        "id": "temple_kom_ombo",
        "name": "Kom Ombo Temple",
        "sub_category_key": "catMonuments",
        "sub_category": "Major Monuments",
        "photo_url": "assets/assouan/ombo.jpeg",
        "description": "Situated on a high promontory overlooking the Nile, this temple is an architectural rarity. Its perfectly symmetrical design is dedicated simultaneously to two deities: Sobek the crocodile god and Haroeris the falcon god.",
        "mapsQuery": "Temple of Kom Ombo"
      },
    ],
    'ar': [
      {
        "id": "abou_simbel",
        "name": "أبو سمبل",
        "sub_category_key": "catMonuments",
        "sub_category": "المعالم الرئيسية",
        "photo_url": "assets/assouan/s.jpg",
        "description": "يقع هذا المجمع المكون من معبدين منحوتين في الصخر بواسطة رمسيس الثاني على أطراف الصحراء، ويُعد تحفة معمارية عالمية. تُعتبر عملية نقل المعبدين المذهلة لإنقاذهما من مياه السد إنجازاً بشرياً وهندسياً فريداً.",
        "mapsQuery": "أبو سمبل"
      },
      {
        "id": "temple_philae",
        "name": "معبد فيلة",
        "sub_category_key": "catMonuments",
        "sub_category": "المعالم الرئيسية",
        "photo_url": "assets/assouan/phi.webp",
        "description": "مكرس للإلهة إيزيس، ويُعد هذا المعبد جوهرة أنيقة تقع على جزيرة أجيلكيا. أعمدته ونقوشه الدقيقة وموقعه وسط مياه النيل تجعله واحداً من أكثر الأماكن شاعرية وأفضلها حفظاً في النوبة.",
        "mapsQuery": "معبد فيلة أسوان"
      },
      {
        "id": "temple_horus",
        "name": "معبد حورس (إدفو)",
        "sub_category_key": "catMonuments",
        "sub_category": "المعالم الرئيسية",
        "photo_url": "assets/assouan/h.jpg",
        "description": "يقع في إدفو بين أسوان والأقصر، ويُعتبر من أفضل المعابد حفظاً في مصر. مكرس للإله الصقر حورس، ويتميز ببنائه الكامل وبواباته الضخمة وأجوائه التي تنقل الزائر إلى عصر البطالمة.",
        "mapsQuery": "معبد حورس إدفو"
      },
      {
        "id": "lac_nasser",
        "name": "بحيرة ناصر",
        "sub_category_key": "catNature",
        "sub_category": "الطبيعة والمناظر الطبيعية",
        "photo_url": "assets/assouan/nasser.jpg",
        "description": "واحدة من أكبر البحيرات الصناعية في العالم، أنشئت نتيجة بناء السد العالي. تتناغم مياهها الزرقاء الداكنة بشكل رائع مع جفاف الصحراء المحيطة بها.",
        "mapsQuery": "بحيرة ناصر أسوان"
      },
      {
        "id": "monastere_saint_simeon",
        "name": "دير الأنبا سمعان",
        "sub_category_key": "catHistory",
        "sub_category": "التاريخ وثقافة",
        "photo_url": "assets/assouan/saint.jpeg",
        "description": "يقع على الضفة الغربية للنيل، وهو دير حصين يعود للقرن السابع الميلادي ويعد من أروع أمثلة العمارة القبطية في مصر. يقع وسط الصحراء ويشهد على الحياة الرهبانية بأسواره الضخمة وكنائسه القديمة.",
        "mapsQuery": "دير الأنبا سمعان أسوان"
      },
      {
        "id": "ile_elephantine",
        "name": "جزيرة الفنتين",
        "sub_category_key": "catHistory",
        "sub_category": "التاريخ وثقافة",
        "photo_url": "assets/assouan/ile.jpg",
        "description": "ملتقى تاريخي حقيقي، تضم الجزيرة معبد خنوم ومقياس النيل القديم. وتوفر بين حدائقها الغناء وبيوت القرى النوبية التقليدية تجربة انغماس كاملة في الحياة اليومية.",
        "mapsQuery": "جزيرة الفنتين أسوان"
      },
      {
        "id": "village_nubien",
        "name": "القرية النوبية",
        "sub_category_key": "catHistory",
        "sub_category": "التاريخ وثقافة",
        "photo_url": "assets/assouan/village.jpeg",
        "description": "اكتشف نمط حياة النوبيين من خلال بيوتهم الملونة وحرفهم اليدوية الرفيعة وحسن ضيافتهم. محطة لا غنى عنها لفهم الهوية الفريدة لهذه الثقافة.",
        "mapsQuery": "القرية النوبية أسوان"
      },
      {
        "id": "jardin_botanique_kitchener",
        "name": "الحديقة النباتية (جزيرة النباتات)",
        "sub_category_key": "catNature",
        "sub_category": "الطبيعة والمناظر الطبيعية",
        "photo_url": "assets/assouan/parc.jpeg",
        "description": "واحة خضراء وسط النيل تضم أنواعاً من النباتات والأشجار النادرة من مختلف القارات. مكان مثالي للاسترخاء والتنزه.",
        "mapsQuery": "الحديقة النباتية أسوان"
      },
      {
        "id": "balade_felouque",
        "name": "جولة بالفلوكة",
        "sub_category_key": "catActivities",
        "sub_category": "الأنشطة",
        "photo_url": "assets/assouan/balade.jpg",
        "description": "الإبحار في هدوء عبر نهر النيل على متن فلوكة تقليدية بدون ضوضاء المحركات هي تجربة فريدة. الوسيلة الأكثر أصالة لاستكشاف جزر النوبة ومناظرها الطبيعية.",
        "mapsQuery": "جولة فلوكة أسوان"
      },
      {
        "id": "temple_kom_ombo",
        "name": "معبد كوم أمبو",
        "sub_category_key": "catMonuments",
        "sub_category": "المعالم الرئيسية",
        "photo_url": "assets/assouan/ombo.jpeg",
        "description": "يقع على ربوة عالية تطل على النيل، ويُعد من أندر المعالم المعمارية. تصميمه المتناظر مخصص لإلهين في وقت واحد: سوبك إله التمساح وحورور إله الصقر.",
        "mapsQuery": "معبد كوم أمبو"
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
      _localizedAssouanData[_lang] ?? _localizedAssouanData['fr']!;

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
                item['mapsQuery'] as String? ?? '${item['name']} Assouan'),
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
  'abou_simbel': {
    'related': ['lac_nasser', 'temple_philae', 'temple_kom_ombo'],
    'fr': {
      'duration': "1 h 30 sur place (environ 3 h de route depuis Assouan)",
      'best': "Dès l'ouverture, tôt le matin",
      'tip': "Partez très tôt d'Assouan pour arriver à l'ouverture : vous profiterez de la fraîcheur et de la lumière du matin sur la façade, qui regarde vers l'est.",
      'fact': "Entre 1964 et 1968, les deux temples ont été découpés en plus d'un millier de blocs et remontés une soixantaine de mètres plus haut, à l'abri des eaux du lac Nasser, grâce à une campagne internationale de l'UNESCO.",
      'hl': [
        {'t': "Les quatre colosses de Ramsès II", 'd': "Hauts d'une vingtaine de mètres, ils veillent sur la façade du grand temple et sur le fleuve depuis plus de 3 200 ans."},
        {'t': "Le temple de Néfertari", 'd': "Dédié à la déesse Hathor, ce petit temple voisin met à l'honneur la reine, représentée à la même échelle que le roi, un honneur rare."},
        {'t': "Le miracle du soleil", 'd': "Deux fois par an, à la fin février et à la fin octobre, les rayons du soleil levant traversent le temple jusqu'au sanctuaire du fond."},
      ],
    },
    'en': {
      'duration': "1.5 hours on site (about 3 hours' drive from Aswan)",
      'best': "First thing in the morning",
      'tip': "Leave Aswan very early to arrive at opening time: you will enjoy the cool air and the morning light on the east-facing façade.",
      'fact': "Between 1964 and 1968, both temples were cut into more than a thousand blocks and rebuilt some sixty metres higher, safe from the waters of Lake Nasser, thanks to an international UNESCO campaign.",
      'hl': [
        {'t': "The four colossi of Ramesses II", 'd': "About twenty metres tall, they have watched over the great temple's façade and the river for more than 3,200 years."},
        {'t': "Nefertari's temple", 'd': "Dedicated to the goddess Hathor, this smaller neighbouring temple honours the queen, shown at the same scale as the king, a rare distinction."},
        {'t': "The solar miracle", 'd': "Twice a year, in late February and late October, the rising sun's rays travel through the temple to the innermost sanctuary."},
      ],
    },
    'ar': {
      'duration': "ساعة ونصف في الموقع (نحو 3 ساعات بالسيارة من أسوان)",
      'best': "في الصباح الباكر عند الافتتاح",
      'tip': "انطلق مبكرًا جدًا من أسوان لتصل عند الافتتاح وتستمتع بالأجواء المنعشة وضوء الصباح على الواجهة المطلة على الشرق.",
      'fact': "بين عامي 1964 و1968 قُطع المعبدان إلى أكثر من ألف كتلة وأُعيد تركيبهما على ارتفاع نحو ستين مترًا بعيدًا عن مياه بحيرة ناصر، بفضل حملة دولية أطلقتها اليونسكو.",
      'hl': [
        {'t': "تماثيل رمسيس الثاني الأربعة", 'd': "يبلغ ارتفاع كل منها نحو عشرين مترًا، وتحرس واجهة المعبد الكبير والنهر منذ أكثر من 3200 عام."},
        {'t': "معبد نفرتاري", 'd': "مكرّس للإلهة حتحور، ويكرّم هذا المعبد الصغير المجاور الملكة، ويصوّرها بحجم الملك نفسه، وهو شرف نادر."},
        {'t': "معجزة الشمس", 'd': "مرتين في السنة، في أواخر فبراير وأواخر أكتوبر، تخترق أشعة الشمس المعبد حتى المقصورة الداخلية."},
      ],
    },
  },
  'temple_philae': {
    'related': ['abou_simbel', 'ile_elephantine', 'balade_felouque'],
    'fr': {
      'duration': "1 h 30 à 2 h",
      'best': "Fin d'après-midi, quand la lumière s'adoucit",
      'tip': "On y accède en bateau depuis l'embarcadère, pour une courte traversée. Un spectacle son et lumière y est proposé le soir : vérifiez les horaires sur place.",
      'fact': "Pour échapper à la montée des eaux, le temple a été démonté puis remonté sur l'île d'Agilkia dans les années 1970. On y trouve la dernière inscription hiéroglyphique connue, datée de 394 apr. J.-C.",
      'hl': [
        {'t': "Le temple d'Isis", 'd': "Son pylône monumental ouvre sur des cours et des salles où se célébrait l'un des cultes les plus durables de l'Égypte antique."},
        {'t': "Le kiosque de Trajan", 'd': "Cet élégant pavillon à colonnes, au bord de l'eau, est devenu l'image emblématique de l'île."},
        {'t': "La porte d'Hadrien", 'd': "Ornée de reliefs bien conservés, elle porte la dernière inscription hiéroglyphique connue."},
      ],
    },
    'en': {
      'duration': "1.5 to 2 hours",
      'best': "Late afternoon, as the light softens",
      'tip': "You reach it by boat from the landing stage, a short crossing. A sound and light show is offered in the evening: check the times on site.",
      'fact': "To escape the rising waters, the temple was dismantled and rebuilt on Agilkia Island in the 1970s. It holds the last known hieroglyphic inscription, dated 394 AD.",
      'hl': [
        {'t': "The Temple of Isis", 'd': "Its monumental pylon opens onto courts and halls where one of ancient Egypt's longest-lasting cults was celebrated."},
        {'t': "Trajan's Kiosk", 'd': "This elegant columned pavilion by the water has become the island's emblematic image."},
        {'t': "Hadrian's Gate", 'd': "Decorated with well-preserved reliefs, it bears the last known hieroglyphic inscription."},
      ],
    },
    'ar': {
      'duration': "من ساعة ونصف إلى ساعتين",
      'best': "وقت العصر حين يلين الضوء",
      'tip': "يُوصل إليه بالقارب من المرسى في عبور قصير. ويُقدَّم في المساء عرض الصوت والضوء، فتحقق من المواعيد في الموقع.",
      'fact': "لتفادي ارتفاع المياه فُكك المعبد وأُعيد تركيبه على جزيرة أجيلكيا في السبعينيات. وفيه آخر نقش هيروغليفي معروف يعود إلى عام 394 ميلادية.",
      'hl': [
        {'t': "معبد إيزيس", 'd': "يفتح صرحه الضخم على أفنية وقاعات كانت تُقام فيها شعائر من أطول العبادات عمرًا في مصر القديمة."},
        {'t': "كشك تراجان", 'd': "هذا الجناح الأنيق ذو الأعمدة على حافة الماء صار الصورة الرمزية للجزيرة."},
        {'t': "بوابة هادريان", 'd': "تزينها نقوش جيدة الحفظ، وتحمل آخر نقش هيروغليفي معروف."},
      ],
    },
  },
  'temple_horus': {
    'related': ['temple_kom_ombo', 'temple_philae', 'balade_felouque'],
    'fr': {
      'duration': "1 h 30",
      'best': "Le matin, avant l'arrivée des groupes",
      'tip': "Edfou se trouve à environ 110 km d'Assouan : le temple se visite souvent en une étape sur la route de Louxor ou pendant une croisière sur le Nil.",
      'fact': "Édifié entre 237 et 57 av. J.-C., c'est le deuxième plus grand temple d'Égypte après Karnak. Ensablé pendant des siècles, il a été dégagé au XIXe siècle par l'égyptologue Auguste Mariette.",
      'hl': [
        {'t': "Le pylône monumental", 'd': "Haut d'environ 36 mètres, il donne le ton dès l'entrée et ouvre sur une vaste cour à colonnes."},
        {'t': "Le faucon de granit", 'd': "Une grande statue d'Horus en granit noir veille sur la cour, devant le pylône du sanctuaire."},
        {'t': "Les murs gravés", 'd': "Des reliefs couvrent presque chaque paroi et racontent, entre autres, le combat mythique d'Horus contre Seth."},
      ],
    },
    'en': {
      'duration': "1.5 hours",
      'best': "Morning, before the tour groups arrive",
      'tip': "Edfu lies about 110 km from Aswan: the temple is often visited as a single stop on the road to Luxor or during a Nile cruise.",
      'fact': "Built between 237 and 57 BC, it is the second largest temple in Egypt after Karnak. Buried in sand for centuries, it was cleared in the 19th century by the Egyptologist Auguste Mariette.",
      'hl': [
        {'t': "The monumental pylon", 'd': "About 36 metres high, it sets the tone from the entrance and opens onto a vast columned courtyard."},
        {'t': "The granite falcon", 'd': "A great statue of Horus in black granite watches over the court, in front of the sanctuary pylon."},
        {'t': "The carved walls", 'd': "Reliefs cover almost every surface and recount, among other tales, Horus's mythical battle against Seth."},
      ],
    },
    'ar': {
      'duration': "ساعة ونصف",
      'best': "في الصباح قبل وصول المجموعات السياحية",
      'tip': "تبعد إدفو نحو 110 كم عن أسوان، وغالبًا ما يُزار المعبد كمحطة واحدة في الطريق إلى الأقصر أو أثناء رحلة نيلية.",
      'fact': "شُيّد بين عامي 237 و57 ق.م، وهو ثاني أكبر معبد في مصر بعد الكرنك. وبعد قرون من الدفن تحت الرمال كشفه في القرن التاسع عشر عالم المصريات أوغست مارييت.",
      'hl': [
        {'t': "الصرح الضخم", 'd': "يبلغ ارتفاعه نحو 36 مترًا، ويضبط الإيقاع منذ المدخل ويفتح على فناء واسع ذي أعمدة."},
        {'t': "صقر الجرانيت", 'd': "تمثال كبير لحورس من الجرانيت الأسود يحرس الفناء أمام صرح المقصورة."},
        {'t': "الجدران المنقوشة", 'd': "تغطي النقوش كل جدار تقريبًا وتروي، من بين ما تروي، المعركة الأسطورية بين حورس وست."},
      ],
    },
  },
  'lac_nasser': {
    'related': ['abou_simbel', 'balade_felouque', 'temple_philae'],
    'fr': {
      'duration': "Une journée, ou plusieurs jours en croisière",
      'best': "En hiver, quand les températures sont douces",
      'tip': "Les rives sont presque désertes : emportez de l'eau, un chapeau et une bonne protection solaire, surtout si vous restez longtemps sur l'eau.",
      'fact': "Né de la construction du haut barrage d'Assouan, achevé en 1970, le lac s'étire sur environ 550 km, dont une partie au Soudan, où on l'appelle le lac de Nubie.",
      'hl': [
        {'t': "Un lac au cœur du désert", 'd': "Un bleu profond bordé de sable et de roche : un contraste saisissant, surtout à l'aube."},
        {'t': "Les temples de Nubie sauvés", 'd': "Plusieurs sanctuaires, déplacés lors de la montée des eaux, jalonnent désormais ses rives."},
        {'t': "Une faune discrète", 'd': "Oiseaux d'eau et crocodiles du Nil peuplent les criques les plus tranquilles."},
      ],
    },
    'en': {
      'duration': "A day, or several days on a cruise",
      'best': "In winter, when temperatures are mild",
      'tip': "The shores are almost deserted: bring water, a hat and good sun protection, especially if you spend long hours on the water.",
      'fact': "Created by the construction of the Aswan High Dam, completed in 1970, the lake stretches about 550 km, partly in Sudan, where it is known as Lake Nubia.",
      'hl': [
        {'t': "A lake in the heart of the desert", 'd': "Deep blue fringed with sand and rock: a striking contrast, especially at dawn."},
        {'t': "The rescued temples of Nubia", 'd': "Several sanctuaries, relocated as the waters rose, now dot its shores."},
        {'t': "Discreet wildlife", 'd': "Waterbirds and Nile crocodiles inhabit the quietest coves."},
      ],
    },
    'ar': {
      'duration': "يوم واحد، أو عدة أيام في رحلة نيلية",
      'best': "في الشتاء حين تكون الحرارة معتدلة",
      'tip': "الشواطئ شبه خالية، فخذ معك الماء وقبعة وواقيًا جيدًا من الشمس، خاصة إن قضيت ساعات طويلة على الماء.",
      'fact': "نشأت البحيرة بعد بناء السد العالي الذي اكتمل عام 1970، وتمتد نحو 550 كم، يقع جزء منها في السودان حيث تُعرف ببحيرة النوبة.",
      'hl': [
        {'t': "بحيرة في قلب الصحراء", 'd': "زرقة عميقة تحيط بها الرمال والصخور، وتباين لافت خاصة عند الفجر."},
        {'t': "معابد النوبة المنقذة", 'd': "تنتشر على شواطئها عدة مزارات نُقلت حين ارتفعت المياه."},
        {'t': "حياة برية هادئة", 'd': "تعيش الطيور المائية وتماسيح النيل في الخلجان الأكثر هدوءًا."},
      ],
    },
  },
  'monastere_saint_simeon': {
    'related': ['ile_elephantine', 'village_nubien', 'balade_felouque'],
    'fr': {
      'duration': "1 h 30",
      'best': "Le matin, avant la chaleur",
      'tip': "Après la traversée du Nil, on rejoint le monastère à pied ou à dos de chameau dans le sable : portez de bonnes chaussures et emportez de l'eau et un chapeau.",
      'fact': "Dédié à l'origine à Anba Hadra, évêque d'Assouan, le monastère pouvait accueillir jusqu'à 300 moines et dominait un important chemin de pèlerinage.",
      'hl': [
        {'t': "Des murailles de briques crues", 'd': "Ses fortifications massives, mêlant pierre et brique, protégeaient les moines dans un environnement hostile."},
        {'t': "L'église et ses fresques", 'd': "Des peintures anciennes subsistent dans l'église, témoins de la vie spirituelle copte."},
        {'t': "Cellules et vue sur le désert", 'd': "Les cellules, le réfectoire et les terrasses dominent la vallée et les dunes."},
      ],
    },
    'en': {
      'duration': "1.5 hours",
      'best': "Morning, before the heat",
      'tip': "After crossing the Nile, you reach the monastery on foot or by camel across the sand: wear good shoes and bring water and a hat.",
      'fact': "Originally dedicated to Anba Hadra, bishop of Aswan, the monastery could house up to 300 monks and overlooked an important pilgrimage route.",
      'hl': [
        {'t': "Mud-brick walls", 'd': "Its massive fortifications, combining stone and brick, protected the monks in a harsh environment."},
        {'t': "The church and its frescoes", 'd': "Ancient paintings survive in the church, a testament to Coptic spiritual life."},
        {'t': "Cells and desert views", 'd': "The cells, refectory and terraces overlook the valley and the dunes."},
      ],
    },
    'ar': {
      'duration': "ساعة ونصف",
      'best': "في الصباح قبل اشتداد الحرارة",
      'tip': "بعد عبور النيل تصل إلى الدير سيرًا على الأقدام أو على ظهر جمل عبر الرمال، فارتدِ حذاءً جيدًا وخذ الماء وقبعة.",
      'fact': "كان الدير مكرسًا في الأصل للأنبا هدرة أسقف أسوان، وكان يتسع لنحو 300 راهب ويشرف على طريق مهم للحجاج.",
      'hl': [
        {'t': "أسوار من الطوب اللبن", 'd': "كانت تحصيناته الضخمة، التي تجمع بين الحجر والطوب، تحمي الرهبان في بيئة قاسية."},
        {'t': "الكنيسة وجدارياتها", 'd': "تبقى في الكنيسة لوحات قديمة تشهد على الحياة الروحية القبطية."},
        {'t': "الصوامع وإطلالة الصحراء", 'd': "تطل الصوامع وقاعة الطعام والشرفات على الوادي والكثبان."},
      ],
    },
  },
  'ile_elephantine': {
    'related': ['village_nubien', 'jardin_botanique_kitchener', 'balade_felouque'],
    'fr': {
      'duration': "2 h",
      'best': "Le matin, quand l'île est calme",
      'tip': "On y accède en bateau depuis la corniche. Profitez-en pour visiter le musée d'Assouan, installé sur l'île, et pour flâner entre les ruelles des villages.",
      'fact': "Située à la frontière sud de l'Égypte antique, l'île était un poste de commerce et de garnison. Son nilomètre servait à mesurer la crue du Nil, dont dépendaient les récoltes et les impôts.",
      'hl': [
        {'t': "Le nilomètre", 'd': "Un escalier gradué descend jusqu'au fleuve et permettait de lire le niveau de la crue."},
        {'t': "Le temple de Khnoum", 'd': "Les vestiges honorent le dieu bélier, réputé gardien des sources du Nil."},
        {'t': "Les villages nubiens", 'd': "Maisons colorées, jardins et ruelles de sable composent un cadre paisible."},
      ],
    },
    'en': {
      'duration': "2 hours",
      'best': "Morning, when the island is quiet",
      'tip': "You reach it by boat from the Corniche. While there, visit the Aswan Museum, set on the island, and wander the lanes of the villages.",
      'fact': "Located on the southern frontier of ancient Egypt, the island was a trading and garrison post. Its nilometer measured the Nile flood, on which harvests and taxes depended.",
      'hl': [
        {'t': "The nilometer", 'd': "A graduated stairway descends to the river and allowed the flood level to be read."},
        {'t': "The Temple of Khnum", 'd': "The remains honour the ram-headed god, said to be the guardian of the Nile's sources."},
        {'t': "The Nubian villages", 'd': "Colourful houses, gardens and sandy lanes make a peaceful setting."},
      ],
    },
    'ar': {
      'duration': "ساعتان",
      'best': "في الصباح حين تكون الجزيرة هادئة",
      'tip': "تصل إليها بالقارب من الكورنيش. وانتهز الفرصة لزيارة متحف أسوان الواقع على الجزيرة والتجول بين أزقة القرى.",
      'fact': "كانت الجزيرة، الواقعة على الحدود الجنوبية لمصر القديمة، مركزًا للتجارة والحامية. وكان مقياس النيل فيها يقيس مستوى الفيضان الذي تعتمد عليه المحاصيل والضرائب.",
      'hl': [
        {'t': "مقياس النيل", 'd': "درج مدرّج ينزل إلى النهر كان يتيح قراءة مستوى الفيضان."},
        {'t': "معبد خنوم", 'd': "تكرّم آثاره الإله ذا رأس الكبش الذي يُعتقد أنه حارس منابع النيل."},
        {'t': "القرى النوبية", 'd': "بيوت ملونة وحدائق وأزقة رملية تصنع أجواء هادئة."},
      ],
    },
  },
  'village_nubien': {
    'related': ['ile_elephantine', 'balade_felouque', 'jardin_botanique_kitchener'],
    'fr': {
      'duration': "1 h 30 à 2 h",
      'best': "En fin d'après-midi, à la lumière dorée",
      'tip': "Prévoyez de la petite monnaie pour l'artisanat et demandez toujours l'accord des habitants avant de les photographier. Un thé ou un repas nubien se partage volontiers.",
      'fact': "De nombreux villages nubiens ont été engloutis ou déplacés lors de la création du lac Nasser, dans les années 1960 : la culture nubienne vit aujourd'hui entre mémoire et renouveau.",
      'hl': [
        {'t': "Des façades colorées", 'd': "Les murs peints de couleurs vives et de motifs font la signature visuelle des maisons nubiennes."},
        {'t': "Un artisanat raffiné", 'd': "Bijoux, paniers tressés et tissages se rapportent à des savoir-faire transmis de génération en génération."},
        {'t': "L'hospitalité nubienne", 'd': "Une tasse de thé ou de karkadé offerte avec le sourire fait partie de l'accueil."},
      ],
    },
    'en': {
      'duration': "1.5 to 2 hours",
      'best': "Late afternoon, in the golden light",
      'tip': "Bring small change for handicrafts, and always ask residents' permission before photographing them. A Nubian tea or meal is gladly shared.",
      'fact': "Many Nubian villages were submerged or relocated when Lake Nasser was created in the 1960s: Nubian culture today lives between memory and renewal.",
      'hl': [
        {'t': "Colourful façades", 'd': "Walls painted in bright colours and patterns are the visual signature of Nubian houses."},
        {'t': "Refined handicrafts", 'd': "Jewellery, woven baskets and textiles reflect skills passed down through generations."},
        {'t': "Nubian hospitality", 'd': "A cup of tea or hibiscus offered with a smile is part of the welcome."},
      ],
    },
    'ar': {
      'duration': "من ساعة ونصف إلى ساعتين",
      'best': "في أواخر العصر عند الضوء الذهبي",
      'tip': "احمل فئات نقدية صغيرة لشراء الحرف اليدوية، واطلب دائمًا إذن السكان قبل تصويرهم. ويُسعد النوبيون بمشاركة الشاي أو وجبة.",
      'fact': "غُمرت قرى نوبية كثيرة أو نُقلت عند إنشاء بحيرة ناصر في الستينيات، وتعيش الثقافة النوبية اليوم بين الذاكرة والتجدد.",
      'hl': [
        {'t': "واجهات ملونة", 'd': "الجدران المطلية بألوان زاهية وزخارف هي البصمة البصرية للبيوت النوبية."},
        {'t': "حرف يدوية رفيعة", 'd': "تعكس المجوهرات والسلال المضفورة والمنسوجات مهارات تنتقل من جيل إلى جيل."},
        {'t': "كرم الضيافة النوبية", 'd': "كوب شاي أو كركديه يُقدَّم بابتسامة جزء من الاستقبال."},
      ],
    },
  },
  'jardin_botanique_kitchener': {
    'related': ['balade_felouque', 'ile_elephantine', 'village_nubien'],
    'fr': {
      'duration': "1 h à 2 h",
      'best': "En fin d'après-midi, quand l'ombre est douce",
      'tip': "L'île se rejoint en felouque ou en bateau : combinez-la avec une balade sur le fleuve et emportez de l'eau.",
      'fact': "L'île a été offerte au général Kitchener à la fin du XIXe siècle. Passionné de botanique, il y a fait planter des espèces venues d'Inde, d'Afrique et d'ailleurs.",
      'hl': [
        {'t': "Des palmiers majestueux", 'd': "Des allées bordées de palmiers royaux offrent une ombre bienvenue."},
        {'t': "Un tour du monde végétal", 'd': "Arbres et fleurs exotiques, venus de plusieurs continents, s'y épanouissent."},
        {'t': "Une vue sur le fleuve", 'd': "Les berges ouvrent sur le Nil, les felouques et la rive ouest."},
      ],
    },
    'en': {
      'duration': "1 to 2 hours",
      'best': "Late afternoon, when the shade is gentle",
      'tip': "The island is reached by felucca or boat: combine it with a ride on the river and bring water.",
      'fact': "The island was given to General Kitchener in the late 19th century. A keen botanist, he had species planted there from India, Africa and beyond.",
      'hl': [
        {'t': "Majestic palms", 'd': "Avenues lined with royal palms offer welcome shade."},
        {'t': "A botanical world tour", 'd': "Exotic trees and flowers from several continents flourish here."},
        {'t': "A view of the river", 'd': "The banks open onto the Nile, the feluccas and the west bank."},
      ],
    },
    'ar': {
      'duration': "من ساعة إلى ساعتين",
      'best': "في أواخر العصر حين يلين الظل",
      'tip': "تُقصد الجزيرة بالفلوكة أو القارب، فادمجها مع جولة في النهر وخذ معك الماء.",
      'fact': "أُهديت الجزيرة إلى الجنرال كتشنر في أواخر القرن التاسع عشر، وكان شغوفًا بعلم النبات فزرع فيها أنواعًا من الهند وإفريقيا وغيرهما.",
      'hl': [
        {'t': "نخيل مهيب", 'd': "تمنح الممرات المحاطة بالنخيل الملكي ظلًا مرحبًا به."},
        {'t': "جولة نباتية حول العالم", 'd': "تزدهر هنا أشجار وأزهار غريبة من عدة قارات."},
        {'t': "إطلالة على النهر", 'd': "تطل الضفاف على النيل والفلايك والضفة الغربية."},
      ],
    },
  },
  'balade_felouque': {
    'related': ['jardin_botanique_kitchener', 'ile_elephantine', 'village_nubien'],
    'fr': {
      'duration': "1 h à 2 h",
      'best': "Au coucher du soleil",
      'tip': "Négociez le prix du bateau (et non par personne) ainsi que la durée et les escales avant d'embarquer. Le soir, la brise rend la balade très agréable.",
      'fact': "Assouan se trouve sur la première cataracte du Nil : des rochers de granit émergent du fleuve et forment de petits îlots, que la felouque contourne en silence.",
      'hl': [
        {'t': "Rochers et îlots de granit", 'd': "Le Nil serpente entre des blocs polis par le courant, dans un paysage unique en Égypte."},
        {'t': "Éléphantine et Kitchener", 'd': "La balade passe devant les deux îles, entre palmiers, jardins et maisons nubiennes."},
        {'t': "Le crépuscule sur le fleuve", 'd': "Le ciel s'embrase sur les dunes de la rive ouest, au rythme du vent dans la voile."},
      ],
    },
    'en': {
      'duration': "1 to 2 hours",
      'best': "At sunset",
      'tip': "Negotiate the price per boat (not per person), as well as the duration and stops, before boarding. In the evening, the breeze makes the ride very pleasant.",
      'fact': "Aswan sits on the Nile's First Cataract: granite rocks emerge from the river and form small islets, which the felucca silently weaves around.",
      'hl': [
        {'t': "Granite rocks and islets", 'd': "The Nile winds between blocks polished by the current, in a landscape unique in Egypt."},
        {'t': "Elephantine and Kitchener", 'd': "The ride passes both islands, among palms, gardens and Nubian houses."},
        {'t': "Dusk on the river", 'd': "The sky ignites over the west bank dunes, to the rhythm of the wind in the sail."},
      ],
    },
    'ar': {
      'duration': "من ساعة إلى ساعتين",
      'best': "عند غروب الشمس",
      'tip': "اتفق على سعر القارب (وليس للفرد) وعلى المدة والمحطات قبل الركوب. وفي المساء يجعل النسيم الجولة ممتعة جدًا.",
      'fact': "تقع أسوان عند الشلال الأول للنيل، حيث تبرز صخور الجرانيت من النهر وتشكل جزرًا صغيرة تلتف حولها الفلوكة بصمت.",
      'hl': [
        {'t': "صخور وجزر من الجرانيت", 'd': "يتعرج النيل بين كتل صقلها التيار، في مشهد فريد في مصر."},
        {'t': "الفنتين وجزيرة النباتات", 'd': "تمر الجولة بالجزيرتين بين النخيل والحدائق والبيوت النوبية."},
        {'t': "الغسق على النهر", 'd': "تلتهب السماء فوق كثبان الضفة الغربية على إيقاع الريح في الشراع."},
      ],
    },
  },
  'temple_kom_ombo': {
    'related': ['temple_horus', 'temple_philae', 'balade_felouque'],
    'fr': {
      'duration': "1 h",
      'best': "Au coucher du soleil, quand la pierre se dore",
      'tip': "Le petit musée des crocodiles momifiés, tout proche du temple, vaut le détour. Le site s'illumine en soirée.",
      'fact': "Construit à l'époque ptolémaïque, le temple possède une double entrée, deux sanctuaires et deux cours. Un relief célèbre y représente des instruments chirurgicaux de l'Antiquité.",
      'hl': [
        {'t': "Deux sanctuaires jumeaux", 'd': "L'aile gauche honore Haroëris, le dieu faucon, et l'aile droite Sobek, le dieu crocodile."},
        {'t': "Le musée des crocodiles", 'd': "Des momies de crocodiles, animaux sacrés de Sobek, y sont exposées."},
        {'t': "Un relief médical", 'd': "Scalpels, pinces et autres instruments gravés dans la pierre évoquent la médecine antique."},
      ],
    },
    'en': {
      'duration': "1 hour",
      'best': "At sunset, when the stone turns golden",
      'tip': "The small museum of mummified crocodiles, right next to the temple, is worth a visit. The site is lit up in the evening.",
      'fact': "Built in the Ptolemaic period, the temple has a double entrance, two sanctuaries and two courts. A famous relief shows surgical instruments of antiquity.",
      'hl': [
        {'t': "Twin sanctuaries", 'd': "The left wing honours Haroeris, the falcon god, and the right wing Sobek, the crocodile god."},
        {'t': "The crocodile museum", 'd': "Mummified crocodiles, sacred animals of Sobek, are on display there."},
        {'t': "A medical relief", 'd': "Scalpels, forceps and other instruments carved in stone evoke ancient medicine."},
      ],
    },
    'ar': {
      'duration': "ساعة",
      'best': "عند الغروب حين يتحول الحجر إلى لون ذهبي",
      'tip': "يستحق متحف التماسيح المحنطة الصغير القريب من المعبد الزيارة. ويُضاء الموقع في المساء.",
      'fact': "شُيّد المعبد في العصر البطلمي وله مدخلان وقدسان وفناءان. ويصوّر نقش شهير فيه أدوات جراحية من العصور القديمة.",
      'hl': [
        {'t': "مقصورتان توأمان", 'd': "يكرّم الجناح الأيسر حورور إله الصقر، والجناح الأيمن سوبك إله التمساح."},
        {'t': "متحف التماسيح", 'd': "تُعرض فيه مومياوات التماسيح، الحيوانات المقدسة لسوبك."},
        {'t': "نقش طبي", 'd': "مشارط وملاقط وأدوات أخرى منقوشة في الحجر تستحضر الطب القديم."},
      ],
    },
  },
};