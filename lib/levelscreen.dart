import 'package:flutter/material.dart';
import 'package:tic_fun_toc/gamescreen.dart';
import 'package:tic_fun_toc/utils.dart';

class LevelScreen extends StatefulWidget {
  final int level;
  final VoidCallback onPlayNext;
  final bool levelCompleted;

  const LevelScreen({super.key, required this.level, required this.onPlayNext, required this.levelCompleted});

  @override
  State<LevelScreen> createState() => _LevelScreenState();
}

class _LevelScreenState extends State<LevelScreen> {

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context),
      child: Scaffold(
        appBar: AppBar(
          actions: [
            Container(
             
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius:
                    BorderRadius.circular(25), // Adjust the radius as needed
              ),
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 8), // Adjust padding as needed
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
     
                  Image.asset(
                    'assets/images/coin1.png',
                    width: 33,
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Text(
                    gameCoins.toString(),
                    style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'Hello Graduation',
                        fontSize: 25,
                        fontWeight: FontWeight.w200),
                  ),
                ],
              ),
            ),
          ],
          title: Row(
            children: [
              Text('Level ${widget.level}'),
              const SizedBox(width: 5),
              if (widget.levelCompleted) const Icon(Icons.check_circle_sharp,color: Colors.green,),
            ],
          ),
        ),
        body: Center(
          child: TicTacToe(
            level: widget.level,
            onGameEnd: () {
              // Call the callback function when the game ends
              widget.onPlayNext();
            },
            // onValueChanged: updateValue,
          ),
        ),
      ),
    );
  }
}
