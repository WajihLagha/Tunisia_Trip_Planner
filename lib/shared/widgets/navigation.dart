import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Creates a slide transition route (from right to left).
/// Uses generics so the pushed route can return values of type T.
Route<T> slideRoute<T>(
    Widget page, {
      Duration duration = const Duration(milliseconds: 300),
      Curve curve = Curves.easeOut,
    }) {
  return PageRouteBuilder<T>(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionDuration: duration,
    reverseTransitionDuration: duration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final tween = Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).chain(CurveTween(curve: curve));
      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

/// Push a page with platform-aware animation.
/// Returns the value pushed route may return (if any).
Future<T?> navigateTo<T>(BuildContext context, Widget page) {
  final platform = Theme.of(context).platform;

  if (platform == TargetPlatform.iOS) {
    return Navigator.push<T>(
      context,
      CupertinoPageRoute<T>(builder: (_) => page),
    );
  } else {
    return Navigator.push<T>(context, slideRoute<T>(page));
  }
}

/// Push a page and replace the current one (like pushReplacement) with animation.
/// Useful for flows like splash -> login or login -> home.
Future<T?> navigateAndReplace<T>(BuildContext context, Widget page) {
  final platform = Theme.of(context).platform;

  if (platform == TargetPlatform.iOS) {
    return Navigator.pushReplacement<T, T>(
      context,
      CupertinoPageRoute<T>(builder: (_) => page),
    );
  } else {
    return Navigator.pushReplacement<T, T>(
      context,
      slideRoute<T>(page),
    );
  }
}

/// Push a page and remove all previous routes (clear the stack) with animation.
/// Equivalent to Navigator.pushAndRemoveUntil(..., (route) => false)
Future<T?> navigateAndRemoveAll<T>(BuildContext context, Widget page) {
  final platform = Theme.of(context).platform;

  if (platform == TargetPlatform.iOS) {
    return Navigator.pushAndRemoveUntil<T>(
      context,
      CupertinoPageRoute<T>(builder: (_) => page),
          (Route<dynamic> route) => false,
    );
  } else {
    return Navigator.pushAndRemoveUntil<T>(
      context,
      slideRoute<T>(page),
          (Route<dynamic> route) => false,
    );
  }
}

// // push (same as old navigateTo)
// await navigateToAnimated(context, DetailsScreen());
//
// // replace (same as pushReplacement)
// await navigateAndReplaceAnimated(context, HomeScreen());
//
// // remove all (same as your navigateAndRemove)
// await navigateAndRemoveAllAnimated(context, HomeScreen());
