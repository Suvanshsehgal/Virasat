import 'package:flutter/material.dart';

class AppAnimations {
  AppAnimations._();

  // Durations
  static const Duration duration300 = Duration(milliseconds: 300);
  static const Duration duration800 = Duration(milliseconds: 800);
  static const Duration stagger60 = Duration(milliseconds: 60);

  // Standard entry: fade + slide up
  static const Curve entryCurve = Curves.easeOutCubic;

  // Spring bounce for buttons, cards, sheets
  static const SpringDescription springBouncy = SpringDescription(
    mass: 1.0,
    stiffness: 300,
    damping: 20,
  );

  static const SpringDescription springGentle = SpringDescription(
    mass: 1.0,
    stiffness: 200,
    damping: 25,
  );

  // Confidence bar spring
  static const SpringDescription confidenceSpring = SpringDescription(
    mass: 1.0,
    stiffness: 150,
    damping: 15,
  );

  // Scale values
  static const double cardPressScale = 0.97;
  static const double cardNormalScale = 1.0;

  // Slide offset for entry
  static const Offset entrySlideOffset = Offset(0, 20);

  // Tab bounce offset
  static const double tabBounceOffset = -4.0;
}
