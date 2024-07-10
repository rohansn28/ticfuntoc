import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tic_fun_toc/ad_helper.dart';
import 'package:tic_fun_toc/levelscreen.dart';
import 'package:tic_fun_toc/menu.dart';
import 'package:tic_fun_toc/setting.dart';

class PlayGamePage extends StatefulWidget {
  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<PlayGamePage> {
  int maxLevels = 32;
  List<bool> levelUnlocked = List.filled(32, false);
  late BannerAd bannerAd;
  bool isLoaded = false;

  @override
  void initState() {
    super.initState();
    initLevel1();
    levelUnlocked[0] = true;
    initbannerAd();

    final musicSettings = Provider.of<MusicSettings>(context, listen: false);

    if (musicSettings.isMusicOn) {
      _playBackgroundMusic();
    }
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

  Future<List<bool>> test() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    for (var i = 0; i < levelUnlocked.length; i++) {
      if (prefs.getBool('level-${i + 1}-unlocked') == true) {
        levelUnlocked[i] = true;
      }
    }
    return levelUnlocked;
  }

  @override
  Widget build(BuildContext context) {
  
    return Theme(
      data: Theme.of(context),
      child: Scaffold(
          appBar: AppBar(
            leading: InkWell(
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MenuScreen(),
                  ),
                );
              },
              child: const Icon(
                Icons.arrow_back,
              ),
            ),
            title: const Text('Levels'),
            titleTextStyle: const TextStyle(
              fontFamily: 'Hello Graduation',
              fontSize: 50,
              color: Colors.black,
            ),
          ),
          body: SafeArea(
            child: Stack(
              children: [
                Image.asset(
                  'assets/theme.gif',
                  fit: BoxFit.cover,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                ),
                // RiveAnimation.asset(
                //   'assets/space.riv',
                //   fit: BoxFit.cover,
                // ),
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
                              // Navigate to the selected level
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
                                  ),
                                ),
                              );
                            } else {
                              // Show a dialog indicating level is locked
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Level Locked'),
                                  content: Text(
                                      'This level is locked. You need to complete the previous level to unlock it.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                          child: Text(
                            ' ${index + 1}',
                            style: TextStyle(
                              fontFamily: 'Hello Graduation',
                              fontSize: 24,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.all(16),
                            backgroundColor: levelUnlocked[index]
                                ? Colors.lightGreen
                                : Colors.blue,
                            textStyle: TextStyle(color: Colors.white),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          bottomNavigationBar: isLoaded
              ? SizedBox(
                  height: bannerAd.size.height.toDouble(),
                  width: bannerAd.size.width.toDouble(),
                  child: AdWidget(ad: bannerAd),
                )
              : const SizedBox()),
    );
  }
}
