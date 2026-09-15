import 'dart:math';
import 'package:flutter/material.dart';
import '../models/habitat.dart';
import '../models/species.dart';

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

class _FloatingParticle {
  final Offset position;
  final String text;
  final Color color;
  final double createdAt;

  _FloatingParticle({
    required this.position,
    required this.text,
    required this.color,
    required this.createdAt,
  });
}

class _AnimatedAnimal {
  double x;
  double y;
  double targetX;
  double targetY;
  double speed;
  double stateTimer;
  String activity;
  bool facingLeft;

  _AnimatedAnimal({
    required this.x,
    required this.y,
    required this.targetX,
    required this.targetY,
    required this.speed,
    required this.stateTimer,
    required this.activity,
  }) : facingLeft = false;
}

class _HabitatViewportState extends State<HabitatViewport>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  final List<_AnimatedAnimal> _animals = [];
  final List<_FloatingParticle> _particles = [];
  final Random _rng = Random();
  double _elapsedTime = 0.0;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..addListener(_updateAnimation);

    _syncAnimals(widget.habitat.population);
    _animController.repeat();
  }

  @override
  void didUpdateWidget(HabitatViewport oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.habitat.population != widget.habitat.population ||
        oldWidget.habitat.speciesId != widget.habitat.speciesId) {
      _syncAnimals(widget.habitat.population);
    }
  }

  void _syncAnimals(int count) {
    final visualCount = min(18, max(1, count));
    while (_animals.length < visualCount) {
      _animals.add(_createRandomAnimal());
    }
    while (_animals.length > visualCount) {
      _animals.removeLast();
    }
  }

  _AnimatedAnimal _createRandomAnimal() {
    final x = 0.2 + (_rng.nextDouble() * 0.6);
    final y = 0.25 + (_rng.nextDouble() * 0.5);
    return _AnimatedAnimal(
      x: x,
      y: y,
      targetX: x,
      targetY: y,
      speed: 0.08 + (_rng.nextDouble() * 0.06),
      stateTimer: 2.0 + _rng.nextDouble() * 3.0,
      activity: 'resting',
    );
  }

  void _updateAnimation() {
    const dt = 0.016;
    _elapsedTime += dt;

    for (final animal in _animals) {
      animal.stateTimer -= dt;
      if (animal.stateTimer <= 0) {
        final activities = ['walking', 'pecking', 'drinking', 'resting'];
        animal.activity = activities[_rng.nextInt(activities.length)];
        animal.stateTimer = 2.5 + (_rng.nextDouble() * 3.5);

        if (animal.activity == 'drinking') {
          animal.targetX = 0.25 + (_rng.nextDouble() * 0.12);
          animal.targetY = 0.45 + (_rng.nextDouble() * 0.15);
        } else if (animal.activity == 'pecking') {
          animal.targetX = 0.55 + (_rng.nextDouble() * 0.15);
          animal.targetY = 0.35 + (_rng.nextDouble() * 0.15);
        } else {
          animal.targetX = 0.20 + (_rng.nextDouble() * 0.60);
          animal.targetY = 0.25 + (_rng.nextDouble() * 0.50);
        }
      }

      final dx = animal.targetX - animal.x;
      final dy = animal.targetY - animal.y;
      final dist = sqrt(dx * dx + dy * dy);

      if (dist > 0.01) {
        final step = min(dist, animal.speed * dt);
        animal.x += (dx / dist) * step;
        animal.y += (dy / dist) * step;
        animal.facingLeft = dx < 0;
      }
    }

    _particles.removeWhere((p) => (_elapsedTime - p.createdAt) > 1.2);

    setState(() {});
  }

  void _handleTapDown(TapDownDetails details) {
    widget.onTap();

    final box = context.findRenderObject() as RenderBox?;
    if (box != null) {
      final localPos = details.localPosition;
      final texts = ['+1 🪙', '+0.5 🧬', '❤️'];
      final colors = [
        const Color(0xFFFBBF24),
        const Color(0xFF38BDF8),
        const Color(0xFFF43F5E),
      ];
      final idx = _rng.nextInt(texts.length);

      _particles.add(_FloatingParticle(
        position: localPos,
        text: texts[idx],
        color: colors[idx],
        createdAt: _elapsedTime,
      ));
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final species = Species.fromId(widget.habitat.speciesId);

    return GestureDetector(
      onTapDown: _handleTapDown,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            gradient: _getBiomeGradient(widget.habitat.biomeType),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CustomPaint(
                painter: _BiomeEnvironmentPainter(
                  time: _elapsedTime,
                  biomeType: widget.habitat.biomeType,
                  habitatLevel: widget.habitat.level,
                  hasAutoFeeder: widget.habitat.hasAutoFeeder,
                  hasAutoWater: widget.habitat.hasAutoWater,
                ),
              ),

              // Animated Habitat Animals
              ..._animals.map((animal) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final px = animal.x * constraints.maxWidth;
                    final py = animal.y * constraints.maxHeight;
                    final bobbing = sin((_elapsedTime * 6.0) + (animal.x * 10)) * 2.5;

                    return Positioned(
                      left: px - 20,
                      top: py - 20 + bobbing,
                      child: Transform.flip(
                        flipX: animal.facingLeft,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.4),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _getActivityBadge(animal.activity),
                                style: const TextStyle(
                                  fontSize: 8,
                                  color: Colors.white70,
                                ),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              species.iconEmoji,
                              style: const TextStyle(fontSize: 28),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),

              // Floating Click Particles
              ..._particles.map((p) {
                final progress = (_elapsedTime - p.createdAt) / 1.2;
                final alpha = (1.0 - progress).clamp(0.0, 1.0);
                final floatOffset = progress * 40.0;

                return Positioned(
                  left: p.position.dx - 20,
                  top: p.position.dy - 20 - floatOffset,
                  child: Opacity(
                    opacity: alpha,
                    child: Text(
                      p.text,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: p.color,
                        shadows: const [
                          Shadow(
                            color: Colors.black,
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),

              Positioned(
                bottom: 12,
                left: 16,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.45),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('✨', style: TextStyle(fontSize: 12)),
                      const SizedBox(width: 4),
                      Text(
                        'Tap to care (+🪙 +🧬)',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
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
  }

  Gradient _getBiomeGradient(String biome) {
    switch (biome) {
      case 'australian_forest':
        return const RadialGradient(
          center: Alignment(0.0, -0.2),
          radius: 1.2,
          colors: [Color(0xFF2E4032), Color(0xFF131A15)],
        );
      case 'northern_coast':
        return const RadialGradient(
          center: Alignment(0.0, -0.2),
          radius: 1.2,
          colors: [Color(0xFF183852), Color(0xFF09141E)],
        );
      case 'african_grasslands':
        return const RadialGradient(
          center: Alignment(0.0, -0.2),
          radius: 1.2,
          colors: [Color(0xFF5B3F1B), Color(0xFF26190A)],
        );
      case 'ice_age_tundra':
        return const RadialGradient(
          center: Alignment(0.0, -0.2),
          radius: 1.2,
          colors: [Color(0xFF22516E), Color(0xFF0C1D29)],
        );
      default:
        return const RadialGradient(
          center: Alignment(0.0, -0.2),
          radius: 1.2,
          colors: [Color(0xFF0F4C81), Color(0xFF072138)],
        );
    }
  }

  String _getActivityBadge(String act) {
    switch (act) {
      case 'pecking':
        return '🍎 Feeding';
      case 'drinking':
        return '💧 Drinking';
      case 'resting':
        return '💤 Resting';
      default:
        return '🐾 Roaming';
    }
  }
}

class _BiomeEnvironmentPainter extends CustomPainter {
  final double time;
  final String biomeType;
  final int habitatLevel;
  final bool hasAutoFeeder;
  final bool hasAutoWater;

  _BiomeEnvironmentPainter({
    required this.time,
    required this.biomeType,
    required this.habitatLevel,
    required this.hasAutoFeeder,
    required this.hasAutoWater,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Determine Biome Color Scheme
    Color waterWaveColor = const Color(0xFF1E6F9F);
    Color terrainBorderColor = const Color(0xFFE5C384);
    Color terrainMainStart = const Color(0xFF2E8B57);
    Color terrainMainEnd = const Color(0xFF1F633D);
    Color springColor = const Color(0xFF38BDF8);

    if (biomeType == 'australian_forest') {
      waterWaveColor = const Color(0xFF2D5A46);
      terrainBorderColor = const Color(0xFFB4532B); // Red outback soil
      terrainMainStart = const Color(0xFF42633E);
      terrainMainEnd = const Color(0xFF273F25);
      springColor = const Color(0xFF4FA07B);
    } else if (biomeType == 'northern_coast') {
      waterWaveColor = const Color(0xFF163E5F);
      terrainBorderColor = const Color(0xFF475569); // Granite cliffs
      terrainMainStart = const Color(0xFF334155);
      terrainMainEnd = const Color(0xFF1E293B);
      springColor = const Color(0xFF38BDF8);
    } else if (biomeType == 'african_grasslands') {
      waterWaveColor = const Color(0xFF785B2D);
      terrainBorderColor = const Color(0xFFD97706); // Golden savannah sand
      terrainMainStart = const Color(0xFFB48325);
      terrainMainEnd = const Color(0xFF785413);
      springColor = const Color(0xFF38BDF8);
    } else if (biomeType == 'ice_age_tundra') {
      waterWaveColor = const Color(0xFF38BDF8);
      terrainBorderColor = const Color(0xFF93C5FD); // Glacial ice edge
      terrainMainStart = const Color(0xFFE2E8F0); // Snow permafrost
      terrainMainEnd = const Color(0xFFCBD5E1);
      springColor = const Color(0xFF67E8F9);
    }

    // 1. Water waves effect
    final wavePaint = Paint()
      ..color = waterWaveColor.withOpacity(0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (int i = 0; i < 4; i++) {
      final yOffset = h * 0.2 + (i * 45.0);
      final path = Path();
      path.moveTo(0, yOffset);
      for (double x = 0; x <= w; x += 30) {
        final waveY = sin((x * 0.02) + (time * 1.8) + i) * 6;
        path.lineTo(x, yOffset + waveY);
      }
      canvas.drawPath(path, wavePaint);
    }

    // 2. Terrain Shore / Border
    final islandCenter = Offset(w * 0.5, h * 0.52);
    final islandRadiusX = w * 0.42;
    final islandRadiusY = h * 0.36;

    final borderPaint = Paint()
      ..color = terrainBorderColor
      ..style = PaintingStyle.fill;

    canvas.drawOval(
      Rect.fromCenter(
        center: islandCenter,
        width: islandRadiusX * 2,
        height: islandRadiusY * 2,
      ),
      borderPaint,
    );

    // 3. Terrain Center
    final grassGradient = RadialGradient(
      center: const Alignment(0.0, -0.2),
      radius: 0.9,
      colors: [terrainMainStart, terrainMainEnd],
    ).createShader(Rect.fromCenter(
      center: islandCenter,
      width: islandRadiusX * 1.8,
      height: islandRadiusY * 1.7,
    ));

    final grassPaint = Paint()..shader = grassGradient;

    canvas.drawOval(
      Rect.fromCenter(
        center: islandCenter,
        width: islandRadiusX * 1.8,
        height: islandRadiusY * 1.7,
      ),
      grassPaint,
    );

    // 4. Freshwater / Glacial Spring
    final springCenter = Offset(w * 0.32, h * 0.50);
    final springPaint = Paint()..color = springColor;
    canvas.drawOval(
      Rect.fromCenter(center: springCenter, width: 44, height: 26),
      springPaint,
    );
    if (hasAutoWater) {
      final rimPaint = Paint()
        ..color = const Color(0xFF93C5FD)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;
      canvas.drawCircle(springCenter, 24, rimPaint);
    }

    // 5. Feeding Station
    final feederCenter = Offset(w * 0.68, h * 0.42);
    final feederPaint = Paint()..color = const Color(0xFF8D5B2E);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: feederCenter, width: 40, height: 22),
        const Radius.circular(6),
      ),
      feederPaint,
    );

    final fruitPaint = Paint()..color = const Color(0xFFEF4444);
    canvas.drawCircle(feederCenter + const Offset(-8, -2), 3.5, fruitPaint);
    canvas.drawCircle(feederCenter + const Offset(4, 1), 3.5, fruitPaint);

    if (hasAutoFeeder) {
      final rimPaint = Paint()
        ..color = const Color(0xFFFBBF24)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;
      canvas.drawCircle(feederCenter, 22, rimPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _BiomeEnvironmentPainter oldDelegate) {
    return oldDelegate.time != time ||
        oldDelegate.biomeType != biomeType ||
        oldDelegate.habitatLevel != habitatLevel ||
        oldDelegate.hasAutoFeeder != hasAutoFeeder ||
        oldDelegate.hasAutoWater != hasAutoWater;
  }
}
