import 'dart:math';

import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' as vec;

void main() {
  runApp(const PendulumSimulationApp());
}

class PendulumSimulationApp extends StatelessWidget {
  const PendulumSimulationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
      ),
      home: const PendulumSimulationScreen(),
    );
  }
}

class PendulumSimulationScreen extends StatefulWidget {
  const PendulumSimulationScreen({super.key});

  @override
  State<PendulumSimulationScreen> createState() =>
      _PendulumSimulationScreenState();
}

class _PendulumSimulationScreenState extends State<PendulumSimulationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Pendulum _pendulum;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(_updatePendulum);

    _pendulum = Pendulum(
      origin: vec.Vector2(200, 100),
      length: 200,
      angle: pi / 4,
    );

    _controller.repeat();
  }

  void _updatePendulum() {
    setState(() {
      _pendulum.update();
    });
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
          painter: PendulumPainter(pendulum: _pendulum),
        ),
      ),
    );
  }
}

class Pendulum {
  vec.Vector2 origin;
  vec.Vector2 position;
  double length;
  double angle;
  double angularVelocity;
  double angularAcceleration;
  double damping;

  Pendulum({
    required this.origin,
    required this.length,
    required this.angle,
  })  : angularVelocity = 0.0,
        angularAcceleration = 0.0,
        damping = 0.995,
        position = vec.Vector2.zero() {
    _updatePosition();
  }

  void update() {
    const double gravity = 0.98;

    angularAcceleration = (-1 * gravity / length) * sin(angle);

    angularVelocity += angularAcceleration;
    angularVelocity *= damping;
    angle += angularVelocity;

    _updatePosition();
  }

  void _updatePosition() {
    position = vec.Vector2(
      origin.x + length * sin(angle),
      origin.y + length * cos(angle),
    );
  }
}

class PendulumPainter extends CustomPainter {
  final Pendulum pendulum;

  PendulumPainter({required this.pendulum});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(pendulum.origin.x, pendulum.origin.y),
      Offset(pendulum.position.x, pendulum.position.y),
      paint,
    );

    paint.style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(pendulum.position.x, pendulum.position.y),
      15.0,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
