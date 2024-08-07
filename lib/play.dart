import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tic_fun_toc/ad_helper.dart';
import 'package:tic_fun_toc/levelscreen.dart';

import 'package:tic_fun_toc/setting.dart';
import 'package:tic_fun_toc/utils.dart';

class PlayGamePage extends StatefulWidget {
  const PlayGamePage({super.key});

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<PlayGamePage> {
  int maxLevels = 32;
  List<bool> levelUnlocked = List.filled(32, false);
  List<bool> levelCompleted = List.filled(32, false);
  late BannerAd bannerAd;
  bool isLoaded = false;
  String userId = "";

  @override
  void initState() {
    super.initState();
    initLevelPrefs();
    initbannerAd();
    initLevel1();
    levelUnlocked[0] = true;

    final musicSettings = Provider.of<MusicSettings>(context, listen: false);

    if (musicSettings.isMusicOn) {
      _playBackgroundMusic();
    }
  }

  Future<void> initLevelPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('user_id')!;
      // userId = prefs.getString('unique_id')!;
    });
  }

  initbannerAd() {
    bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: AdHelper.bannerAdUnitId,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            bannerAd = ad as BannerAd;
            isLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          // print('error');
        },
      ),
      request: const AdRequest(),
    );

    bannerAd.load();
  }

  void _playBackgroundMusic() {
    final musicSettings = Provider.of<MusicSettings>(context, listen: false);

    if (musicSettings.isMusicOn) {
      try {
        FlameAudio.bgm.play('bg.mp3', volume: 1.0);
      } catch (e) {
        print('Error loading and playing background music: $e');
      }
    } else {
      FlameAudio.bgm.stop();
    }
  }

  void didChangeAppLifecycleState(AppLifecycleState state) {
    final musicSettings = Provider.of<MusicSettings>(context, listen: false);

    if (state == AppLifecycleState.paused || !musicSettings.isMusicOn) {
      FlameAudio.bgm.pause();
    } else if (state == AppLifecycleState.resumed && musicSettings.isMusicOn) {
      FlameAudio.bgm.resume();
    }
  }

  Future<void> initLevel1() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('level-1-unlocked', true);
  }

  Future<void> initChcekLevel() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('level-1-unlocked', true);
  }

  Future<List<bool>> test() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    for (var i = 0; i < levelUnlocked.length; i++) {
      if (prefs.getBool('level-${i + 1}-unlocked') == true) {
        levelUnlocked[i] = true;
      }
      if (prefs.containsKey('Level ${i + 1} completed')) {
        if (prefs.getBool('Level ${i + 1} completed') == true) {
          setState(() {
            levelCompleted[i] = true;
          });
        }
      }
    }
    return levelUnlocked;
  }

  @override
  void dispose() {
    bannerAd.dispose();
    isLoaded = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [
            Container(
              // width: 180,
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
          title: const Text('Levels'),
          titleTextStyle: const TextStyle(
            fontFamily: 'Hello Graduation',
            fontSize: 50,
            // color: Colors.black,
          ),
          bottom: PreferredSize(
            preferredSize: Size(0.0, 50.0),
            child: Container(
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 8), // Adjust padding as needed
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
          ),
        ),
        body: Stack(
          children: [
            FutureBuilder(
              future: test(),
              builder: (context, snapshot) {
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: maxLevels,
                  itemBuilder: (BuildContext context, int index) {
                    return ElevatedButton(
                      onPressed: () {
                        FlameAudio.play('button.mp3');
                        if (levelUnlocked[index]) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LevelScreen(
                                level: index + 1,
                                onPlayNext: () {
                                  // Unlock the next level if it exists
                                  if (index + 1 < maxLevels) {
                                    levelUnlocked[index + 1] = true;
                                    setState(() {});
                                  }
                                },
                                levelCompleted: levelCompleted[index],
                              ),
                            ),
                          );
                        } else {
                          // Show a dialog indicating level is locked
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Level Locked'),
                              content: const Text(
                                  'This level is locked. You need to complete the previous level to unlock it.'),
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
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        backgroundColor:
                            levelUnlocked[index] && levelCompleted[index]
                                ? Colors.red
                                : levelUnlocked[index]
                                    ? Colors.lightGreen
                                    : Colors.blue,
                        textStyle: const TextStyle(color: Colors.white),
                      ),
                      child: levelCompleted[index]
                          ? const Icon(Icons.check,
                              color: Colors.white, size: 40)
                          : Text(
                              ' ${index + 1}',
                              style: const TextStyle(
                                fontFamily: 'Hello Graduation',
                                fontSize: 24,
                                color: Colors.white,
                              ),
                            ),
                    );
                  },
                );
              },
            ),
          ],
        ),
        bottomNavigationBar: isLoaded
            ? SizedBox(
                height: bannerAd.size.height.toDouble(),
                width: bannerAd.size.width.toDouble(),
                child: AdWidget(ad: bannerAd),
              )
            : const SizedBox()
        );
  }
}
