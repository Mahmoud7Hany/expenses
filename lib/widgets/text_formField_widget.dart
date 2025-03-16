// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import 'package:flutter/services.dart';

class TextFormFieldWidget extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode; // إضافة FocusNode
  final String labelText;
  final TextInputType keyboardType;
  final Function(String)? onChanged;
  final IconData? prefixIcon;
  final List<TextInputFormatter>? inputFormatters;
  final bool? enabled;
  final TextInputAction? textInputAction; // إضافة جديدة

  const TextFormFieldWidget({
    Key? key,
    required this.controller,
    this.focusNode, // إضافة FocusNode
    required this.labelText,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.prefixIcon,
    this.inputFormatters,
    this.enabled,
    this.textInputAction, // إضافة للكونستركتور
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: themeProvider.isDarkMode 
                ? Colors.black.withOpacity(0.2)
                : Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode, // إضافة FocusNode
        keyboardType: keyboardType,
        onChanged: onChanged,
        inputFormatters: inputFormatters,
        enabled: enabled,
        textInputAction: textInputAction, // إضافة الخاصية الجديدة
        // إضافة معالج للتركيز
        onTap: () {
          if (focusNode != null) {
            focusNode!.requestFocus();
          }
        },
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
        ),
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(
            color: themeProvider.isDarkMode ? Colors.grey[400] : Colors.grey[600],
            fontSize: 14,
          ),
          prefixIcon: prefixIcon != null
              ? Icon(
                  prefixIcon,
                  color: themeProvider.isDarkMode ? Colors.blue[400] : Colors.blue[700],
                )
              : null,
          filled: true,
          fillColor: themeProvider.isDarkMode ? Color(0xFF2D2D2D) : Colors.grey[50],
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(
              color: themeProvider.isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(
              color: themeProvider.isDarkMode ? Colors.blue[400]! : Colors.blue[700]!,
              width: 1.5,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(
              color: Colors.red[300]!,
              width: 1.5,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(
              color: Colors.red[700]!,
              width: 1.5,
            ),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }
}
