import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  final String text;
  final Function()? onPressed;
  final Widget child;

  const Button({super.key,
    required this.text,
    required this.onPressed,
    required this.child,
  });

  @override
  Widget build(BuildContext context) => ElevatedButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      backgroundColor: Colors.blueGrey,
    ).copyWith(overlayColor: MaterialStateProperty.resolveWith<Color?>(
          (Set<MaterialState> states) {
        if (states.contains(MaterialState.pressed)) {
          return Colors.blueGrey[900];
        }
        return null; // Defer to the widget's default.
      },
    )),
    child: child,
  );
}