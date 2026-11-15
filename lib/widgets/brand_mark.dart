import 'package:flutter/material.dart';

const sritInstitutionName = 'Sri Ramakrishna Institute of Technology';
const sritInstitutionAddress =
    'Pachapalayam (Post), Perur Chettipalayam, '
    'Coimbatore - 641 010, INDIA';

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

class InstitutionBranding extends StatelessWidget {
  const InstitutionBranding({
    this.logoSize = 56,
    this.textColor,
    this.compact = false,
    super.key,
  });

  final double logoSize;
  final Color? textColor;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final color = textColor ?? Theme.of(context).colorScheme.onSurface;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        BrandMark(size: logoSize),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'SRIT PORTAL',
                style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                sritInstitutionName,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  height: 1.25,
                ),
              ),
              if (!compact) ...[
                const SizedBox(height: 2),
                Text(
                  sritInstitutionAddress,
                  style: TextStyle(
                    color: color.withValues(alpha: 0.8),
                    fontSize: 10,
                    height: 1.25,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
