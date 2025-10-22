import 'package:flutter/material.dart';
import 'page_transitions.dart';

class AppNavigator {
  // Navegación con slide
  static Future<T?> pushSlide<T>(
    BuildContext context,
    Widget page, {
    SlideDirection direction = SlideDirection.right,
  }) {
    return Navigator.push<T>(
      context,
      PageTransitions.slideTransition<T>(page, direction: direction),
    );
  }

  // Navegación con fade
  static Future<T?> pushFade<T>(BuildContext context, Widget page) {
    return Navigator.push<T>(
      context,
      PageTransitions.fadeTransition<T>(page),
    );
  }

  // Navegación con scale
  static Future<T?> pushScale<T>(BuildContext context, Widget page) {
    return Navigator.push<T>(
      context,
      PageTransitions.scaleTransition<T>(page),
    );
  }

  // Navegación modal (desde abajo)
  static Future<T?> pushModal<T>(BuildContext context, Widget page) {
    return Navigator.push<T>(
      context,
      PageTransitions.modalTransition<T>(page),
    );
  }

  // Navegación con shared axis
  static Future<T?> pushSharedAxis<T>(
    BuildContext context,
    Widget page, {
    SharedAxisDirection direction = SharedAxisDirection.horizontal,
  }) {
    return Navigator.push<T>(
      context,
      PageTransitions.sharedAxisTransition<T>(page, direction: direction),
    );
  }

  // Reemplazar con animación
  static Future<T?> pushReplacementSlide<T, TO>(
    BuildContext context,
    Widget page, {
    SlideDirection direction = SlideDirection.right,
    TO? result,
  }) {
    return Navigator.pushReplacement<T, TO>(
      context,
      PageTransitions.slideTransition<T>(page, direction: direction),
      result: result,
    );
  }

  // Navegar y remover todas las anteriores
  static Future<T?> pushAndRemoveUntilSlide<T>(
    BuildContext context,
    Widget page, {
    SlideDirection direction = SlideDirection.right,
  }) {
    return Navigator.pushAndRemoveUntil<T>(
      context,
      PageTransitions.slideTransition<T>(page, direction: direction),
      (route) => false,
    );
  }
}
