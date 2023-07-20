import 'package:flutter/material.dart';
import 'package:pearl_certification/core/navigation/routeKeys.dart';
import 'package:pearl_certification/features/home/home.dart';
import 'package:pearl_certification/features/splash/splash.dart';

Route generateRoute(RouteSettings settings) {
  String routeName = settings.name ?? '';

  switch (routeName) {
    case RouteKeys.splash:
      return MaterialPageRoute(
          settings: settings, builder: (_) => const SplashScreen());

    case RouteKeys.home:
    return MaterialPageRoute(
          settings: settings, builder: (_) => const HomeScreen());

    default:
      return MaterialPageRoute(
          settings: settings,
          builder: (_) => _ErrorScreen(routeName: routeName));
  }}


class _ErrorScreen extends StatelessWidget {
  final String routeName;
  const _ErrorScreen({Key? key, required this.routeName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("Route '$routeName' does not exist"),
      ),
    );
  }
}
