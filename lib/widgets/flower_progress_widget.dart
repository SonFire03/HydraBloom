import 'package:flutter/material.dart';

class FlowerProgressWidget extends StatefulWidget {
  const FlowerProgressWidget({super.key, required this.progress});

  final double progress;

  @override
  State<FlowerProgressWidget> createState() => _FlowerProgressWidgetState();
}

class _FlowerProgressWidgetState extends State<FlowerProgressWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = 0.92 + (widget.progress * 0.28);
    final imagePath = widget.progress >= 1
        ? 'photo/Néréabelle.png'
        : widget.progress >= 0.5
            ? 'photo/Florali.png'
            : 'photo/Goutili.png';

    final message = widget.progress >= 1 ? 'Objectif valide !' : 'Bravo, continue !';

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 420),
      tween: Tween(begin: 0.9, end: scale),
      curve: Curves.easeOutBack,
      builder: (context, value, _) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: 230,
            height: 210,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              gradient: const LinearGradient(
                colors: [Color(0xFFFFE7F0), Color(0xFFE8DEFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFF08CB4).withOpacity(0.25),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final t = _controller.value;
                final bob = (t - 0.5) * 10;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Transform.translate(
                      offset: Offset(0, bob),
                      child: Image.asset(
                        imagePath,
                        width: 120,
                        height: 120,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      message,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}
