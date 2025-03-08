// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class CustomSnackBar {
  static void show({
    required BuildContext context,
    required String message,
    required SnackBarType type,
    bool showTitle = true, // إضافة متغير للتحكم في ظهور العنوان
    Duration duration = const Duration(seconds: 3),
  }) {
    final snackBar = SnackBar(
      content: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(50 * (1 - value), 0),
            child: Opacity(
              opacity: value.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getBackgroundColor(type).withOpacity(0.9),
                      _getBackgroundColor(type),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: _getBackgroundColor(type).withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showTitle) ...[
                      Row(
                        children: [
                          _buildIcon(type),
                          const SizedBox(width: 12),
                          Text(
                            _getTitle(type),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                    ],
                    Text(
                      message,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: showTitle ? 13 : 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      backgroundColor: Colors.transparent,
      behavior: SnackBarBehavior.floating,
      elevation: 0,
      margin: EdgeInsets.all(12),
      padding: EdgeInsets.zero,
      dismissDirection: DismissDirection.horizontal,
      duration: duration,
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  static Widget _buildIcon(SnackBarType type) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 750),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getIcon(type),
              color: Colors.white,
              size: 24,
            ),
          ),
        );
      },
    );
  }

  static IconData _getIcon(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return Icons.check_circle_outlined;
      case SnackBarType.error:
        return Icons.error_outline_rounded;
      case SnackBarType.warning:
        return Icons.warning_amber_rounded;
      case SnackBarType.info:
        return Icons.info_outline_rounded;
    }
  }

  static String _getTitle(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return 'تم';
      case SnackBarType.error:
        return 'خطأ';
      case SnackBarType.warning:
        return 'تنبيه';
      case SnackBarType.info:
        return 'معلومات';
    }
  }

  static Color _getBackgroundColor(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return Color(0xFF2E7D32); // Green 800
      case SnackBarType.error:
        return Color(0xFFC62828); // Red 800
      case SnackBarType.warning:
        return Color(0xFFF57C00); // Orange 800
      case SnackBarType.info:
        return Color(0xFF1565C0); // Blue 800
    }
  }
}

enum SnackBarType {
  success,
  error,
  warning,
  info,
}
