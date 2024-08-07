import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tic_fun_toc/ad_helper.dart';
import 'package:tic_fun_toc/play.dart';
import 'package:tic_fun_toc/setting.dart';
import 'package:tic_fun_toc/utils.dart';



class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController titleAnimationController;
  late Animation<double> titleAnimation;
  bool isLoaded = false;
  late BannerAd bannerAd;
  int adCount = 0;
  String adHintUrl = "";
  String userId = "";
  @override
  void initState() {
    super.initState();
    initMenuPrefs();
    initbannerAd();
    WidgetsBinding.instance.addObserver(this);
    setupAnimation();

    final musicSettings = Provider.of<MusicSettings>(context, listen: false);

    if (musicSettings.isMusicOn) {
      _playBackgroundMusic();
    }
  }

  Future<void> initMenuPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      userId = prefs.getString('user_id')!;

    });
  }



  Future<void> countAd() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey('adCount')) {
      setState(() {
        adCount = prefs.getInt('adCount')!;
      });

      if (adCount + 1 == 2) {
        setState(() {
          adHintUrl = adHintUrl2;
        });
      }
      if (adCount + 1 == 3) {
        setState(() {
          adHintUrl = adHintUrl3;
        });
      }
      if (adCount + 1 == 4) {
        setState(() {
          adHintUrl = adHintUrl4;
        });
      }
      if (adCount + 1 == 5) {
        setState(() {
          adHintUrl = adHintUrl5;
        });
      }
    } else {
      if (adCount + 1 == 1) {
        setState(() {
          adHintUrl = adHintUrl1;
        });
      }
    }
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
          print('error');
        },
      ),
      request: const AdRequest(),
    );

    bannerAd.load();
  }

  void setupAnimation() {
    titleAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    titleAnimation = Tween<double>(begin: 0, end: 20).animate(
      CurvedAnimation(
        parent: titleAnimationController,
        curve: Curves.easeInOut,
      ),
    );
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

  @override
  void dispose() {
    titleAnimationController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    bannerAd.dispose();
    isLoaded = false;
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final musicSettings = Provider.of<MusicSettings>(context, listen: false);

    if (state == AppLifecycleState.paused || !musicSettings.isMusicOn) {
      FlameAudio.bgm.pause();
    } else if (state == AppLifecycleState.resumed && musicSettings.isMusicOn) {
      FlameAudio.bgm.resume();
    }
  }

  @override
  Widget build(BuildContext context) {
    // fetchLvl1Locked();
    return Scaffold(
        body: Stack(
          children: [

            SingleChildScrollView(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 50,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 8),
                      width: MediaQuery.of(context).size.width * 0.7,
                      // height: 70,
                      decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(10)),
                      child: Text(
                        titleBox,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Hello Graduation',
                          fontSize: 23,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 60),
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
                    const SizedBox(height: 20),
                    AnimatedTextKit(
                      animatedTexts: [
                        WavyAnimatedText(
                          'Tic Fun Toc!',
                          textStyle: const TextStyle(
                            fontFamily: 'Hello Graduation',
                            fontSize: 50,
                            color: Colors.white,
                          ),
                          speed: const Duration(milliseconds: 200),
                        ),
                      ],
                    ),
                    const SizedBox(height: 50),
                    CustomButton(
                      onPressed: () {
                        FlameAudio.play('button.mp3');

                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const PlayGamePage()));
                      },
                      label: 'Play',
                    ),
                    const SizedBox(height: 20),
                    CustomButton(
                      onPressed: () {
                        FlameAudio.play('button.mp3');
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => SettingsScreen()));
                      },
                      label: 'Settings',
                    ),
                    const SizedBox(height: 20),
                    CustomButton(
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
                                          "link": adHintUrl,
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
                        label: 'Hint'),
                  ],
                ),
              ),
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

class CustomButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String label;

  const CustomButton({
    super.key,
    required this.onPressed,
    required this.label,
  });

  @override
  _CustomButtonState createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => isPressed = true),
      onTapUp: (_) => setState(() => isPressed = false),
      onTapCancel: () => setState(() => isPressed = false),
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: 200,
        height: 60,
        decoration: BoxDecoration(
          color: isPressed ? Colors.lightGreen : Colors.blue,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            widget.label,
            style: const TextStyle(
              fontFamily: 'Hello Graduation',
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
