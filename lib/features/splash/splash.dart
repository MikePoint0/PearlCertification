import 'package:flutter/material.dart';
import 'package:pearl_certification/core/navigation/routeKeys.dart';
import 'package:pearl_certification/core/utils/images.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 3), () {
      //change to home page
      Navigator.of(context).pushReplacementNamed(RouteKeys.home);
    });
    return Scaffold(
      body: Center(
        child: Image.asset(
          AppAssets.splash,
          fit: BoxFit.fitWidth,
        ),
      ),
    );
  }
}
