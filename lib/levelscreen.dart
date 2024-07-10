import 'package:flutter/material.dart';
import 'package:tic_fun_toc/gamescreen.dart';

class LevelScreen extends StatelessWidget {
  final int level;
  final VoidCallback onPlayNext;

  LevelScreen({required this.level, required this.onPlayNext});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Level $level'),
        ),
        body: Center(
          child: TicTacToe(
            level: level,
            onGameEnd: () {
              // Call the callback function when the game ends
              onPlayNext();
            },
          ),
        ),
      ),
    );
  }
}