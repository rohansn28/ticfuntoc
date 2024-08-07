import 'dart:convert';
import 'dart:math';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tic_fun_toc/ad_helper.dart';
import 'package:tic_fun_toc/controllers/launch_custom_tab.dart';
import 'package:tic_fun_toc/utils.dart';
import 'package:http/http.dart' as http;

class TicTacToe extends StatefulWidget {
  final int level;
  final VoidCallback onGameEnd;

  const TicTacToe({
    super.key,
    required this.level,
    required this.onGameEnd,
  });

  @override
  _TicTacToeState createState() => _TicTacToeState();
}

class _TicTacToeState extends State<TicTacToe> {
  List<String> board = List.filled(9, '');
  bool playerTurn = true; // true for player X, false for player O
  bool gameEnded = false;
  bool isLoaded = false;
  bool isBannerLoaded = false;
  bool moveMade = false; // Tracks if a move has been made in the current turn
  bool canTap = true; // Flag to control whether tapping is enabled
  RewardedAd? rewardedAd;
  // InterstitialAd? interstitialAd;
  BannerAd? bannerAd;
  int levelPlayed = 0;
  bool hintUnlocked = false;
  bool adMob = false;
  int adCount = 0;
  String userId = "";

  @override
  void initState() {
    initRewardAd();
    initbannerAd();
    // initIntrestialAd();
    initPrefs();
    super.initState();
  }

  Future<void> _updateCoins(int earnedCoins) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');

    if (userId != null) {
      final response = await http.post(
        Uri.parse(
            'https://loungecard.website/linebucks/public/api/update-coins-tft'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'user_id': userId,
          'coins': earnedCoins,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update coins');
      }
    }
  }

  void _onEarnCoins(int earnedCoins) {
    _updateCoins(earnedCoins);
  }

  Future<void> updateLevelPlayed(int levelPlayed) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');

    if (userId != null) {
      final response = await http.post(
        Uri.parse(
            'https://loungecard.website/linebucks/public/api/update-level-played'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'user_id': userId,
          'lvl_1_played': levelPlayed,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update level played');
      }
    }
  }

