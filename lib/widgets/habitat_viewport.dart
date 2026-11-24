import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../models/habitat.dart';
import '../models/species.dart';
import '../theme/app_theme.dart';

/// The visual centerpiece of a habitat.
///
/// Keep this widget deliberately self-contained: the game state supplies the
/// population/species/level, while this widget is responsible only for
/// rendering and lightweight presentation animation.
class HabitatViewport extends StatefulWidget {
  final Habitat habitat;
  final VoidCallback onTap;

  const HabitatViewport({
    super.key,
    required this.habitat,
    required this.onTap,
  });

  @override
  State<HabitatViewport> createState() => _HabitatViewportState();
}

class _AnimalVisual {
  double x;
  double y;
  double targetX;
  double targetY;
  double speed;
  double timer;
  String activity;
  bool left;
  double jump;
  double velocity;

  _AnimalVisual({
    required this.x,
    required this.y,
    required this.speed,
    required this.timer,
  })  : targetX = x,
        targetY = y,
        activity = 'resting',
        left = false,
        jump = 0,
        velocity = 0;
}

class _CareParticle {
  final Offset position;
  final String text;
  final Color color;
  final double born;

  const _CareParticle({
    required this.position,
    required this.text,
    required this.color,
    required this.born,
  });
}

class _HabitatViewportState extends State<HabitatViewport>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final Random _random = Random();
  final List<_AnimalVisual> _animals = <_AnimalVisual>[];
  final List<_CareParticle> _particles = <_CareParticle>[];
  final ValueNotifier<double> _clock = ValueNotifier<double>(0);
  Duration _lastElapsed = Duration.zero;
  bool _showHint = true;

  @override
  void initState() {
    super.initState();
    _syncAnimals(widget.habitat.population);
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void didUpdateWidget(covariant HabitatViewport oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.habitat.population != widget.habitat.population ||
        oldWidget.habitat.speciesId != widget.habitat.speciesId) {
      _syncAnimals(widget.habitat.population);
    }
  }

  void _syncAnimals(int population) {
    // Show enough animals to make the habitat feel populated without creating
    // dozens of independent Flutter widgets on every frame.
    final visible = min(12, max(1, population));
    while (_animals.length < visible) {
      _animals.add(
        _AnimalVisual(
          x: 0.22 + _random.nextDouble() * 0.56,
          y: 0.30 + _random.nextDouble() * 0.42,
          speed: 0.025 + _random.nextDouble() * 0.035,
          timer: 1.5 + _random.nextDouble() * 3,
        ),
      );
    }
    while (_animals.length > visible) {
      _animals.removeLast();
    }
  }

  void _onTick(Duration elapsed) {
    if (!mounted) return;
    // Derive delta from the ticker so animation speed follows real elapsed
    // time on 60Hz, 90Hz and 120Hz displays. Clamp after app resumes.
    final dt = ((elapsed - _lastElapsed).inMicroseconds / 1e6)
        .clamp(0.0, 0.05);
    _lastElapsed = elapsed;
    _clock.value += dt;
    _advanceAnimals(dt);
  }

  void _advanceAnimals(double dt) {
    for (final animal in _animals) {
      animal.timer -= dt;

      if (animal.timer <= 0) {
        final activities = <String>['roaming', 'feeding', 'drinking', 'resting'];
        animal.activity = activities[_random.nextInt(activities.length)];
        animal.timer = 2 + _random.nextDouble() * 3;

        switch (animal.activity) {
          case 'feeding':
            animal.targetX = 0.62 + _random.nextDouble() * 0.10;
            animal.targetY = 0.44 + _random.nextDouble() * 0.10;
            break;
          case 'drinking':
            animal.targetX = 0.28 + _random.nextDouble() * 0.08;
            animal.targetY = 0.48 + _random.nextDouble() * 0.08;
            break;
          case 'resting':
            animal.targetX = animal.x;
            animal.targetY = animal.y;
            break;
          default:
            animal.targetX = 0.20 + _random.nextDouble() * 0.60;
            animal.targetY = 0.28 + _random.nextDouble() * 0.44;
        }
      }

      if (animal.activity != 'resting') {
        final dx = animal.targetX - animal.x;
        final dy = animal.targetY - animal.y;
        final distance = sqrt(dx * dx + dy * dy);
        if (distance > 0.005) {
          final step = min(distance, animal.speed * dt);
          animal.x += dx / distance * step;
          animal.y += dy / distance * step;
          animal.left = dx < 0;
        }
      }

      if (animal.velocity != 0 || animal.jump < 0) {
        animal.velocity += 500 * dt;
        animal.jump += animal.velocity * dt;
        if (animal.jump >= 0) {
          animal.jump = 0;
          animal.velocity = 0;
        }
      }
    }

    _particles.removeWhere((p) => _clock.value - p.born > 1.15);
  }

  void _handleTap(Offset position) {
    widget.onTap();
    if (_showHint) {
      setState(() => _showHint = false);
    }

    for (final animal in _animals) {
      animal.velocity = -115 - _random.nextDouble() * 70;
      animal.jump = -1;
      if (animal.activity == 'resting') {
        animal.activity = 'roaming';
        animal.timer = 2;
      }
    }

    const texts = <String>['+1 🪙', '+0.5 🧬', '❤️', '✨', '🐾'];
    const colors = <Color>[
      Color(0xFFFBBF24),
      Color(0xFF38BDF8),
      Color(0xFFF43F5E),
      Color(0xFFA78BFA),
      Color(0xFF34D399),
    ];
    final i = _random.nextInt(texts.length);
    _particles.add(
      _CareParticle(
        position: position,
        text: texts[i],
        color: colors[i],
        born: _clock.value,
      ),
    );
  }

  @override
  void dispose() {
    _ticker.dispose();
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final species = Species.fromId(widget.habitat.speciesId);
    final habitat = widget.habitat;

    return Semantics(
      button: true,
      label: '${habitat.name}: ${habitat.population} ${species.name} in the '
          '${_biomeLabel(habitat.biomeType)}. Activate to care for the animals.',
      onTap: () {
        final size = context.size;
        _handleTap(
          size == null ? Offset.zero : size.center(Offset.zero),
        );
      },
      child: ExcludeSemantics(
        child: RepaintBoundary(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (details) => _handleTap(details.localPosition),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.sheet),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: _backgroundGradient(habitat.biomeType),
                ),
                child: ValueListenableBuilder<double>(
                  valueListenable: _clock,
                  builder: (context, time, _) {
                    return Stack(
                      fit: StackFit.expand,
                      children: <Widget>[
                        // Explicit child sizing prevents a painter-only
                        // CustomPaint from collapsing on a device.
                        CustomPaint(
                          painter: _HabitatPainter(
                            biome: habitat.biomeType,
                            level: habitat.level,
                            time: time,
                            autoWater: habitat.hasAutoWater,
                            autoFeeder: habitat.hasAutoFeeder,
                          ),
                          child: const SizedBox.expand(),
                        ),
                        ..._buildAnimals(species),
                        ..._buildParticles(time),
                        if (_showHint)
                          Positioned(
                            left: 14,
                            bottom: 12,
                            child: _hint(),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _biomeLabel(String biome) {
    switch (biome) {
      case 'australian_forest':
        return 'Australian forest';
      case 'northern_coast':
        return 'northern coast';
      case 'african_grasslands':
        return 'African grasslands';
      case 'ice_age_tundra':
        return 'ice age tundra';
      default:
        return 'tropical island';
    }
  }

  List<Widget> _buildAnimals(Species species) {
    return _animals.map((animal) {
      return Align(
        alignment: Alignment(
          (animal.x * 2) - 1,
          (animal.y * 2) - 1,
        ),
        child: Transform.translate(
          offset: Offset(animal.left ? -2 : 2, animal.jump),
          child: Transform.scale(
            // Slight perspective: animals lower in the scene read as closer.
            scale: (0.88 + animal.y * 0.26) *
                (animal.jump < -2 ? 1.08 : 1),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  _activityIcon(animal.activity),
                  style: const TextStyle(fontSize: 8),
                ),
                Transform.scale(
                  scaleX: animal.left ? -1.0 : 1.0,
                  child: Text(
                    species.iconEmoji,
                    style: TextStyle(
                      fontSize: 28,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.35),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  List<Widget> _buildParticles(double time) {
    return _particles.map((particle) {
      final progress = ((time - particle.born) / 1.15).clamp(0.0, 1.0);
      return Positioned(
        left: particle.position.dx - 18,
        top: particle.position.dy - 18 - progress * 42,
        child: Opacity(
          opacity: 1 - progress,
          child: Text(
            particle.text,
            style: TextStyle(
              color: particle.color,
              fontSize: 15,
              fontWeight: FontWeight.w900,
              shadows: const <Shadow>[
                Shadow(color: Colors.black, blurRadius: 4),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _hint() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.48),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: Colors.white12),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Text(
          '✨ Tap to care  (+🪙 +🧬)',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  String _activityIcon(String activity) {
    switch (activity) {
      case 'feeding':
        return '🍎';
      case 'drinking':
        return '💧';
      case 'resting':
        return '💤';
      default:
        return '🐾';
    }
  }

  Gradient _backgroundGradient(String biome) {
    switch (biome) {
      case 'australian_forest':
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[Color(0xFF315B3A), Color(0xFF0D2113)],
        );
      case 'northern_coast':
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[Color(0xFF1D5275), Color(0xFF071725)],
        );
      case 'african_grasslands':
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[Color(0xFF9A6A27), Color(0xFF30200B)],
        );
      case 'ice_age_tundra':
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[Color(0xFF5F91B1), Color(0xFF132B3A)],
        );
      default:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[Color(0xFF287A93), Color(0xFF062033)],
        );
    }
  }
}

class _HabitatPainter extends CustomPainter {
  final String biome;
  final int level;
  final double time;
  final bool autoWater;
  final bool autoFeeder;

  const _HabitatPainter({
    required this.biome,
    required this.level,
    required this.time,
    required this.autoWater,
    required this.autoFeeder,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // The gradient is supplied by the parent. This painter adds a clearly
    // visible island and habitat objects on top of it.
    final cx = size.width * 0.5;
    final cy = size.height * 0.53;
    final rx = size.width * 0.43;
    final ry = size.height * 0.34;

    final shore = Paint()..color = _shoreColor();
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy), width: rx * 2, height: ry * 2),
      shore,
    );

    final grass = Paint()
      ..shader = RadialGradient(
        colors: <Color>[_grassLight(), _grassDark()],
      ).createShader(
        Rect.fromCenter(
          center: Offset(cx, cy - 2),
          width: rx * 1.86,
          height: ry * 1.78,
        ),
      );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, cy - 2),
        width: rx * 1.86,
        height: ry * 1.78,
      ),
      grass,
    );

    _drawAtmosphere(canvas, size);
    _drawWater(canvas, size);
    _drawFeedingStation(canvas, size);
    _drawFence(canvas, Offset(cx, cy), rx * 0.88, ry * 0.86);
    _drawPlants(canvas, size);
    if (level >= 3) _drawShelter(canvas, size);
    if (level >= 6) _drawNest(canvas, size);
    if (level >= 8) _drawFireflies(canvas, size);

    if (autoFeeder) _drawAutomationBadge(canvas, size, true);
    if (autoWater) _drawAutomationBadge(canvas, size, false);
  }

  void _drawWater(Canvas canvas, Size size) {
    final s = _propScale(size);
    final center = Offset(size.width * 0.29, size.height * 0.50);
    final paint = Paint()..color = _waterColor();
    canvas.drawOval(
      Rect.fromCenter(center: center, width: 54 * s, height: 32 * s),
      paint,
    );

    final ripple = Paint()
      ..color = Colors.white.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4 * s;
    final pulse = (sin(time * 2) + 1) / 2;
    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: (18 + pulse * 24) * s,
        height: (8 + pulse * 12) * s,
      ),
      ripple,
    );

    if (biome == 'ice_age_tundra') {
      final ice = Paint()..color = const Color(0xFFE0F2FE);
      canvas.drawOval(
        Rect.fromCenter(
          center: center + Offset(6 * s, -3 * s),
          width: 22 * s,
          height: 10 * s,
        ),
        ice,
      );
    }
  }

  void _drawFeedingStation(Canvas canvas, Size size) {
    final s = _propScale(size);
    final center = Offset(size.width * 0.68, size.height * 0.49);
    final post = Paint()..color = const Color(0xFF7C4A24);
    canvas.drawRect(
      Rect.fromCenter(
        center: center + Offset(0, 9 * s),
        width: 5 * s,
        height: 18 * s,
      ),
      post,
    );
    final bowl = Paint()..color = const Color(0xFFF59E0B);
    canvas.drawOval(
      Rect.fromCenter(center: center, width: 40 * s, height: 14 * s),
      bowl,
    );
    final food = Paint()..color = const Color(0xFF84CC16);
    canvas.drawCircle(center + Offset(-8 * s, -1 * s), 4 * s, food);
    canvas.drawCircle(center + Offset(3 * s, -2 * s), 4 * s, food);
    canvas.drawCircle(center + Offset(12 * s, -1 * s), 3 * s, food);
  }

  void _drawFence(Canvas canvas, Offset center, double rx, double ry) {
    final paint = Paint()
      ..color = _fenceColor()
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    final fill = Paint()..color = _fenceColor();
    const start = pi * 1.10;
    const end = pi * 1.90;
    const count = 9;
    Offset? previous;
    for (var i = 0; i < count; i++) {
      final angle = start + (end - start) * i / (count - 1);
      final point = Offset(
        center.dx + rx * cos(angle),
        center.dy + ry * sin(angle),
      );
      if (previous != null) {
        canvas.drawLine(previous, point, paint);
      }
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: point, width: 4, height: 12),
          const Radius.circular(2),
        ),
        fill,
      );
      previous = point;
    }
  }

  void _drawPlants(Canvas canvas, Size size) {
    final s = _propScale(size);
    switch (biome) {
      case 'australian_forest':
        _drawEucalyptus(canvas, size, s);
        break;
      case 'northern_coast':
        _drawCoastalFlora(canvas, size, s);
        break;
      case 'african_grasslands':
        _drawSavannaFlora(canvas, size, s);
        break;
      case 'ice_age_tundra':
        _drawTundraFlora(canvas, size, s);
        break;
      default:
        _drawTropicalFlora(canvas, size, s);
    }
  }

  void _drawTropicalFlora(Canvas canvas, Size size, double s) {
    final trunk = Paint()
      ..color = const Color(0xFF7C5A2B)
      ..strokeWidth = 2.4 * s
      ..strokeCap = StrokeCap.round;
    final palm = Paint()
      ..color = const Color(0xFF22C55E)
      ..strokeWidth = 2 * s
      ..strokeCap = StrokeCap.round;
    final fern = Paint()..color = const Color(0xFF4ADE80);

    for (final p in <Offset>[
      Offset(size.width * .16, size.height * .60),
      Offset(size.width * .83, size.height * .56),
    ]) {
      final top = p + Offset(0, -16 * s);
      canvas.drawLine(p, top, trunk);
      for (var i = 0; i < 4; i++) {
        final angle = -pi / 2 + (i - 1.5) * 0.55;
        canvas.drawLine(
          top,
          top + Offset(cos(angle) * 20 * s, sin(angle) * 14 * s),
          palm,
        );
      }
    }
    for (final p in <Offset>[
      Offset(size.width * .46, size.height * .30),
      Offset(size.width * .76, size.height * .40),
      Offset(size.width * .22, size.height * .40),
    ]) {
      canvas.drawLine(p, p + Offset(0, 10 * s), trunk);
      canvas.drawOval(
        Rect.fromCenter(
          center: p + Offset(-3 * s, 4 * s),
          width: 8 * s,
          height: 4 * s,
        ),
        fern,
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: p + Offset(3 * s, 6 * s),
          width: 8 * s,
          height: 4 * s,
        ),
        fern,
      );
    }
  }

  void _drawEucalyptus(Canvas canvas, Size size, double s) {
    final trunk = Paint()
      ..color = const Color(0xFF9CA3AF)
      ..strokeWidth = 3 * s
      ..strokeCap = StrokeCap.round;
    final canopy = Paint()..color = const Color(0xFF6B8E6B);
    final undergrowth = Paint()..color = const Color(0xFF3F6212);

    for (final p in <Offset>[
      Offset(size.width * .18, size.height * .58),
      Offset(size.width * .80, size.height * .54),
    ]) {
      canvas.drawLine(p, p + Offset(0, -26 * s), trunk);
      canvas.drawOval(
        Rect.fromCenter(
          center: p + Offset(0, -32 * s),
          width: 24 * s,
          height: 15 * s,
        ),
        canopy,
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: p + Offset(-11 * s, -27 * s),
          width: 13 * s,
          height: 9 * s,
        ),
        canopy,
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: p + Offset(11 * s, -28 * s),
          width: 13 * s,
          height: 9 * s,
        ),
        canopy,
      );
    }
    for (final p in <Offset>[
      Offset(size.width * .42, size.height * .63),
      Offset(size.width * .58, size.height * .34),
    ]) {
      canvas.drawOval(
        Rect.fromCenter(
          center: p,
          width: 20 * s,
          height: 7 * s,
        ),
        undergrowth,
      );
    }
  }

  void _drawCoastalFlora(Canvas canvas, Size size, double s) {
    final rock = Paint()..color = const Color(0xFF64748B);
    final rockDark = Paint()..color = const Color(0xFF475569);
    final kelp = Paint()
      ..color = const Color(0xFF166534)
      ..strokeWidth = 2 * s
      ..strokeCap = StrokeCap.round;
    final foam = Paint()..color = Colors.white.withValues(alpha: 0.55);

    for (final p in <Offset>[
      Offset(size.width * .15, size.height * .42),
      Offset(size.width * .84, size.height * .38),
      Offset(size.width * .72, size.height * .66),
    ]) {
      canvas.drawOval(
        Rect.fromCenter(center: p, width: 24 * s, height: 13 * s),
        rock,
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: p + Offset(-5 * s, 3 * s),
          width: 12 * s,
          height: 6 * s,
        ),
        rockDark,
      );
    }
    for (var i = 0; i < 3; i++) {
      final x = size.width * (0.18 + i * 0.035);
      final base = size.height * 0.62;
      final path = Path()
        ..moveTo(x, base)
        ..quadraticBezierTo(
          x + 6 * s,
          base - 12 * s,
          x - 2 * s,
          base - 22 * s,
        );
      canvas.drawPath(path, kelp);
    }
    canvas.drawCircle(
      Offset(size.width * .30, size.height * .58),
      2.2 * s,
      foam,
    );
    canvas.drawCircle(
      Offset(size.width * .33, size.height * .56),
      1.4 * s,
      foam,
    );
  }

  void _drawSavannaFlora(Canvas canvas, Size size, double s) {
    final trunk = Paint()
      ..color = const Color(0xFF78350F)
      ..strokeWidth = 3 * s
      ..strokeCap = StrokeCap.round;
    final canopy = Paint()..color = const Color(0xFF6B7F2A);
    final grass = Paint()
      ..color = const Color(0xFFD4A72C)
      ..strokeWidth = 1.4 * s
      ..strokeCap = StrokeCap.round;

    final acacia = Offset(size.width * .82, size.height * .42);
    canvas.drawLine(
      acacia,
      acacia + Offset(0, 26 * s),
      trunk,
    );
    canvas.drawLine(
      acacia + Offset(0, 8 * s),
      acacia + Offset(-10 * s, 18 * s),
      trunk,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: acacia + Offset(0, -4 * s),
        width: 46 * s,
        height: 13 * s,
      ),
      canopy,
    );

    for (var i = 0; i < 6; i++) {
      final base = Offset(
        size.width * (0.14 + i * 0.11),
        size.height * (0.44 + (i % 3) * 0.08),
      );
      canvas.drawLine(base, base + Offset(-3 * s, -7 * s), grass);
      canvas.drawLine(base, base + Offset(1 * s, -9 * s), grass);
      canvas.drawLine(base, base + Offset(4 * s, -6 * s), grass);
    }
  }

  void _drawTundraFlora(Canvas canvas, Size size, double s) {
    final snow = Paint()..color = const Color(0xFFE2E8F0);
    final ice = Paint()..color = const Color(0xFFBAE6FD);
    final lichen = Paint()..color = const Color(0xFF7DD3FC);

    for (final p in <Offset>[
      Offset(size.width * .16, size.height * .40),
      Offset(size.width * .84, size.height * .62),
      Offset(size.width * .62, size.height * .34),
    ]) {
      canvas.drawOval(
        Rect.fromCenter(center: p, width: 26 * s, height: 12 * s),
        snow,
      );
    }
    for (final p in <Offset>[
      Offset(size.width * .24, size.height * .64),
      Offset(size.width * .74, size.height * .40),
    ]) {
      final shard = Path()
        ..moveTo(p.dx, p.dy - 12 * s)
        ..lineTo(p.dx + 6 * s, p.dy)
        ..lineTo(p.dx - 6 * s, p.dy)
        ..close();
      canvas.drawPath(shard, ice);
      canvas.drawCircle(p + Offset(-9 * s, 3 * s), 2 * s, lichen);
      canvas.drawCircle(p + Offset(-12 * s, 6 * s), 1.4 * s, lichen);
    }
  }

  void _drawShelter(Canvas canvas, Size size) {
    final s = _propScale(size);
    final p = Offset(size.width * .67, size.height * .29);

    switch (biome) {
      case 'australian_forest':
        final log = Paint()..color = const Color(0xFF8B5A2B);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: p + Offset(0, 8 * s),
              width: 44 * s,
              height: 18 * s,
            ),
            Radius.circular(7 * s),
          ),
          log,
        );
        canvas.drawOval(
          Rect.fromCenter(
            center: p + Offset(16 * s, 8 * s),
            width: 10 * s,
            height: 12 * s,
          ),
          Paint()..color = const Color(0xFF3F2A14),
        );
        break;
      case 'northern_coast':
        final ledge = Paint()..color = const Color(0xFF64748B);
        final cave = Paint()..color = const Color(0xFF1E293B);
        canvas.drawOval(
          Rect.fromCenter(
            center: p + Offset(0, 6 * s),
            width: 52 * s,
            height: 22 * s,
          ),
          ledge,
        );
        canvas.drawOval(
          Rect.fromCenter(
            center: p + Offset(-14 * s, 7 * s),
            width: 16 * s,
            height: 12 * s,
          ),
          cave,
        );
        break;
      case 'african_grasslands':
        final branch = Paint()
          ..color = const Color(0xFF78350F)
          ..strokeWidth = 2.4 * s
          ..strokeCap = StrokeCap.round;
        final leaves = Paint()..color = const Color(0xFF4D7C0F);
        for (var i = 0; i < 3; i++) {
          final base = p + Offset((i - 1) * 14 * s, 12 * s);
          canvas.drawLine(base, base + Offset(0, -18 * s), branch);
          canvas.drawOval(
            Rect.fromCenter(
              center: base + Offset(0, -20 * s),
              width: 18 * s,
              height: 10 * s,
            ),
            leaves,
          );
        }
        break;
      case 'ice_age_tundra':
        final ice = Paint()..color = const Color(0xFFBAE6FD);
        final cave = Paint()..color = const Color(0xFF0C4A6E);
        canvas.drawArc(
          Rect.fromCenter(
            center: p + Offset(0, 12 * s),
            width: 46 * s,
            height: 40 * s,
          ),
          pi,
          pi,
          true,
          ice,
        );
        canvas.drawArc(
          Rect.fromCenter(
            center: p + Offset(0, 12 * s),
            width: 22 * s,
            height: 20 * s,
          ),
          pi,
          pi,
          true,
          cave,
        );
        break;
      default:
        final wood = Paint()..color = const Color(0xFF8B5A2B);
        canvas.drawRect(
          Rect.fromLTWH(p.dx - 18 * s, p.dy, 4 * s, 20 * s),
          wood,
        );
        canvas.drawRect(
          Rect.fromLTWH(p.dx + 14 * s, p.dy, 4 * s, 20 * s),
          wood,
        );
        final roof = Path()
          ..moveTo(p.dx - 25 * s, p.dy)
          ..lineTo(p.dx, p.dy - 16 * s)
          ..lineTo(p.dx + 25 * s, p.dy)
          ..close();
        canvas.drawPath(roof, Paint()..color = const Color(0xFFB45309));
    }
  }

  void _drawNest(Canvas canvas, Size size) {
    final s = _propScale(size);
    final center = Offset(size.width * .52, size.height * .67);
    final Color beddingColor;
    switch (biome) {
      case 'australian_forest':
        beddingColor = const Color(0xFF4B5563);
        break;
      case 'northern_coast':
        beddingColor = const Color(0xFF475569);
        break;
      case 'african_grasslands':
        beddingColor = const Color(0xFFA16207);
        break;
      case 'ice_age_tundra':
        beddingColor = const Color(0xFF94A3B8);
        break;
      default:
        beddingColor = const Color(0xFF92400E);
    }
    final nest = Paint()..color = beddingColor;
    canvas.drawOval(
      Rect.fromCenter(center: center, width: 46 * s, height: 20 * s),
      nest,
    );
    final egg = Paint()..color = const Color(0xFFF8FAFC);
    canvas.drawOval(
      Rect.fromCenter(
        center: center + Offset(-8 * s, -3 * s),
        width: 9 * s,
        height: 13 * s,
      ),
      egg,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: center + Offset(8 * s, -2 * s),
        width: 9 * s,
        height: 13 * s,
      ),
      egg,
    );
  }

  void _drawAtmosphere(Canvas canvas, Size size) {
    final s = _propScale(size);
    final color = _atmosphereColor();
    final count = biome == 'ice_age_tundra' ? 16 : 10;
    for (var i = 0; i < count; i++) {
      final drift = 0.012 + (i % 5) * 0.004;
      final x = ((i * 0.173 + time * drift) % 1.0) * size.width;
      final y =
          (0.08 + ((i * 0.211 + time * drift * 0.6) % 0.78)) * size.height;
      final radius = (i % 3 == 0 ? 1.7 : 1.1) * s;
      final paint = Paint()
        ..color = color.withValues(alpha: 0.16 + (i % 4) * 0.05);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  void _drawFireflies(Canvas canvas, Size size) {
    final s = _propScale(size);
    final glow = Paint()
      ..color = _atmosphereColor().withValues(alpha: 0.8);
    for (var i = 0; i < 8; i++) {
      final x = (0.15 + ((i * 0.117) % .72)) * size.width;
      final y = (0.18 + ((i * .173) % .55)) * size.height;
      final pulse = (1.5 + sin(time * 2 + i) * .8) * s;
      canvas.drawCircle(Offset(x, y), pulse, glow);
    }
  }

  void _drawAutomationBadge(Canvas canvas, Size size, bool feeder) {
    final s = _propScale(size);
    final center = feeder
        ? Offset(size.width * .70, size.height * .55)
        : Offset(size.width * .29, size.height * .55);
    final paint = Paint()
      ..color = AppColors.accent.withValues(alpha: 0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2 * s;
    canvas.drawCircle(center, 19 * s, paint);
  }

  double _propScale(Size size) =>
      (size.shortestSide / 360).clamp(0.75, 1.55);

  Color _waterColor() {
    switch (biome) {
      case 'australian_forest':
        return const Color(0xFF2D6A7A);
      case 'northern_coast':
        return const Color(0xFF1E7FA8);
      case 'african_grasslands':
        return const Color(0xFF7C9A3B);
      case 'ice_age_tundra':
        return const Color(0xFF7DD3FC);
      default:
        return const Color(0xFF38BDF8);
    }
  }

  Color _atmosphereColor() {
    switch (biome) {
      case 'australian_forest':
        return const Color(0xFFA3E635);
      case 'northern_coast':
        return const Color(0xFFBAE6FD);
      case 'african_grasslands':
        return const Color(0xFFFDE68A);
      case 'ice_age_tundra':
        return const Color(0xFFF8FAFC);
      default:
        return const Color(0xFFFDE68A);
    }
  }

  Color _shoreColor() {
    switch (biome) {
      case 'australian_forest':
        return const Color(0xFF9A5B32);
      case 'northern_coast':
        return const Color(0xFF94A3B8);
      case 'african_grasslands':
        return const Color(0xFFD4A72C);
      case 'ice_age_tundra':
        return const Color(0xFFE2E8F0);
      default:
        return const Color(0xFFE5C384);
    }
  }

  Color _grassLight() {
    switch (biome) {
      case 'australian_forest':
        return const Color(0xFF527A45);
      case 'northern_coast':
        return const Color(0xFF475569);
      case 'african_grasslands':
        return const Color(0xFFC49A36);
      case 'ice_age_tundra':
        return const Color(0xFFF1F5F9);
      default:
        return const Color(0xFF4E9A61);
    }
  }

  Color _grassDark() {
    switch (biome) {
      case 'australian_forest':
        return const Color(0xFF244225);
      case 'northern_coast':
        return const Color(0xFF1E293B);
      case 'african_grasslands':
        return const Color(0xFF755116);
      case 'ice_age_tundra':
        return const Color(0xFFCBD5E1);
      default:
        return const Color(0xFF1F633D);
    }
  }

  Color _fenceColor() {
    switch (biome) {
      case 'northern_coast':
        return const Color(0xFF64748B);
      case 'african_grasslands':
        return const Color(0xFF78350F);
      default:
        return const Color(0xFF7C4A24);
    }
  }

  @override
  bool shouldRepaint(covariant _HabitatPainter oldDelegate) {
    return oldDelegate.biome != biome ||
        oldDelegate.level != level ||
        oldDelegate.time != time ||
        oldDelegate.autoWater != autoWater ||
        oldDelegate.autoFeeder != autoFeeder;
  }
}
