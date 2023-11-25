import 'package:flutter/material.dart';

class ColoredCircle extends StatelessWidget {
  final Color color;
  final double size;

  const ColoredCircle({Key? key, required this.color, this.size = 24.0})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
