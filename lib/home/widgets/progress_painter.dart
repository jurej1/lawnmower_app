// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:math';

import 'package:flutter/material.dart';

class ProgressPainter extends CustomPainter {
  final int index;
  final int fullLength;
  final Color backgroundColor;

  const ProgressPainter({
    required this.backgroundColor,
    required this.index,
    required this.fullLength,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final imageRadius = size.width / 2; // Radius of the image container
    const strokeWidth = 9.0; // Stroke width for the progress circle
    final radius = imageRadius + strokeWidth / 2 + 5; // Adjust radius for the progress circle

    final backgroundPaint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    final progressPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    const startAngle = 3 * pi / 4;

    // Draw the background circle (100%)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      2 * pi - (pi / 2),
      false,
      backgroundPaint,
    );

    // Calculate the angle for the arc based on the index and fullLength
    final sweepAngle = (2 * pi - (pi / 2)) * (index / fullLength);

    // Draw the progress arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // Return true if the new index and fullLength are different from the old
    if (oldDelegate is ProgressPainter) {
      return index != oldDelegate.index || fullLength != oldDelegate.fullLength;
    }
    return false;
  }
}
