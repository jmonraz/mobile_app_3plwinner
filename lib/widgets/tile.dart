import 'package:flutter/material.dart';

class Tile extends StatelessWidget {
  final String title;

  const Tile({
    super.key,
    required this.title
  });


  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
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
          child: Text(title),
        ),
      ),
    );
  }
}
