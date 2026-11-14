import 'package:flutter/material.dart';

class BrandMark extends StatelessWidget {
  const BrandMark({this.size = 76, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.28),
        gradient: const LinearGradient(
          colors: [Color(0xFF2467CF), Color(0xFF123B72)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF123B72).withValues(alpha: 0.2),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.school_rounded,
              color: Colors.white.withValues(alpha: 0.15),
              size: size * 0.8,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'SRIT',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: size * 0.24,
                    fontWeight: FontWeight.w800,
                    height: 1,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'PLUS',
                  style: TextStyle(
                    color: const Color(0xFFFFD978),
                    fontSize: size * 0.11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.4,
                    height: 1,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
