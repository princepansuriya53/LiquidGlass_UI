import 'dart:math';
import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    home: MyGlassWidget(),
    theme: ThemeData.light(),
    title: 'Liquid Glass Draggable Jelly',
    debugShowCheckedModeBanner: false,
  );
}

class MyGlassWidget extends StatefulWidget {
  const MyGlassWidget({super.key});
  @override
  MyGlassWidgetState createState() => MyGlassWidgetState();
}

class MyGlassWidgetState extends State<MyGlassWidget>
    with SingleTickerProviderStateMixin {
  Offset position = Offset.zero;

  /// Controller for our “jelly” wobble
  late final AnimationController jellyController;

  @override
  void initState() {
    super.initState();
    jellyController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    jellyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // center it initially
    if (position == Offset.zero) {
      final s = MediaQuery.of(context).size;
      position = Offset((s.width - 200) / 2, (s.height - 200) / 2);
    }

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              'https://images.pexels.com/photos/13750357/pexels-photo-13750357.jpeg',
              fit: BoxFit.cover,
            ),
          ),

          AnimatedBuilder(
            animation: jellyController,
            builder: (context, child) {
              final wobble = sin(jellyController.value * 2 * pi);
              final scaleX = 1 + 0.05 * wobble;
              final scaleY = 1 - 0.05 * wobble;
              return Positioned(
                left: position.dx,
                top: position.dy,
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.diagonal3Values(scaleX, scaleY, 1),
                  child: child,
                ),
              );
            },
            child: GestureDetector(
              onPanStart: (_) {
                jellyController.repeat();
              },
              onPanUpdate: (details) {
                setState(() {
                  position += details.delta;
                });
              },
              onPanEnd: (_) {
                // let the jelly wobble for a bit after release
                Future.delayed(const Duration(milliseconds: 300), () {
                  if (mounted) {
                    jellyController.stop();
                    jellyController.value = 0;
                  }
                });
              },
              onPanCancel: () {
                Future.delayed(const Duration(milliseconds: 300), () {
                  if (mounted) {
                    jellyController.stop();
                    jellyController.value = 0;
                  }
                });
              },
              child: LiquidGlass(
                blur: 4,
                settings: const LiquidGlassSettings(lightAngle: 7),
                shape: LiquidRoundedSuperellipse(
                  borderRadius: Radius.circular(50),
                ),
                child: const SizedBox(
                  width: 200,
                  height: 200,
                  child: Center(child: FlutterLogo(size: 100)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
