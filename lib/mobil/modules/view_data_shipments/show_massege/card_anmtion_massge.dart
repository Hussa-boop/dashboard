import 'package:flutter/material.dart';

class AnimatedAlertCard extends StatefulWidget {
  final Color backgroundColor;
  final Color textColor;
  final IconData icon;
  final String message;
  final Duration duration;

  const AnimatedAlertCard({
    required this.backgroundColor,
    required this.textColor,
    required this.icon,
    required this.message,
    required this.duration,
    Key? key,
  }) : super(key: key);

  @override
  _AnimatedAlertCardState createState() => _AnimatedAlertCardState();
}

class _AnimatedAlertCardState extends State<AnimatedAlertCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      reverseDuration: const Duration(milliseconds: 250),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();

    // Start reverse animation before the duration ends for smooth exit
    Future.delayed(widget.duration - const Duration(milliseconds: 300), () {
      if (mounted) _controller.reverse();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Card(
          margin: EdgeInsets.zero,
          color: widget.backgroundColor,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(widget.icon, color: widget.textColor, size: 28),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    widget.message,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: widget.textColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: widget.textColor, size: 20),
                  onPressed: () => _controller.reverse(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}