import 'dart:math';

import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' as vec;

void main() {
  runApp(const ParticleSimulationApp());
}

class ParticleSimulationApp extends StatelessWidget {
  const ParticleSimulationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
      ),
      home: const ParticleSimulationScreen(),
    );
  }
}

class ParticleSimulationScreen extends StatefulWidget {
  const ParticleSimulationScreen({super.key});

  @override
  State<ParticleSimulationScreen> createState() =>
      _ParticleSimulationScreenState();
}

class _ParticleSimulationScreenState extends State<ParticleSimulationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Particle> _particles;
  final int _numberOfParticles = 200;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(_updateParticles);

    _initializeParticles();
    _controller.repeat();
  }

  void _initializeParticles() {
    _particles = List.generate(
      _numberOfParticles,
          (index) => Particle(
        position: vec.Vector2(
          _random.nextDouble() * 400,
          _random.nextDouble() * 800,
        ),
        velocity: vec.Vector2(
          _random.nextDouble() * 2 - 1,
          _random.nextDouble() * 2 - 1,
        ),
        acceleration: vec.Vector2(0, 0.1),
        radius: _random.nextDouble() * 4 + 2,
        color: Colors.primaries[_random.nextInt(Colors.primaries.length)],
      ),
    );
  }

  void _updateParticles() {
    for (var particle in _particles) {
      particle.update();
      particle.checkBounds(const Size(400, 800));
    }
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CustomPaint(
          size: const Size(400, 800),
          painter: ParticlePainter(particles: _particles),
        ),
      ),
    );
  }
}

class Particle {
  vec.Vector2 position;
  vec.Vector2 velocity;
  vec.Vector2 acceleration;
  final double radius;
  final Color color;

  Particle({
    required this.position,
    required this.velocity,
    required this.acceleration,
    required this.radius,
    required this.color,
  });

  void update() {
    velocity += acceleration;
    position += velocity;

    velocity *= 0.99;
  }

  void checkBounds(Size size) {
    if (position.x - radius < 0 || position.x + radius > size.width) {
      velocity.x *= -1;
    }
    if (position.y - radius < 0 || position.y + radius > size.height) {
      velocity.y *= -1;
    }
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  ParticlePainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (var particle in particles) {
      paint.color = particle.color.withOpacity(0.7);
      canvas.drawCircle(
        Offset(particle.position.x, particle.position.y),
        particle.radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
