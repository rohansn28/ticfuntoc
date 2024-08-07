import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:tic_fun_toc/menu.dart';
import 'package:tic_fun_toc/play.dart';
import 'package:tic_fun_toc/resume_tracking_screen.dart';
import 'package:tic_fun_toc/resume_tracking_screen2.dart';
import 'package:tic_fun_toc/setting.dart';
import 'package:tic_fun_toc/splashscreen.dart';

import 'package:tic_fun_toc/utils.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Load the music settings
  MusicSettings musicSettings = MusicSettings();
  await musicSettings.loadMusicSetting();
  // initpref();
  // initUnityAds();
  await fetchMainData();

  //Onesingle code starts-->
  await OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.initialize("b6cf291e-609f-4457-8cf1-22fff4e9a3b1");
  OneSignal.Notifications.requestPermission(true);
  //Onesingle code ends-->

  runApp(
    ChangeNotifierProvider.value(
      value: musicSettings,
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tic Fun Toc',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(backgroundColor: Colors.transparent,foregroundColor: Colors.white)
      ),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      // home: MenuScreen(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => const SplashScreen(),
        '/home': (context) => const MenuScreen(),
        '/playpage': (context) => const PlayGamePage(),
        '/tracking': (context) => const ResumeTrackingScreen(),
        '/tracking2': (context) => const ResumeTrackingScreen2(),
      },
    );
  }
}
