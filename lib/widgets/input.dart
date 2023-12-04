import 'package:flutter/material.dart';

class Input extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool enabled;
  final bool obscureText;
  final Icon? prefixIcon;
  final FocusNode? focusNode;

  const Input ({super.key,
    required this.hintText,
    required this.controller,
    required this.keyboardType,
    this.prefixIcon,
    this.enabled = true,
    this.obscureText = false,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) => TextFormField(
    enabled: enabled,
    obscureText: obscureText,
    controller: controller,
    keyboardType: keyboardType,
    focusNode: focusNode,
    validator: (value) {
      if (value == null || value.isEmpty) {
        return 'This field is required.';
      }
      return null;
    },
    style: const TextStyle(fontSize: 16.0, color: Colors.black, fontWeight: FontWeight.bold),
    decoration: InputDecoration(
      prefixIcon: prefixIcon,
      hintText: hintText,
      hintStyle: const TextStyle(fontSize: 16.0, color: Colors.blueGrey, fontWeight: FontWeight.bold),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(
          width: 2.0,
          color: Colors.black,
        ),
    ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(
          width: 2.0,
          color: Colors.blueGrey,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(
          width: 2.0,
          color: Colors.black,
        ),
      ),
      filled: true,
      fillColor: Colors.grey[200],
      contentPadding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
  ),
);
}

