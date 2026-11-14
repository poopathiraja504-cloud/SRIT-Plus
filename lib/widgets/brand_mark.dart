import 'package:flutter/material.dart';

class BrandMark extends StatelessWidget {
  const BrandMark({this.size = 76, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/srit_logo.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}
