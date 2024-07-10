import 'dart:math';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tic_fun_toc/ad_helper.dart';
import 'package:tic_fun_toc/utils.dart';

class TicTacToe extends StatefulWidget {
  final int level;
  final VoidCallback onGameEnd;

  TicTacToe({required this.level, required this.onGameEnd});

  @override
  _TicTacToeState createState() => _TicTacToeState();
}

class _TicTacToeState extends State<TicTacToe> {
  List<String> board = List.filled(9, '');
  bool playerTurn = true; // true for player X, false for player O
  late RewardedAd rewardedAd;
  bool gameEnded = false;
  late BannerAd bannerAd;
  bool isLoaded = false;
  bool moveMade = false; // Tracks if a move has been made in the current turn
  bool canTap = true; // Flag to control whether tapping is enabled

  @override
  void initState() {
    super.initState();
    initRewardAd();
    initbannerAd();
  }

  initRewardAd() {
    RewardedAd.load(
      adUnitId: AdHelper.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        // Called when an ad is successfully received.
        onAdLoaded: (ad) {
          debugPrint('$ad loaded.');
          // Keep a reference to the ad so you can show it later.
          rewardedAd = ad;
        },
        // Called when an ad request failed.
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('RewardedAd failed to load: $error');
        },
      ),
    );
  }

  initbannerAd() {
    bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: AdHelper.bannerAdUnitId,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            isLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          print(error.code);
          print(error.domain);
          print(error.message);
          ad.dispose();
          print('error');
        },
      ),
      request: const AdRequest(),
    );

    bannerAd.load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GridView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(20.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                  ),
                  itemCount: 9,
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () {
                        // Check if tapping is allowed
                        if (!canTap) {
                          return; // If tapping is disabled, return without processing the move
                        }
                        FlameAudio.play('button.mp3');
                        if (!gameEnded && board[index] == '' && !moveMade) {
                          setState(() {
                            // Only allow move if it's the correct player's turn
                            if (playerTurn && board[index] == '') {
                              board[index] = 'X';
                            } else if (!playerTurn && board[index] == '') {
                              board[index] = 'O';
                            }

                            // Check for winner or draw
                            if (checkWinner(board, 'X')) {
                              gameEnded = true;
                              showDialogAndReset(
                                  'Congratulations!', 'Player X wins!');
                            } else if (checkWinner(board, 'O')) {
                              gameEnded = true;
                              showDialogAndReset('Oops!', 'Player O wins!');
                            } else if (!board.contains('')) {
                              gameEnded = true;
                              showDialogAndReset(
                                  'It\'s a draw!', 'No one wins.');
                            } else {
                              // Switch turn only if there was a valid move
                              if (board[index] != '') {
                                playerTurn = !playerTurn;
                                if (!playerTurn) {
                                  aiMove(); // AI's move
                                }
                                canTap = false; // Disable tapping temporarily
                                moveMade = true;
                              }
                            }
                          });
                          // Reset moveMade flag after each turn
                          if (!playerTurn) {
                            moveMade = false;
                          }
                          // Delay before re-enabling tapping
                          Future.delayed(Duration(milliseconds: 500), () {
                            setState(() {
                              canTap = true; // Enable tapping after the delay
                            });
                          });
                        }
                      },
                      child: Container(
                        color: Colors.blue[300],
                        child: Center(
                          child: Text(
                            board[index],
                            style: TextStyle(
                              fontFamily: 'Hello Graduation',
                              fontSize: 60,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 20),
                if (!gameEnded)
                  Text(
                    playerTurn ? 'Player X\'s Turn' : 'Player O\'s Turn',
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'Hello Graduation',
                    ),
                  ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: isLoaded
            ? SizedBox(
                height: bannerAd.size.height.toDouble(),
                width: bannerAd.size.width.toDouble(),
                child: AdWidget(ad: bannerAd),
              )
            : const SizedBox());
  }

  bool checkWinner(List<String> board, String player) {
    // Check rows
    for (int i = 0; i < 3; i++) {
      if (board[i * 3] == player &&
          board[i * 3 + 1] == player &&
          board[i * 3 + 2] == player) {
        return true;
      }
    }
    // Check columns
    for (int i = 0; i < 3; i++) {
      if (board[i] == player &&
          board[i + 3] == player &&
          board[i + 6] == player) {
        return true;
      }
    }
    // Check diagonals
    if (board[0] == player && board[4] == player && board[8] == player) {
      return true;
    }
    if (board[2] == player && board[4] == player && board[6] == player) {
      return true;
    }
    return false;
  }

  void resetGame() {
    setState(() {
      board = List.filled(9, '');
      playerTurn = true;
      gameEnded = false;
      moveMade = false; // Reset moveMade flag
    });
  }

  void showDialogAndReset(String title, String content) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print(content);
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) => PopScope(
        canPop: false,
        child: AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            if (content.contains('Player O wins'))
              TextButton(
                onPressed: () async {
                  FlameAudio.play('button.mp3');

                  // Check if Player O wins for the first time
                  bool isFirstTimeWinning =
                      prefs.getBool('player-o-wins${widget.level}') ?? true;
                  await rewardedAd.show(
                    onUserEarnedReward: (ad, reward) {
                      print('Display Ad');
                    },
                    // Deduct coins only if it's the first time Player O wins
                  );
                  if (isFirstTimeWinning) {
                    await decreaseGameCoin(
                        50); // Deduct 50 coins if Player O wins
                    // Mark Player O as won to prevent future deductions
                    prefs.setBool('player-o-wins${widget.level}', false);
                  } // Deduct 50 coins if the player loses
                  resetGame();
                  Navigator.pop(context);
                },
                child: Text('Play Again'),
              )
            else if (content.contains('No one wins'))
              TextButton(
                onPressed: () async {
                  FlameAudio.play('button.mp3');

                  // Check if Player O wins for the first time
                  bool isFirstTimeWinning =
                      prefs.getBool('No one wins${widget.level}') ?? true;
                  await rewardedAd.show(
                    onUserEarnedReward: (ad, reward) {
                      print('Display Ad');
                    },
                  );
                  if (isFirstTimeWinning) {
                    // Deduct coins only if it's the first time Player O wins
                    await decreaseGameCoin(
                        20); // Deduct 50 coins if Player O wins
                    // Mark Player O as won to prevent future deductions
                    prefs.setBool('No one wins${widget.level}', false);
                  }
                  resetGame();
                  Navigator.pop(context);
                },
                child: Text('Play Again'),
              )
            else
              TextButton(
                onPressed: () async {
                  FlameAudio.play('button.mp3');
                  // Check if the level is being played for the first time
                  bool isFirstTimePlaying =
                      prefs.getBool('level-${widget.level}-played') ?? true;
                  rewardedAd.show(
                    onUserEarnedReward: (ad, reward) {
                      print('Display Ad');
                    },
                  );
                  if (isFirstTimePlaying) {
                    // Show reward ad and credit coins only if it's the first time playing the level
                    increaseGameCoin(100);
                    // Mark the level as played
                    prefs.setBool('level-${widget.level}-played', false);
                  }

                  // Lock the first level when moving to the second level
                  prefs.setBool('level-${widget.level + 1}-unlocked', true);
                  // prefs.setBool('level-1-unlocked', false);
                  // prefs.setBool('level-${widget.level}-unlocked', false);

                  widget.onGameEnd(); // Call the callback function
                  // Navigator.pop(context);
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: Text('Play Next'),
              ),
          ],
        ),
      ),
    );
  }

  void aiMove() {
    Future.delayed(const Duration(milliseconds: 400), () {
      if (!gameEnded) {
        setState(() {
          int bestMove = findBestMove(board, 'O', widget.level);
          board[bestMove] = 'O'; // Set the AI's move as 'O'
          if (checkWinner(board, 'O')) {
            gameEnded = true;
            showDialogAndReset('Oops!', 'Player O wins!');
          } else if (board.every((square) => square != '')) {
            gameEnded = true;
            showDialogAndReset('It\'s a draw!', 'No one wins.');
          } else {
            playerTurn =
                true; // Change the turn back to the player after the AI's move
          }
        });
      }
    });
  }

  int findBestMove(List<String> board, String player, int level) {
    List<int> availableMoves = [];
    for (int i = 0; i < board.length; i++) {
      if (board[i] == '') {
        availableMoves.add(i);
      }
    }

    if (availableMoves.isNotEmpty) {
      if (level <= 12) {
        // Levels 1-12: Easy difficulty, AI makes random moves
        return availableMoves[Random().nextInt(availableMoves.length)];
      } else if (level <= 22) {
        // Levels 13-22: Medium difficulty, AI makes slightly smarter moves
        return mediumDifficultyMove(board, availableMoves, player);
      } else {
        // Levels 23-32: Hard difficulty, AI makes optimal moves
        // return hardDifficultyMove(board, player);
        return mediumDifficultyMove(board, availableMoves, player);
      }
    } else {
      // No available moves
      return -1;
    }
  }

  int mediumDifficultyMove(
      List<String> board, List<int> availableMoves, String player) {
    // If there's a winning move, take it
    for (int move in availableMoves) {
      List<String> testBoard = List.from(board);
      testBoard[move] = player;
      if (checkWinner(testBoard, player)) {
        return move;
      }
    }

    // If there's a winning move for the opponent, block it
    String opponent = player == 'X' ? 'O' : 'X';
    for (int move in availableMoves) {
      List<String> testBoard = List.from(board);
      testBoard[move] = opponent;
      if (checkWinner(testBoard, opponent)) {
        return move;
      }
    }

    // Otherwise, make a random move
    return availableMoves[Random().nextInt(availableMoves.length)];
  }

  // int hardDifficultyMove(List<String> board, String player) {
  //   int bestScore = -1000;
  //   int bestMove = -1;

  //   for (int i = 0; i < board.length; i++) {
  //     if (board[i] == '') {
  //       List<String> testBoard = List.from(board);
  //       testBoard[i] = player;
  //       int score = minimax(testBoard, 0, false, player == 'X' ? 'O' : 'X');
  //       if (score > bestScore) {
  //         bestScore = score;
  //         bestMove = i;
  //       }
  //     }
  //   }

  //   return bestMove;
  // }

  // int minimax(List<String> board, int depth, bool isMaximizing, String player) {
  //   String opponent = player == 'X' ? 'O' : 'X';

  //   // Check if the game has reached a terminal state
  //   if (checkWinner(board, player)) {
  //     return 10 - depth; // Give higher score for winning earlier
  //   } else if (checkWinner(board, opponent)) {
  //     return depth - 10; // Give lower score for losing earlier
  //   } else if (!board.contains('')) {
  //     return 0; // It's a draw
  //   }

  //   // If it's the maximizing player's turn (AI)
  //   if (isMaximizing) {
  //     int bestScore = -1000;
  //     for (int i = 0; i < board.length; i++) {
  //       if (board[i] == '') {
  //         List<String> testBoard = List.from(board);
  //         testBoard[i] = player;
  //         int score = minimax(testBoard, depth + 1, false, player);
  //         bestScore = max(score, bestScore); // Update the best score
  //       }
  //     }
  //     return bestScore;
  //   } else {
  //     // If it's the minimizing player's turn (Opponent)
  //     int bestScore = 1000;
  //     for (int i = 0; i < board.length; i++) {
  //       if (board[i] == '') {
  //         List<String> testBoard = List.from(board);
  //         testBoard[i] = opponent;
  //         int score = minimax(testBoard, depth + 1, true, player);
  //         bestScore = min(score, bestScore); // Update the best score
  //       }
  //     }
  //     return bestScore;
  //   }
  // }
}
