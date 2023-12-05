import 'package:flutter/material.dart';

class Tile extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const Tile({
    super.key,
    required this.title,
    required this.onTap
  });


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Center(
            child: Text(title, style: const TextStyle(fontSize: 18.0, color: Colors.blueGrey)) ,
          ),
        ),
      ),
    );
  }
}
