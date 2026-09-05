import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/modules/splash/splash_controller.dart';
import 'package:aub_connect_app/modules/splash/widgets/splash_background.dart';
import 'package:aub_connect_app/modules/splash/widgets/splash_brand_title.dart';

class SplashScreen extends GetView<SplashController> {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure SplashController is created so bootstrap runs.
    controller;

    return const PopScope(
      canPop: false,
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            SplashBackground(),
            Center(child: SplashLogo()),
            Positioned(
              left: 0,
              right: 0,
              bottom: 40,
              child: SafeArea(
                child: Center(child: SplashBrandTitle()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
