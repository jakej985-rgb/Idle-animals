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
  double jumpOffset;
  double jumpVelocity;

  _AnimatedAnimal({
    required this.x,
    required this.y,
    required this.targetX,
    required this.targetY,
    required this.speed,
    required this.stateTimer,
    required this.activity,
  })  : facingLeft = false,
        jumpOffset = 0.0,
        jumpVelocity = 0.0;
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
    final x = 0.25 + (_rng.nextDouble() * 0.5);
    final y = 0.32 + (_rng.nextDouble() * 0.4);
    return _AnimatedAnimal(
      x: x,
      y: y,
      targetX: x,
      targetY: y,
      speed: 0.07 + (_rng.nextDouble() * 0.06),
      stateTimer: 2.0 + _rng.nextDouble() * 3.0,
      activity: 'resting',
    );
  }

  void _updateAnimation() {
    const dt = 0.016;
    _elapsedTime += dt;

    for (final animal in _animals) {
      // Jump physics
      if (animal.jumpVelocity != 0.0 || animal.jumpOffset < 0.0) {
        animal.jumpVelocity += 650.0 * dt;
        animal.jumpOffset += animal.jumpVelocity * dt;
        if (animal.jumpOffset >= 0.0) {
          animal.jumpOffset = 0.0;
          animal.jumpVelocity = 0.0;
        }
      }

      animal.stateTimer -= dt;
      if (animal.stateTimer <= 0) {
        final activities = ['roaming', 'pecking', 'drinking', 'resting'];
        animal.activity = activities[_rng.nextInt(activities.length)];
        animal.stateTimer = 2.5 + (_rng.nextDouble() * 3.5);

        if (animal.activity == 'drinking') {
          animal.targetX = 0.30 + (_rng.nextDouble() * 0.08);
          animal.targetY = 0.48 + (_rng.nextDouble() * 0.08);
        } else if (animal.activity == 'pecking') {
          animal.targetX = 0.65 + (_rng.nextDouble() * 0.08);
          animal.targetY = 0.42 + (_rng.nextDouble() * 0.08);
        } else if (animal.activity == 'resting') {
          animal.targetX = animal.x;
          animal.targetY = animal.y;
        } else {
          animal.targetX = 0.22 + (_rng.nextDouble() * 0.56);
          animal.targetY = 0.30 + (_rng.nextDouble() * 0.42);
        }
      }

      final dx = animal.targetX - animal.x;
      final dy = animal.targetY - animal.y;
      final dist = sqrt(dx * dx + dy * dy);

      if (dist > 0.01 && animal.activity != 'resting') {
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

    // Trigger bounce hop on animals
    for (final animal in _animals) {
      animal.jumpVelocity = -140.0 - (_rng.nextDouble() * 90.0);
      animal.jumpOffset = -2.0;
      if (animal.activity == 'resting') {
        animal.activity = 'roaming';
        animal.stateTimer = 2.0;
      }
    }

    final box = context.findRenderObject() as RenderBox?;
    if (box != null) {
      final localPos = details.localPosition;
      final texts = ['+1 🪙', '+0.5 🧬', '❤️', '✨', '🐾'];
      final colors = [
        const Color(0xFFFBBF24),
        const Color(0xFF38BDF8),
        const Color(0xFFF43F5E),
        const Color(0xFFA78BFA),
        const Color(0xFF34D399),
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

              // Animated Habitat Animals with Hop Physics & Bobbing
              ..._animals.map((animal) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final px = animal.x * constraints.maxWidth;
                    final py = animal.y * constraints.maxHeight;
                    final bobbing = animal.activity == 'resting'
                        ? sin(_elapsedTime * 2.0 + animal.x * 5) * 1.0
                        : sin((_elapsedTime * 6.0) + (animal.x * 10)) * 2.2;
                    final totalY = py - 20 + bobbing + animal.jumpOffset;
                    final isJumping = animal.jumpOffset < -2.0;

                    return Positioned(
                      left: px - 20,
                      top: totalY,
                      child: Transform.scale(
                        scale: isJumping ? 1.15 : 1.0,
                        child: Transform.flip(
                          flipX: animal.facingLeft,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 1),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.45),
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
    Color fenceColor = const Color(0xFF8D5B2E);
    Color flowerColor1 = const Color(0xFFF43F5E);
    Color flowerColor2 = const Color(0xFFFBBF24);

    if (biomeType == 'australian_forest') {
      waterWaveColor = const Color(0xFF2D5A46);
      terrainBorderColor = const Color(0xFFB4532B); // Red outback soil
      terrainMainStart = const Color(0xFF42633E);
      terrainMainEnd = const Color(0xFF273F25);
      springColor = const Color(0xFF4FA07B);
      fenceColor = const Color(0xFF7C3E1D);
      flowerColor1 = const Color(0xFFFB7185);
      flowerColor2 = const Color(0xFFFACC15);
    } else if (biomeType == 'northern_coast') {
      waterWaveColor = const Color(0xFF163E5F);
      terrainBorderColor = const Color(0xFF475569); // Granite cliffs
      terrainMainStart = const Color(0xFF334155);
      terrainMainEnd = const Color(0xFF1E293B);
      springColor = const Color(0xFF38BDF8);
      fenceColor = const Color(0xFF64748B);
      flowerColor1 = const Color(0xFF818CF8);
      flowerColor2 = const Color(0xFF93C5FD);
    } else if (biomeType == 'african_grasslands') {
      waterWaveColor = const Color(0xFF785B2D);
      terrainBorderColor = const Color(0xFFD97706); // Golden savannah sand
      terrainMainStart = const Color(0xFFB48325);
      terrainMainEnd = const Color(0xFF785413);
      springColor = const Color(0xFF38BDF8);
      fenceColor = const Color(0xFF92400E);
      flowerColor1 = const Color(0xFFF97316);
      flowerColor2 = const Color(0xFFFDE047);
    } else if (biomeType == 'ice_age_tundra') {
      waterWaveColor = const Color(0xFF38BDF8);
      terrainBorderColor = const Color(0xFF93C5FD); // Glacial ice edge
      terrainMainStart = const Color(0xFFE2E8F0); // Snow permafrost
      terrainMainEnd = const Color(0xFFCBD5E1);
      springColor = const Color(0xFF67E8F9);
      fenceColor = const Color(0xFF475569);
      flowerColor1 = const Color(0xFFBAE6FD);
      flowerColor2 = const Color(0xFFC084FC);
    }

    // 1. Water waves background effect
    final wavePaint = Paint()
      ..color = waterWaveColor.withOpacity(0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (int i = 0; i < 4; i++) {
      final yOffset = h * 0.18 + (i * 45.0);
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
    final islandRadiusX = w * 0.44;
    final islandRadiusY = h * 0.38;

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

    // 3. Terrain Center (Lush Island Body)
    final grassGradient = RadialGradient(
      center: const Alignment(0.0, -0.2),
      radius: 0.9,
      colors: [terrainMainStart, terrainMainEnd],
    ).createShader(Rect.fromCenter(
      center: islandCenter,
      width: islandRadiusX * 1.84,
      height: islandRadiusY * 1.76,
    ));

    final grassPaint = Paint()..shader = grassGradient;

    canvas.drawOval(
      Rect.fromCenter(
        center: islandCenter,
        width: islandRadiusX * 1.84,
        height: islandRadiusY * 1.76,
      ),
      grassPaint,
    );

    // 4. Perimeter Wooden Fencing (Tier 1+)
    _drawPerimeterFencing(canvas, islandCenter, islandRadiusX * 0.88,
        islandRadiusY * 0.86, fenceColor);

    // 5. Freshwater Spring with Animated Water Ripples
    _drawWaterSpring(canvas, w, h, springColor);

    // 6. Progressive Shade Shelter (Level 3+)
    if (habitatLevel >= 3) {
      _drawShadeShelter(canvas, w, h, fenceColor);
    }

    // 7. Progressive Feeding Station
    _drawFeedingStation(canvas, w, h);

    // 8. Nesting Hollow with Eggs (Level 6+)
    if (habitatLevel >= 6) {
      _drawNestingHollow(canvas, w, h);
    }

    // 9. Natural Flora & Rocks (Tiered by Habitat Level)
    _drawFloraAndRocks(canvas, w, h, flowerColor1, flowerColor2);

    // 10. Ambient Glow Fireflies (High Level Reserve)
    if (habitatLevel >= 8) {
      _drawAmbientSpores(canvas, w, h);
    }
  }

  void _drawPerimeterFencing(Canvas canvas, Offset center, double rx, double ry,
      Color fenceColor) {
    // Posts along top-left to top-right arc
    final postPaint = Paint()
      ..color = fenceColor
      ..style = PaintingStyle.fill;
    final railPaint = Paint()
      ..color = fenceColor.withOpacity(0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final postPoints = <Offset>[];
    const startAngle = pi * 1.15;
    const endAngle = pi * 1.85;
    const count = 7;

    for (int i = 0; i < count; i++) {
      final angle = startAngle + (endAngle - startAngle) * (i / (count - 1));
      final px = center.dx + rx * cos(angle);
      final py = center.dy + ry * sin(angle);
      postPoints.add(Offset(px, py));
    }

    // Horizontal rails between posts
    for (int i = 0; i < postPoints.length - 1; i++) {
      canvas.drawLine(postPoints[i] + const Offset(0, -4),
          postPoints[i + 1] + const Offset(0, -4), railPaint);
      canvas.drawLine(postPoints[i] + const Offset(0, 1),
          postPoints[i + 1] + const Offset(0, 1), railPaint);
    }

    // Vertical posts
    for (final p in postPoints) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: p, width: 4, height: 12),
          const Radius.circular(2),
        ),
        postPaint,
      );
    }
  }

  void _drawWaterSpring(Canvas canvas, double w, double h, Color springColor) {
    final springCenter = Offset(w * 0.30, h * 0.50);

    // Stone rim around spring (Level >= 3)
    if (habitatLevel >= 3) {
      final pebblePaint = Paint()..color = const Color(0xFF64748B);
      const pebbleCount = 8;
      for (int i = 0; i < pebbleCount; i++) {
        final angle = (i / pebbleCount) * 2 * pi;
        final px = springCenter.dx + cos(angle) * 24;
        final py = springCenter.dy + sin(angle) * 15;
        canvas.drawOval(
          Rect.fromCenter(center: Offset(px, py), width: 6, height: 4),
          pebblePaint,
        );
      }
    }

    // Pond water body
    final springPaint = Paint()..color = springColor;
    canvas.drawOval(
      Rect.fromCenter(center: springCenter, width: 42, height: 26),
      springPaint,
    );

    // Concentric expanding water ripples
    final ripplePaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    for (int r = 0; r < 2; r++) {
      final rippleProgress = ((time * 0.8) + (r * 0.5)) % 1.0;
      final rx = 8.0 + (rippleProgress * 15.0);
      final ry = 4.0 + (rippleProgress * 8.0);
      final alpha = (1.0 - rippleProgress).clamp(0.0, 0.6);
      ripplePaint.color = Colors.white.withOpacity(alpha);
      canvas.drawOval(
        Rect.fromCenter(center: springCenter, width: rx * 2, height: ry * 2),
        ripplePaint,
      );
    }

    // Auto-water automated pump ring
    if (hasAutoWater) {
      final rimPaint = Paint()
        ..color = const Color(0xFF38BDF8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;
      canvas.drawCircle(springCenter, 24, rimPaint);
    }
  }

  void _drawShadeShelter(Canvas canvas, double w, double h, Color woodColor) {
    final shelterPos = Offset(w * 0.68, h * 0.28);
    final shelterWidth = habitatLevel >= 6 ? 48.0 : 36.0;
    final shelterHeight = habitatLevel >= 6 ? 26.0 : 20.0;

    // Drop shadow
    final shadowPaint = Paint()..color = Colors.black.withOpacity(0.25);
    canvas.drawOval(
      Rect.fromCenter(
        center: shelterPos + const Offset(0, 10),
        width: shelterWidth + 8,
        height: 12,
      ),
      shadowPaint,
    );

    // Support wooden posts
    final postPaint = Paint()
      ..color = woodColor
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;
    canvas.drawLine(shelterPos + Offset(-shelterWidth * 0.35, -4),
        shelterPos + Offset(-shelterWidth * 0.35, 10), postPaint);
    canvas.drawLine(shelterPos + Offset(shelterWidth * 0.35, -4),
        shelterPos + Offset(shelterWidth * 0.35, 10), postPaint);

    // Thatch roof canopy
    final roofPaint = Paint()
      ..color = habitatLevel >= 6
          ? const Color(0xFF0284C7) // Upgraded canvas pavilion
          : const Color(0xFFB45309) // Thatched amber reed
      ..style = PaintingStyle.fill;

    final roofPath = Path()
      ..moveTo(shelterPos.dx - (shelterWidth * 0.5), shelterPos.dy - 2)
      ..lineTo(shelterPos.dx, shelterPos.dy - shelterHeight)
      ..lineTo(shelterPos.dx + (shelterWidth * 0.5), shelterPos.dy - 2)
      ..close();
    canvas.drawPath(roofPath, roofPaint);

    // Ridge accent
    final ridgePaint = Paint()
      ..color = Colors.white24
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawLine(Offset(shelterPos.dx, shelterPos.dy - shelterHeight),
        Offset(shelterPos.dx - (shelterWidth * 0.5), shelterPos.dy - 2), ridgePaint);
  }

  void _drawFeedingStation(Canvas canvas, double w, double h) {
    final feederCenter = Offset(w * 0.70, h * 0.44);

    if (habitatLevel >= 6 || hasAutoFeeder) {
      // High-tech automated solar feeder
      final basePaint = Paint()..color = const Color(0xFF334155);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: feederCenter, width: 44, height: 20),
          const Radius.circular(5),
        ),
        basePaint,
      );

      // Solar canopy
      final solarPaint = Paint()..color = const Color(0xFF0369A1);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
              center: feederCenter + const Offset(0, -14),
              width: 32,
              height: 7),
          const Radius.circular(2),
        ),
        solarPaint,
      );

      // LED indicator pulse
      final ledPulse = (sin(time * 4) * 0.5 + 0.5);
      final ledPaint = Paint()
        ..color = Color.lerp(
            const Color(0xFF10B981), const Color(0xFF34D399), ledPulse)!;
      canvas.drawCircle(feederCenter + const Offset(-16, -1), 2.5, ledPaint);

      // Feeding bowl contents
      final foodPaint = Paint()..color = const Color(0xFFFBBF24);
      canvas.drawCircle(feederCenter + const Offset(0, 1), 5, foodPaint);
      final berryPaint = Paint()..color = const Color(0xFFEF4444);
      canvas.drawCircle(feederCenter + const Offset(8, 0), 3.5, berryPaint);
    } else if (habitatLevel >= 3) {
      // Wooden trough with greens & fruit
      final troughPaint = Paint()..color = const Color(0xFF8D5B2E);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: feederCenter, width: 40, height: 18),
          const Radius.circular(4),
        ),
        troughPaint,
      );
      final greenPaint = Paint()..color = const Color(0xFF4ADE80);
      canvas.drawCircle(feederCenter + const Offset(-8, -1), 4, greenPaint);
      final fruitPaint = Paint()..color = const Color(0xFFEF4444);
      canvas.drawCircle(feederCenter + const Offset(6, 1), 4, fruitPaint);
    } else {
      // Simple wooden fruit crate
      final cratePaint = Paint()..color = const Color(0xFF78350F);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: feederCenter, width: 28, height: 16),
          const Radius.circular(3),
        ),
        cratePaint,
      );
      final fruitPaint = Paint()..color = const Color(0xFFEF4444);
      canvas.drawCircle(feederCenter + const Offset(-4, 0), 3.5, fruitPaint);
      canvas.drawCircle(feederCenter + const Offset(4, 0), 3.5, fruitPaint);
    }
  }

  void _drawNestingHollow(Canvas canvas, double w, double h) {
    final nestPos = Offset(w * 0.22, h * 0.36);

    // Straw bed
    final strawPaint = Paint()..color = const Color(0xFFD97706);
    canvas.drawOval(
      Rect.fromCenter(center: nestPos, width: 34, height: 20),
      strawPaint,
    );

    // Inner hollow
    final hollowPaint = Paint()..color = const Color(0xFF92400E);
    canvas.drawOval(
      Rect.fromCenter(center: nestPos, width: 26, height: 14),
      hollowPaint,
    );

    // Speckled eggs
    final eggPaint = Paint()..color = const Color(0xFFFFFBEB);
    final eggSpotPaint = Paint()..color = const Color(0xFFD4D4D8);

    canvas.drawOval(
      Rect.fromCenter(center: nestPos + const Offset(-4, -1), width: 7, height: 10),
      eggPaint,
    );
    canvas.drawCircle(nestPos + const Offset(-4, -2), 1.2, eggSpotPaint);

    canvas.drawOval(
      Rect.fromCenter(center: nestPos + const Offset(4, 1), width: 8, height: 11),
      eggPaint,
    );
    canvas.drawCircle(nestPos + const Offset(4, 0), 1.3, eggSpotPaint);
  }

  void _drawFloraAndRocks(
      Canvas canvas, double w, double h, Color fCol1, Color fCol2) {
    final rockPaint = Paint()..color = const Color(0xFF475569);

    // Pebble clusters
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.46, h * 0.38), width: 8, height: 5),
      rockPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.49, h * 0.40), width: 5, height: 3),
      rockPaint,
    );

    // Flowers for Level >= 3
    if (habitatLevel >= 3) {
      _drawFlowerCluster(canvas, Offset(w * 0.38, h * 0.32), fCol1);
      _drawFlowerCluster(canvas, Offset(w * 0.58, h * 0.60), fCol2);
      _drawFlowerCluster(canvas, Offset(w * 0.78, h * 0.52), fCol1);
    }

    // Additional flora for Level >= 6
    if (habitatLevel >= 6) {
      _drawFlowerCluster(canvas, Offset(w * 0.18, h * 0.48), fCol2);
      _drawFlowerCluster(canvas, Offset(w * 0.42, h * 0.64), fCol1);
      _drawFlowerCluster(canvas, Offset(w * 0.64, h * 0.34), fCol2);
    }
  }

  void _drawFlowerCluster(Canvas canvas, Offset pos, Color color) {
    final stemPaint = Paint()
      ..color = const Color(0xFF15803D)
      ..strokeWidth = 1.5;
    canvas.drawLine(pos, pos + const Offset(0, 5), stemPaint);

    final petalPaint = Paint()..color = color;
    const petalRadius = 2.5;
    canvas.drawCircle(pos + const Offset(-2, -1), petalRadius, petalPaint);
    canvas.drawCircle(pos + const Offset(2, -1), petalRadius, petalPaint);
    canvas.drawCircle(pos + const Offset(0, -3), petalRadius, petalPaint);

    final centerPaint = Paint()..color = const Color(0xFFFEF08A);
    canvas.drawCircle(pos + const Offset(0, -1), 1.5, centerPaint);
  }

  void _drawAmbientSpores(Canvas canvas, double w, double h) {
    final sporePaint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < 5; i++) {
      final sx = (w * 0.25) + ((i * 57.0 + time * 12.0) % (w * 0.5));
      final sy = (h * 0.30) + (sin(time * 1.5 + i) * 20.0) + (i * 18.0);
      final alpha = (sin(time * 2.0 + i) * 0.3 + 0.5).clamp(0.1, 0.8);
      sporePaint.color = const Color(0xFF67E8F9).withOpacity(alpha);
      canvas.drawCircle(Offset(sx, sy), 2.2, sporePaint);
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
