import 'dart:math';
import 'package:flutter/material.dart';
import '../models/habitat.dart';

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
  final double createdAt; // in seconds

  _FloatingParticle({
    required this.position,
    required this.text,
    required this.color,
    required this.createdAt,
  });
}

class _AnimatedDodo {
  double x; // 0.0 to 1.0 (relative to island bounds)
  double y;
  double targetX;
  double targetY;
  double speed;
  double stateTimer;
  String activity; // 'pecking', 'drinking', 'resting', 'walking'
  bool facingLeft;

  _AnimatedDodo({
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
  final List<_AnimatedDodo> _dodos = [];
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

    _syncDodos(widget.habitat.population);
    _animController.repeat();
  }

  @override
  void didUpdateWidget(HabitatViewport oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.habitat.population != widget.habitat.population) {
      _syncDodos(widget.habitat.population);
    }
  }

  void _syncDodos(int count) {
    // Cap visual dodos to 18 for performance while representing large populations
    final visualCount = min(18, max(1, count));
    while (_dodos.length < visualCount) {
      _dodos.add(_createRandomDodo());
    }
    while (_dodos.length > visualCount) {
      _dodos.removeLast();
    }
  }

  _AnimatedDodo _createRandomDodo() {
    final x = 0.2 + (_rng.nextDouble() * 0.6);
    final y = 0.25 + (_rng.nextDouble() * 0.5);
    return _AnimatedDodo(
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
    final dt = 0.016; // approximate ~60fps
    _elapsedTime += dt;

    for (final dodo in _dodos) {
      dodo.stateTimer -= dt;
      if (dodo.stateTimer <= 0) {
        // Pick new activity & destination
        final activities = ['walking', 'pecking', 'drinking', 'resting'];
        dodo.activity = activities[_rng.nextInt(activities.length)];
        dodo.stateTimer = 2.5 + (_rng.nextDouble() * 3.5);

        if (dodo.activity == 'drinking') {
          // Water spring waypoint (near left shore)
          dodo.targetX = 0.25 + (_rng.nextDouble() * 0.12);
          dodo.targetY = 0.45 + (_rng.nextDouble() * 0.15);
        } else if (dodo.activity == 'pecking') {
          // Feeder waypoint (near center/right)
          dodo.targetX = 0.55 + (_rng.nextDouble() * 0.15);
          dodo.targetY = 0.35 + (_rng.nextDouble() * 0.15);
        } else {
          // Random stroll on island
          dodo.targetX = 0.20 + (_rng.nextDouble() * 0.60);
          dodo.targetY = 0.25 + (_rng.nextDouble() * 0.50);
        }
      }

      // Move toward target
      final dx = dodo.targetX - dodo.x;
      final dy = dodo.targetY - dodo.y;
      final dist = sqrt(dx * dx + dy * dy);

      if (dist > 0.01) {
        final step = min(dist, dodo.speed * dt);
        dodo.x += (dx / dist) * step;
        dodo.y += (dy / dist) * step;
        dodo.facingLeft = dx < 0;
      }
    }

    // Clean up old particles
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
    return GestureDetector(
      onTapDown: _handleTapDown,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0.0, -0.2),
              radius: 1.2,
              colors: [
                Color(0xFF0F4C81), // Tropical lagoon blue
                Color(0xFF072138), // Deep ocean
              ],
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Custom Painted Island, waves, and environment
              CustomPaint(
                painter: _IslandEnvironmentPainter(
                  time: _elapsedTime,
                  habitatLevel: widget.habitat.level,
                  hasAutoFeeder: widget.habitat.hasAutoFeeder,
                  hasAutoWater: widget.habitat.hasAutoWater,
                ),
              ),

              // Animated Dodos
              ..._dodos.map((dodo) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final px = dodo.x * constraints.maxWidth;
                    final py = dodo.y * constraints.maxHeight;
                    final bobbing = sin((_elapsedTime * 6.0) + (dodo.x * 10)) * 2.5;

                    return Positioned(
                      left: px - 20,
                      top: py - 20 + bobbing,
                      child: Transform.flip(
                        flipX: dodo.facingLeft,
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
                                _getActivityBadge(dodo.activity),
                                style: const TextStyle(
                                  fontSize: 8,
                                  color: Colors.white70,
                                ),
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              '🦤',
                              style: TextStyle(fontSize: 28),
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

              // Quick hint in top corner
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
                        'Tap island to care (+🪙 +🧬)',
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

class _IslandEnvironmentPainter extends CustomPainter {
  final double time;
  final int habitatLevel;
  final bool hasAutoFeeder;
  final bool hasAutoWater;

  _IslandEnvironmentPainter({
    required this.time,
    required this.habitatLevel,
    required this.hasAutoFeeder,
    required this.hasAutoWater,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Water waves effect
    final wavePaint = Paint()
      ..color = const Color(0xFF1E6F9F).withOpacity(0.3)
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

    // 2. Island Sandy Shore
    final islandCenter = Offset(w * 0.5, h * 0.52);
    final islandRadiusX = w * 0.42;
    final islandRadiusY = h * 0.36;

    final sandPaint = Paint()
      ..color = const Color(0xFFE5C384)
      ..style = PaintingStyle.fill;

    canvas.drawOval(
      Rect.fromCenter(
        center: islandCenter,
        width: islandRadiusX * 2,
        height: islandRadiusY * 2,
      ),
      sandPaint,
    );

    // 3. Lush Green Island Center
    final grassGradient = const RadialGradient(
      center: Alignment(0.0, -0.2),
      radius: 0.9,
      colors: [
        Color(0xFF2E8B57), // Lush sea green
        Color(0xFF1F633D), // Forest green
      ],
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

    // 4. Freshwater Spring (Left side)
    final springCenter = Offset(w * 0.32, h * 0.50);
    final springPaint = Paint()..color = const Color(0xFF38BDF8);
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

    // 5. Feeding Trough (Right side)
    final feederCenter = Offset(w * 0.68, h * 0.42);
    final feederPaint = Paint()..color = const Color(0xFF8D5B2E);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: feederCenter, width: 40, height: 22),
        const Radius.circular(6),
      ),
      feederPaint,
    );
    // Fruit dots
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

    // 6. Nesting Site / Soft Moss
    final nestCenter = Offset(w * 0.50, h * 0.68);
    final nestPaint = Paint()..color = const Color(0xFFC29B38).withOpacity(0.85);
    canvas.drawOval(
      Rect.fromCenter(center: nestCenter, width: 50, height: 24),
      nestPaint,
    );
    // Soft egg
    final eggPaint = Paint()..color = Colors.white70;
    canvas.drawOval(
      Rect.fromCenter(center: nestCenter + const Offset(0, -2), width: 9, height: 12),
      eggPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _IslandEnvironmentPainter oldDelegate) {
    return oldDelegate.time != time ||
        oldDelegate.habitatLevel != habitatLevel ||
        oldDelegate.hasAutoFeeder != hasAutoFeeder ||
        oldDelegate.hasAutoWater != hasAutoWater;
  }
}
