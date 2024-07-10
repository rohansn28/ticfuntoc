import 'package:flutter/material.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:provider/provider.dart';
import 'package:tic_fun_toc/ad_helper.dart';
import 'package:tic_fun_toc/play.dart';
import 'package:tic_fun_toc/setting.dart';
import 'package:tic_fun_toc/utils.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
// import 'about.dart';
// import 'choose.dart';

class MenuScreen extends StatefulWidget {
  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController titleAnimationController;
  late Animation<double> titleAnimation;
  // bool _isRiveLoading = false;
  late BannerAd bannerAd;
  bool isLoaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    setupAnimation();
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

  void setupAnimation() {
    titleAnimationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
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
    super.dispose();
    // _bannerAd.dispose();
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
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Image.asset(
            'assets/theme.gif',
            fit: BoxFit.cover,
            // width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
          ),
          // if (!_isRiveLoading)
          //   RiveAnimation.asset(
          //     'assets/riv.riv',
          //     fit: BoxFit.cover,
          //     alignment: Alignment.center,
          //     antialiasing: true,
          //   ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 20),
                AnimatedTextKit(
                  animatedTexts: [
                    WavyAnimatedText(
                      'Tic Fun Toc!',
                      textStyle: TextStyle(
                        fontFamily: 'Hello Graduation',
                        fontSize: 50,
                        color: Colors.white,
                      ),
                      speed: Duration(milliseconds: 200),
                    ),
                  ],
                ),
                SizedBox(height: 50),
                CustomButton(
                  onPressed: () {
                    FlameAudio.play('button.mp3');
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => PlayGamePage()));
                  },
                  label: 'Play',
                ),
                // SizedBox(height: 50),
                // CustomButton(
                //   onPressed: () {
                //     FlameAudio.play('button.mp3');
                //     Navigator.push(context,
                //         MaterialPageRoute(builder: (_) => ModeScreen()));
                //   },
                //   label: 'Mode',
                // ),
                SizedBox(height: 20),
                CustomButton(
                  onPressed: () {
                    FlameAudio.play('button.mp3');
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => SettingsScreen()));
                  },
                  label: 'Settings',
                ),
                SizedBox(height: 20),
                if (objlive)
                  Container(
                    width: 180,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(
                          25), // Adjust the radius as needed
                    ),
                    padding: EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 10), // Adjust padding as needed
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/coin.png',
                          width: 33,
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Text(
                          gameCoins.toString(),
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Hello Graduation',
                              fontSize: 25,
                              fontWeight: FontWeight.w200),
                        ),
                      ],
                    ),
                  ),
              ],
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
          : const SizedBox(),
    );
  }
}

class CustomButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String label;

  const CustomButton({
    Key? key,
    required this.onPressed,
    required this.label,
  }) : super(key: key);

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
        duration: Duration(milliseconds: 100),
        width: 200,
        height: 60,
        decoration: BoxDecoration(
          color: isPressed ? Colors.lightGreen : Colors.blue,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            widget.label,
            style: TextStyle(
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
