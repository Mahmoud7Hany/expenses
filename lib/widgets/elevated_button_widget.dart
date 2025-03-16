// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class ElevatedButtonWidget extends StatefulWidget {
  final Function() onPressed;
  final String buttonText;
  final Color? color;
  final IconData? icon;
  final Function()? onDisabledHint; // إضافة دالة جديدة

  const ElevatedButtonWidget({
    Key? key,
    required this.onPressed,
    required this.buttonText,
    this.color,
    this.icon,
    this.onDisabledHint,
  }) : super(key: key);

  @override
  State<ElevatedButtonWidget> createState() => _ElevatedButtonWidgetState();
}

class _ElevatedButtonWidgetState extends State<ElevatedButtonWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: SizedBox(  // استبدال Container بـ SizedBox
            height: 56,
            child: MaterialButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              onPressed: widget.color == Colors.grey[400] && widget.onDisabledHint != null
                  ? widget.onDisabledHint
                  : widget.onPressed,
              padding: EdgeInsets.zero,
              child: Ink(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: widget.color != null
                        ? [
                            widget.color!,
                            widget.color!.withOpacity(0.8),
                          ]
                        : [
                            Colors.blue[700]!,
                            Colors.blue[500]!,
                          ],
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: (widget.color ?? Colors.blue[700])!.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(
                          widget.icon,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        widget.buttonText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
