import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Palette commune à toutes les pages.
class EgyptPalette {
  static const Color bg = Color(0xFF07080E);
  static const Color card = Color(0xFF11131C);
  static const Color sand = Color(0xFFF6EFE0);
  static const Color muted = Color(0xFFB9BFCC);
  static const Color teal = Color(0xFF0F766E);
  static const Color violet = Color(0xFF4C1D95);
  static const Color terracotta = Color(0xFF9A3412);
  static const Color rose = Color(0xFF9F1239);
}

// ==========================================
// FOND FLUIDE
// ==========================================

/// Fond animé : halos colorés qui dérivent lentement.
/// Si [image] est fourni, il apparaît en arrière-plan très flouté.
class EgyptAurora extends StatefulWidget {
  final List<Color> colors;
  final String? image;

  const EgyptAurora({super.key, required this.colors, this.image});

  @override
  State<EgyptAurora> createState() => _EgyptAuroraState();
}

class _EgyptAuroraState extends State<EgyptAurora> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 24))..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(color: EgyptPalette.bg),
            if (widget.image != null)
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 1600),
                child: ImageFiltered(
                  key: ValueKey(widget.image),
                  imageFilter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
                  child: Image.asset(
                    widget.image!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
              ),
            if (widget.image != null)
              DecoratedBox(decoration: BoxDecoration(color: EgyptPalette.bg.withOpacity(0.7))),
            AnimatedBuilder(
              animation: _ctrl,
              builder: (context, _) => CustomPaint(
                painter: _AuroraPainter(_ctrl.value, widget.colors),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuroraPainter extends CustomPainter {
  final double t;
  final List<Color> colors;
  const _AuroraPainter(this.t, this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double a = t * 2 * math.pi;

    final centers = <Offset>[
      Offset(w * (0.18 + 0.14 * _sin(a)), h * (0.12 + 0.07 * _cos(a))),
      Offset(w * (0.88 + 0.10 * _cos(a * 0.7)), h * (0.32 + 0.09 * _sin(a * 0.8))),
      Offset(w * (0.30 + 0.16 * _sin(a * 0.5 + 1.1)), h * (0.62 + 0.08 * _cos(a * 1.1))),
      Offset(w * (0.85 + 0.09 * _sin(a * 1.3)), h * (0.92 + 0.05 * _cos(a * 0.6))),
    ];
    final radii = <double>[w * 0.85, w * 0.75, w * 0.8, w * 0.7];

    for (var k = 0; k < centers.length; k++) {
      final Color c = colors[k % colors.length];
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [c.withOpacity(0.42), c.withOpacity(0.0)],
        ).createShader(Rect.fromCircle(center: centers[k], radius: radii[k]));
      canvas.drawRect(Offset.zero & size, paint);
    }
  }

  double _sin(double x) => math.sin(x);
  double _cos(double x) => math.cos(x);

  @override
  bool shouldRepaint(covariant _AuroraPainter old) => old.t != t || old.colors != colors;
}

// ==========================================
// VERRE DÉPOLI
// ==========================================

class EgyptGlass extends StatelessWidget {
  final Widget child;
  final double radius;
  final EdgeInsetsGeometry padding;
  final Color? tint;

  const EgyptGlass({
    super.key,
    required this.child,
    this.radius = 24,
    this.padding = const EdgeInsets.all(16),
    this.tint,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            color: tint ?? Colors.white.withOpacity(0.07),
            border: Border.all(color: Colors.white.withOpacity(0.13)),
          ),
          child: child,
        ),
      ),
    );
  }
}

// ==========================================
// INTERACTIONS
// ==========================================

/// Léger rétrécissement au toucher.
class EgyptPressable extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const EgyptPressable({super.key, required this.child, required this.onTap});

  @override
  State<EgyptPressable> createState() => _EgyptPressableState();
}

class _EgyptPressableState extends State<EgyptPressable> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) => setState(() => _down = false),
      onTapCancel: () => setState(() => _down = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? 0.97 : 1,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}

/// Apparition fluide : fondu + glissement vertical.
class EgyptReveal extends StatelessWidget {
  final Widget child;
  final int delay;

  const EgyptReveal({super.key, required this.child, this.delay = 0});

  @override
  Widget build(BuildContext context) {
    final int total = 900 + delay;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: total),
      curve: Interval(delay / total, 1, curve: Curves.easeOutCubic),
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(offset: Offset(0, 26 * (1 - t)), child: child),
      ),
      child: child,
    );
  }
}

// ==========================================
// COMPOSANTS
// ==========================================

/// Titre de section : index, filet dégradé, titre complet qui passe à la ligne.
class EgyptSectionLabel extends StatelessWidget {
  final String index;
  final String title;
  final Color accent;

  const EgyptSectionLabel({
    super.key,
    required this.index,
    required this.title,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 8, 22, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                index,
                style: GoogleFonts.montserrat(color: accent, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 2),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [accent.withOpacity(0.6), accent.withOpacity(0)]),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: GoogleFonts.playfairDisplay(
              color: EgyptPalette.sand,
              fontSize: 30,
              height: 1.15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Bouton retour en verre.
class EgyptBackButton extends StatelessWidget {
  final bool isRtl;
  final VoidCallback onTap;

  const EgyptBackButton({super.key, required this.isRtl, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: EgyptGlass(
        radius: 24,
        padding: const EdgeInsets.all(13),
        child: Icon(
          isRtl ? Icons.arrow_forward_ios_rounded : Icons.arrow_back_ios_new_rounded,
          color: EgyptPalette.sand,
          size: 16,
        ),
      ),
    );
  }
}

/// Sélecteur de langue FR / EN / AR en verre.
class EgyptLangSwitch extends StatelessWidget {
  final String current;
  final Color accent;
  final ValueChanged<String> onChanged;

  const EgyptLangSwitch({
    super.key,
    required this.current,
    required this.accent,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return EgyptGlass(
      radius: 26,
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final code in const ['fr', 'en', 'ar']) _item(code),
        ],
      ),
    );
  }

  Widget _item(String code) {
    final bool selected = current == code;
    final Color onAccent = accent.computeLuminance() > 0.45 ? EgyptPalette.bg : Colors.white;
    return GestureDetector(
      onTap: () => onChanged(code),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? accent : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Text(
          code.toUpperCase(),
          style: GoogleFonts.montserrat(
            color: selected ? onAccent : EgyptPalette.sand.withOpacity(0.8),
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }
}