import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' as vec;

void main() {
  runApp(const BouncingBallsApp());
}

class BouncingBallsApp extends StatelessWidget {
  const BouncingBallsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: BouncingBallsScreen(),
    );
  }
}

class BouncingBallsScreen extends StatefulWidget {
  const BouncingBallsScreen({super.key});

  @override
  State<BouncingBallsScreen> createState() => _BouncingBallsScreenState();
}

class _BouncingBallsScreenState extends State<BouncingBallsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<Ball> _balls = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16), // ~60 FPS
    )..addListener(_updateBalls);

    _initializeBalls();

    _controller.repeat();
  }

  void _initializeBalls() {
    for (int i = 0; i < 5; i++) {
      _balls.add(Ball(
        position: vec.Vector2(
          _random.nextDouble() * 400,
          _random.nextDouble() * 700,
        ),
        velocity: vec.Vector2(
          _random.nextDouble() * 2 - 1,
          _random.nextDouble() * 2 - 1,
        ),
        radius: _random.nextDouble() * 20 + 10,
        color: Color.fromARGB(
          255,
          _random.nextInt(256),
          _random.nextInt(256),
          _random.nextInt(256),
        ),
      ));
    }
  }

  void _updateBalls() {
    setState(() {
      for (var ball in _balls) {
        ball.update();
        _handleWallCollisions(ball);
      }
      _handleBallCollisions();
    });
  }

  void _handleWallCollisions(Ball ball) {
    if (ball.position.x <= ball.radius ||
        ball.position.x >= 400 - ball.radius) {
      ball.velocity.x *= -1;
    }

    if (ball.position.y <= ball.radius ||
        ball.position.y >= 800 - ball.radius) {
      ball.velocity.y *= -1;
    }
  }

  void _handleBallCollisions() {
    for (int i = 0; i < _balls.length; i++) {
      for (int j = i + 1; j < _balls.length; j++) {
        var ballA = _balls[i];
        var ballB = _balls[j];
        var distance = ballA.position.distanceTo(ballB.position);
        if (distance < ballA.radius + ballB.radius) {
          _resolveCollision(ballA, ballB);
        }
      }
    }
  }

  void _resolveCollision(Ball ballA, Ball ballB) {
    vec.Vector2 collisionNormal = (ballB.position - ballA.position).normalized();
    vec.Vector2 relativeVelocity = ballA.velocity - ballB.velocity;

    double velocityAlongNormal = relativeVelocity.dot(collisionNormal);
    if (velocityAlongNormal > 0) return;

    double restitution = 1.0; // Elastic collision
    double impulseMagnitude =
        -(1 + restitution) * velocityAlongNormal / (1 / ballA.radius + 1 / ballB.radius);

    vec.Vector2 impulse = collisionNormal * impulseMagnitude;
    ballA.velocity += impulse / ballA.radius;
    ballB.velocity -= impulse / ballB.radius;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTapDown: (details) {
          setState(() {
            _balls.add(Ball(
              position: vec.Vector2(details.localPosition.dx, details.localPosition.dy),
              velocity: vec.Vector2(_random.nextDouble() * 2 - 1, _random.nextDouble() * 2 - 1),
              radius: _random.nextDouble() * 20 + 10,
              color: Color.fromARGB(
                255,
                _random.nextInt(256),
                _random.nextInt(256),
                _random.nextInt(256),
              ),
            ));
          });
        },
        onPanUpdate: (details) {
          for (var ball in _balls) {
            if ((ball.position - vec.Vector2(details.localPosition.dx, details.localPosition.dy))
                .length <
                ball.radius) {
              setState(() {
                ball.position = vec.Vector2(details.localPosition.dx, details.localPosition.dy);
              });
            }
          }
        },
        child: Center(
          child: CustomPaint(
            size: const Size(400, 800),
            painter: BallPainter(balls: _balls),
          ),
        ),
      ),
    );
  }
}

class Ball {
  vec.Vector2 position;
  vec.Vector2 velocity;
  double radius;
  Color color;
  static const double gravity = 0.05;
  static const double damping = 0.99; // To simulate air resistance

  Ball({
    required this.position,
    required this.velocity,
    required this.radius,
    required this.color,
  });

  void update() {
    velocity.y += gravity; // Apply gravity
    velocity *= damping; // Apply damping
    position += velocity; // Update position
  }
}

class BallPainter extends CustomPainter {
  final List<Ball> balls;

  BallPainter({required this.balls});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (var ball in balls) {
      paint.color = ball.color;
      canvas.drawCircle(
        Offset(ball.position.x, ball.position.y),
        ball.radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant oldDelegate) => true; }