  Future<void> countAd() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('adCount')) {
      setState(() {
        adCount = prefs.getInt('adCount')!;
      });
    }
  }

  Future<void> initPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      userId = prefs.getString('user_id')!;
      levelPlayed = (prefs.getInt('level ${widget.level} played') ?? 0);
      adMob = (prefs.getBool('level ${widget.level} adMob') ?? false);
    });
  }

  // Increment the counter value and save it to SharedPreferences
  _incrementCounter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      levelPlayed = (prefs.getInt('level ${widget.level} played') ?? 0) + 1;
      prefs.setInt('level ${widget.level} played', levelPlayed);
      updateLevelPlayed(levelPlayed);
    });
  }

  _setAdMob() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      adMob = !(prefs.getBool('level ${widget.level} adMob') ?? false);
      prefs.setBool('level ${widget.level} adMob', adMob);
    });
  }

  initRewardAd() {
    RewardedAd.load(
      adUnitId: AdHelper.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        // Called when an ad is successfully received.
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = const FullScreenContentCallback();
          // debugPrint('$ad loaded.');
          // Keep a reference to the ad so you can show it later.
          setState(() {
            rewardedAd = ad;
          });
        },
        // Called when an ad request failed.
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('RewardedAd failed to load: $error');
        },
      ),
    );
  }

  initbannerAd() {
    try {
      bannerAd = BannerAd(
        size: AdSize.banner,
        adUnitId: AdHelper.bannerAdUnitId,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            setState(() {
              isBannerLoaded = true;
            });
          },
          onAdFailedToLoad: (ad, error) {
            ad.dispose();
          },
        ),
      );
      bannerAd!.load();
    } catch (e) {
      bannerAd = null;
    }
  }

  // initIntrestialAd() {
  //   InterstitialAd.load(
  //       adUnitId: AdHelper.interstitialAdUnitId,
  //       request: AdRequest(),
  //       adLoadCallback: InterstitialAdLoadCallback(
  //         onAdLoaded: (ad) {
  //           ad.fullScreenContentCallback = const FullScreenContentCallback();
  //           // print('$ad Loaded ');
  //           setState(() {
  //             isLoaded = true;
  //             interstitialAd = ad;
  //           });
  //         },
  //         onAdFailedToLoad: (LoadAdError error) {
  //           print('InterstitialAd failed to load: $error');
  //         },
  //       ));
  // }

  @override
  void dispose() {
    bannerAd!.dispose();
    isBannerLoaded = false;
    isLoaded = false;
    if (rewardedAd != null) {
      rewardedAd!.dispose();
    }
    // interstitialAd!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(
                          20), // Adjust the radius as needed
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8), // Adjust padding as needed
                    child: Text(
                      textAlign: TextAlign.center,
                      'User Id: $userId',
                      style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'Hello Graduation',
                          fontSize: 16,
                          fontWeight: FontWeight.w200),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.7,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(
                          25), // Adjust the radius as needed
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8), // Adjust padding as needed
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Game Played :',
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Hello Graduation',
                              fontSize: 25,
                              fontWeight: FontWeight.w200),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Container(
                          width: 50,
                          height: 50,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: Center(
                            child: Text(
                              '$levelPlayed',
                              style: const TextStyle(
                                color: Colors.black,
                                fontFamily: 'Hello Graduation',
                                fontSize: 20,
                                fontWeight: FontWeight.w200,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Text('Game Played $levelPlayed'),

                  GridView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(20.0),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
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
                                // widget.onValueChanged(true);
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
                            Future.delayed(const Duration(milliseconds: 500),
                                () {
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
                              style: const TextStyle(
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
                  const SizedBox(height: 20),
                  if (!gameEnded)
                    Text(
                      playerTurn ? 'Player X\'s Turn' : 'Player O\'s Turn',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontFamily: 'Hello Graduation',
                      ),
                    ),
                  const SizedBox(height: 20),
                  Container(
                    width: 200,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      style: const ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(Colors.blue)),
                      onPressed: () async {
                        await countAd();
                        if (adCount == 5) {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Hint Unlocked'),
                              content: Text(hintContent),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                        } else {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Hint Locked'),
                              content: Text(
                                  'Watch ${5 - adCount} ads to unlock hint.'),
                              actions: [
                                TextButton(
                                  onPressed: () async {
                                    Navigator.pushNamed(
                                      context,
                                      '/tracking',
                                      arguments: {
                                        "link": adUrl,
                                        "adCountTemp": adCount.toString(),
                                        "seconds": "10"
                                      },
                                    );
                                  },
                                  child: const Text('Watch Ad'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                      child: const Center(
                        child: Text(
                          'Hint',
                          style: TextStyle(
                            fontFamily: 'Hello Graduation',
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: isBannerLoaded && bannerAd != null
              ? SizedBox(
                  height: bannerAd!.size.height.toDouble(),
                  width: bannerAd!.size.width.toDouble(),
                  child: AdWidget(ad: bannerAd!))
              : const SizedBox()),
    );
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

                  // _incrementCounter();

                  // Check if Player O wins for the first time
                  bool isFirstTimeWinning =
                      prefs.getBool('player-o-wins${widget.level}') ?? true;

                  // unityPlacements[AdManager.interstitialVideoAdPlacementId] ==
                  //     true;
                  // showUnityAd(AdManager.interstitialVideoAdPlacementId);

                  if (isFirstTimeWinning) {
                    // await decreaseGameCoin(
                    //     50); // Deduct 50 coins if Player O wins
                    // Mark Player O as won to prevent future deductions
                    prefs.setBool('player-o-wins${widget.level}', false);
                  } // Deduct 50 coins if the player loses

                  if (adMob) {
                    await rewardedAd!.show(
                      onUserEarnedReward: (ad, reward) {
                        print('ad displayed');
                      },
                    );
                    _setAdMob();
                    await _incrementCounter();

                    resetGame();
                    Navigator.pop(context);
                    Navigator.pop(context);
                  } else {
                    await Navigator.pushNamed(
                      context,
                      '/tracking',
                      arguments: {
                        "link": adUrl,
                        "adCountTemp": "",
                        "seconds": "15"
                      },
                    );

                    _setAdMob();
                    await _incrementCounter();

                    resetGame();
                  }

                  // await _incrementCounter();

                  // resetGame();
                  // Navigator.pop(context);
                  // Navigator.pop(context);
                },
                child: const Text('Play Again'),
              )
            else if (content.contains('No one wins'))
              TextButton(
                onPressed: () async {
                  FlameAudio.play('button.mp3');

                  // Check if Player O wins for the first time
                  // bool isFirstTimeWinning =
                  //     prefs.getBool('No one wins${widget.level}') ?? true;

                  // setState(() {});
                  // unityPlacements[AdManager.interstitialVideoAdPlacementId] ==
                  //     true;
                  // showUnityAd(AdManager.interstitialVideoAdPlacementId);

                  // if (isFirstTimeWinning) {
                  //   // Deduct coins only if it's the first time Player O wins
                  //   // await decreaseGameCoin(
                  //   //     20); // Deduct 50 coins if Player O wins
                  //   // Mark Player O as won to prevent future deductions
                  //   prefs.setBool('No one wins${widget.level}', false);
                  // }
                  // await interstitialAd!.show();

                  if (adMob) {
                    await rewardedAd!.show(
                      onUserEarnedReward: (ad, reward) {
                        print('ad displayed');
                      },
                    );
                    _setAdMob();
                    await _incrementCounter();

                    resetGame();
                    Navigator.pop(context);
                    Navigator.pop(context);
                  } else {
                    await Navigator.pushNamed(
                      context,
                      '/tracking',
                      arguments: {
                        "link": adUrl,
                        "adCountTemp": "",
                        "seconds": "15"
                      },
                    );

                    _setAdMob();
                    await _incrementCounter();

                    resetGame();
                  }

                  // await _incrementCounter();

                  // resetGame();
                  // Navigator.pop(context);
                  // Navigator.pop(context);
                },
                child: const Text('Play Again'),
              )
            else
              TextButton(
                onPressed: () async {
                  FlameAudio.play('button.mp3');

                  // _incrementCounter();

                  // Check if the level is being played for the first time
                  bool isFirstTimePlaying =
                      prefs.getBool('level-${widget.level}-played') ?? true;
                  prefs.setBool('Level ${widget.level} completed', true);
                  // unityPlacements[AdManager.rewardedVideoAdPlacementId] == true;

                  // showUnityAd(AdManager.rewardedVideoAdPlacementId);

                  await rewardedAd!.show(
                    onUserEarnedReward: (ad, reward) {
                      print('Display Ad');
                    },
                  );

                  await _incrementCounter();

                  if (isFirstTimePlaying) {
                    // Show reward ad and credit coins only if it's the first time playing the level
                    increaseGameCoin(101);
                    _onEarnCoins(101);
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
                child: const Text('Play Next'),
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
      if (easyMode == "1") {
        return availableMoves[Random().nextInt(availableMoves.length)];
      } else {
        if (levelPlayed >= int.parse(levelPlayedCount)) {
          return availableMoves[Random().nextInt(availableMoves.length)];
        } else {
          return hardDifficultyMove(board, player);
        }
      }
    } else {
      return -1;
    }

    // if (availableMoves.isNotEmpty) {
    //   if (level <= 11) {
    //     // Levels 1: Easy difficulty, AI makes random moves
    //     return availableMoves[Random().nextInt(availableMoves.length)];
    //   } else if (level >= 12 && level <= 13) {
    //     // Levels 2-6: Hard difficulty, AI makes optimal moves
    //     return mediumDifficultyMove(board, availableMoves, player);
    //   } else {
    //     // Levels 31-32: Hard difficulty, AI makes optimal moves
    //     if (level >= 14) {
    //       return hardDifficultyMove(board, player);
    //     } else {
    //       return mediumDifficultyMove(board, availableMoves, player);
    //     }
    //   }
    // } else {
    //   // No available moves
    //   return -1;
    // }
    // if (availableMoves.isNotEmpty) {
    //   if (level <= 1) {
    //     // Levels 1: Easy difficulty, AI makes random moves
    //     return availableMoves[Random().nextInt(availableMoves.length)];
    //   } else if (level >= 2 && level <= 3) {
    //     // Levels 2-6: Hard difficulty, AI makes optimal moves
    //     return mediumDifficultyMove(board, availableMoves, player);
    //   } else {
    //     // Levels 31-32: Hard difficulty, AI makes optimal moves
    //     if (level >= 4) {
    //       return hardDifficultyMove(board, player);
    //     } else {
    //       return mediumDifficultyMove(board, availableMoves, player);
    //     }
    //   }
    // } else {
    //   // No available moves
    //   return -1;
    // }
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

  int hardDifficultyMove(List<String> board, String player) {
    int bestScore = -1000;
    int bestMove = -1;
    for (int i = 0; i < 9; i++) {
      if (board[i] == '') {
        board[i] = player;
        int score = minimax(board, 0, false);
        board[i] = '';
        if (score > bestScore) {
          bestScore = score;
          bestMove = i;
        }
      }
    }
    return bestMove;
  }

  int minimax(List<String> newBoard, int depth, bool isMaximizing) {
    String aiPlayer = 'O';
    String humanPlayer = 'X';

    if (checkWinner(newBoard, aiPlayer)) return 10 - depth;
    if (checkWinner(newBoard, humanPlayer)) return depth - 10;
    if (!newBoard.contains('')) return 0;

    if (isMaximizing) {
      int bestScore = -1000;
      for (int i = 0; i < 9; i++) {
        if (newBoard[i] == '') {
          newBoard[i] = aiPlayer;
          int score = minimax(newBoard, depth + 1, false);
          newBoard[i] = '';
          bestScore = max(score, bestScore);
        }
      }
      return bestScore;
    } else {
      int bestScore = 1000;
      for (int i = 0; i < 9; i++) {
        if (newBoard[i] == '') {
          newBoard[i] = humanPlayer;
          int score = minimax(newBoard, depth + 1, true);
          newBoard[i] = '';
          bestScore = min(score, bestScore);
        }
      }
      return bestScore;
    }
  }
}
