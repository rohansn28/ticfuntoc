import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:tic_fun_toc/menu.dart';
import 'package:tic_fun_toc/setting.dart';
import 'package:tic_fun_toc/startpage.dart';
import 'package:tic_fun_toc/utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Load the music settings
  MusicSettings musicSettings = MusicSettings();
  await musicSettings.loadMusicSetting();
  // initpref();

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
    fetchMainData();
    return MaterialApp(
      title: 'Tic Fun Toc',
      theme: ThemeData(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      // home: MenuScreen(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => const StartPageScreen(),
        '/home': (context) => MenuScreen(),
      },
    );
  }
}
