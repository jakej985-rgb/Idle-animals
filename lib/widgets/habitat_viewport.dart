import 'dart:math';

import 'package:flutter/material.dart';

import '../models/habitat.dart';
import '../models/species.dart';

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
  late final AnimationController _controller;
  final Random _random = Random();
  final List<_AnimalVisual> _animals = <_AnimalVisual>[];
  final List<_CareParticle> _particles = <_CareParticle>[];
  double _time = 0;

  @override
  void initState() {
    super.initState();
    _syncAnimals(widget.habitat.population);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(_tick);
    _controller.repeat();
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

  void _tick() {
    if (!mounted) return;
    const dt = 1 / 60;
    _time += dt;

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

    _particles.removeWhere((p) => _time - p.born > 1.15);
    setState(() {});
  }

  void _handleTap(TapDownDetails details) {
    widget.onTap();

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
        position: details.localPosition,
        text: texts[i],
        color: colors[i],
        born: _time,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final species = Species.fromId(widget.habitat.speciesId);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _handleTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: _backgroundGradient(widget.habitat.biomeType),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              // Explicit child sizing prevents a painter-only CustomPaint from
              // ever collapsing to an unexpected size on a device.
              CustomPaint(
                painter: _HabitatPainter(
                  biome: widget.habitat.biomeType,
                  level: widget.habitat.level,
                  time: _time,
                  autoWater: widget.habitat.hasAutoWater,
                  autoFeeder: widget.habitat.hasAutoFeeder,
                ),
                child: const SizedBox.expand(),
              ),
              ..._buildAnimals(species),
              ..._buildParticles(),
              Positioned(
                left: 14,
                bottom: 12,
                child: _hint(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildAnimals(Species species) {
    return _animals.map((animal) {
      return Positioned(
        left: (animal.x * 100) - 10,
        top: (animal.y * 100) - 12,
        width: 20,
        height: 32,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final dx = animal.x * constraints.maxWidth * 5;
            final dy = animal.y * constraints.maxHeight * 5;
            return Align(
              alignment: Alignment(
                (animal.x * 2) - 1,
                (animal.y * 2) - 1,
              ),
              child: Transform.translate(
                offset: Offset(animal.left ? -2 : 2, animal.jump),
                child: Transform.scale(
                  scale: animal.jump < -2 ? 1.08 : 1,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        _activityIcon(animal.activity),
                        style: const TextStyle(fontSize: 8),
                      ),
                      Text(
                        species.iconEmoji,
                        style: const TextStyle(fontSize: 28),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
    }).toList();
  }

  List<Widget> _buildParticles() {
    return _particles.map((particle) {
      final progress = ((_time - particle.born) / 1.15).clamp(0.0, 1.0);
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
    final center = Offset(size.width * 0.29, size.height * 0.50);
    final paint = Paint()..color = const Color(0xFF38BDF8);
    canvas.drawOval(
      Rect.fromCenter(center: center, width: 54, height: 32),
      paint,
    );

    final ripple = Paint()
      ..color = Colors.white.withOpacity(0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    final pulse = (sin(time * 2) + 1) / 2;
    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: 18 + pulse * 24,
        height: 8 + pulse * 12,
      ),
      ripple,
    );
  }

  void _drawFeedingStation(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.68, size.height * 0.49);
    final post = Paint()..color = const Color(0xFF7C4A24);
    canvas.drawRect(
      Rect.fromCenter(center: center + const Offset(0, 9), width: 5, height: 18),
      post,
    );
    final bowl = Paint()..color = const Color(0xFFF59E0B);
    canvas.drawOval(
      Rect.fromCenter(center: center, width: 40, height: 14),
      bowl,
    );
    final food = Paint()..color = const Color(0xFF84CC16);
    canvas.drawCircle(center + const Offset(-8, -1), 4, food);
    canvas.drawCircle(center + const Offset(3, -2), 4, food);
    canvas.drawCircle(center + const Offset(12, -1), 3, food);
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
    final stem = Paint()
      ..color = const Color(0xFF166534)
      ..strokeWidth = 2;
    final leaf = Paint()..color = const Color(0xFF4ADE80);
    final positions = <Offset>[
      Offset(size.width * .46, size.height * .34),
      Offset(size.width * .54, size.height * .65),
      Offset(size.width * .78, size.height * .37),
      Offset(size.width * .23, size.height * .65),
    ];
    for (final p in positions) {
      canvas.drawLine(p, p + const Offset(0, 13), stem);
      canvas.drawOval(
        Rect.fromCenter(center: p + const Offset(-4, 3), width: 10, height: 5),
        leaf,
      );
      canvas.drawOval(
        Rect.fromCenter(center: p + const Offset(4, 6), width: 10, height: 5),
        leaf,
      );
    }
  }

  void _drawShelter(Canvas canvas, Size size) {
    final p = Offset(size.width * .67, size.height * .29);
    final wood = Paint()..color = const Color(0xFF8B5A2B);
    canvas.drawRect(Rect.fromLTWH(p.dx - 18, p.dy, 4, 20), wood);
    canvas.drawRect(Rect.fromLTWH(p.dx + 14, p.dy, 4, 20), wood);
    final roof = Path()
      ..moveTo(p.dx - 25, p.dy)
      ..lineTo(p.dx, p.dy - 16)
      ..lineTo(p.dx + 25, p.dy)
      ..close();
    canvas.drawPath(roof, Paint()..color = const Color(0xFFB45309));
  }

  void _drawNest(Canvas canvas, Size size) {
    final center = Offset(size.width * .52, size.height * .67);
    final nest = Paint()..color = const Color(0xFF92400E);
    canvas.drawOval(
      Rect.fromCenter(center: center, width: 46, height: 20),
      nest,
    );
    final egg = Paint()..color = const Color(0xFFF8FAFC);
    canvas.drawOval(
      Rect.fromCenter(center: center + const Offset(-8, -3), width: 9, height: 13),
      egg,
    );
    canvas.drawOval(
      Rect.fromCenter(center: center + const Offset(8, -2), width: 9, height: 13),
      egg,
    );
  }

  void _drawFireflies(Canvas canvas, Size size) {
    final glow = Paint()..color = const Color(0xFFFDE68A).withOpacity(.8);
    for (var i = 0; i < 8; i++) {
      final x = (0.15 + ((i * 0.117) % .72)) * size.width;
      final y = (0.18 + ((i * .173) % .55)) * size.height;
      final pulse = 1.5 + sin(time * 2 + i) * .8;
      canvas.drawCircle(Offset(x, y), pulse, glow);
    }
  }

  void _drawAutomationBadge(Canvas canvas, Size size, bool feeder) {
    final center = feeder
        ? Offset(size.width * .70, size.height * .55)
        : Offset(size.width * .29, size.height * .55);
    final paint = Paint()
      ..color = const Color(0xFF38BDF8).withOpacity(.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, 19, paint);
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
