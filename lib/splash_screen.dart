import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'homepage.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[100],
      body:  Container(
        color: Colors.brown[100],
        margin: const EdgeInsets.only(top: 50,bottom: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              height: 550,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: DefaultTextStyle(
                    child: AnimatedTextKit(animatedTexts: [
                      WavyAnimatedText("Digit Predictor")
                    ],
                      repeatForever: true,
                      isRepeatingAnimation: true,
                    ),
                    style: const TextStyle(fontSize: 50,color: Colors.brown),
                  ),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              height: 120,
              child: GestureDetector(
                  onTap: () {
                    Get.to(const HomePage());
                  },
                  child: const Center(
                    child:  CircleAvatar(
                      radius: 80,
                      backgroundColor: Colors.brown,
                      child: Icon(Icons.arrow_forward_ios, size: 50,)
                    ),
                  )),
            )
          ],
        ),

      )
    );
  }
}
