import 'dart:math' as math;
import 'package:flutter/material.dart';

class LiquidBackground extends StatefulWidget {
  final Widget child;
  const LiquidBackground({super.key, required this.child});

  @override
  State<LiquidBackground> createState() => _LiquidBackgroundState();
}

class _LiquidBackgroundState extends State<LiquidBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.primaryColor;
    final secondary = theme.colorScheme.secondary;

    return Stack(
      children: [
        // Base background
        Container(color: theme.scaffoldBackgroundColor),

        // Animated Blobs
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Stack(
              children: [
                _Blob(
                  color: primary.withOpacity(0.2),
                  size: 400,
                  offset: Offset(
                    math.sin(_controller.value * 2 * math.pi) * 50,
                    math.cos(_controller.value * 2 * math.pi) * 50 - 100,
                  ),
                ),
                _Blob(
                  color: secondary.withOpacity(0.15),
                  size: 350,
                  offset: Offset(
                    math.cos(_controller.value * 2 * math.pi + 1) * 60 + 200,
                    math.sin(_controller.value * 2 * math.pi + 1) * 60 + 300,
                  ),
                ),
                _Blob(
                  color: primary.withOpacity(0.1),
                  size: 300,
                  offset: Offset(
                    math.sin(_controller.value * 2 * math.pi + 2) * 40 - 100,
                    math.cos(_controller.value * 2 * math.pi + 2) * 40 + 500,
                  ),
                ),
              ],
            );
          },
        ),

        // Blur layer for the mesh effect
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white24, Colors.white12],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),

        // The actual content
        widget.child,
      ],
    );
  }
}

class _Blob extends StatelessWidget {
  final Color color;
  final double size;
  final Offset offset;

  const _Blob({required this.color, required this.size, required this.offset});

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: offset,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}
