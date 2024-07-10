import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:tic_fun_toc/utils.dart';

class StartPageScreen extends StatefulWidget {
  const StartPageScreen({super.key});

  @override
  State<StartPageScreen> createState() => _StartPageScreenState();
}

class _StartPageScreenState extends State<StartPageScreen> {
  @override
  void initState() {
    super.initState();
    initpref(context);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedTextKit(
        animatedTexts: [
          TyperAnimatedText(
            'Loading...',
            textStyle: TextStyle(
              fontFamily: 'Hello Graduation',
              fontSize: 50,
              color: const Color.fromARGB(255, 153, 74, 74),
            ),
            speed: Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}
