import 'package:flutter/material.dart';
import './Widget/login.dart';
import './Widget/table.dart';
import './Widget/setting.dart';
import 'package:animations/animations.dart';

void main() {
  Map<String, Widget> routesMap = {
    '/login': LoginPage(),
    '/table': CourseTable(),
    '/setting': Setting()
  };
  runApp(
    MaterialApp(
      title: 'NTOU Course Notification',
      // Start the app with the "/" named route. In this case, the app starts
      // on the FirstScreen widget.
      initialRoute: '/login',
      onGenerateRoute: (settings) {
        return PageRouteBuilder(
          settings: settings,
          transitionDuration: Duration(milliseconds: 500),
          reverseTransitionDuration: Duration(milliseconds: 500),
          pageBuilder: (context, animation, secondaryAnimation) =>
              routesMap[settings.name]!,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeThroughTransition(
              fillColor: Theme.of(context).scaffoldBackgroundColor,
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              child: child,
            );
          },
        );
      },
    ),
  );
}
