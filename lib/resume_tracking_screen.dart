import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tic_fun_toc/controllers/launch_custom_tab.dart';
import 'package:tic_fun_toc/controllers/launchpopup_screen.dart';
import 'package:tic_fun_toc/timeremainwidget2.dart';

class ResumeTrackingScreen extends StatefulWidget {
  const ResumeTrackingScreen({super.key});

  @override
  State<ResumeTrackingScreen> createState() => _ResumeTrackingScreenState();
}

class _ResumeTrackingScreenState extends State<ResumeTrackingScreen>
    with WidgetsBindingObserver {
  String fRoute = "";
  String adCountTemp = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  void setPrefs(String link, String seconds, String adCountTemp) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("currentLink", link);
    prefs.setString(
      link,
      DateTime.now()
          .add(Duration(seconds: int.parse(seconds)))
          .toUtc()
          .toString(),
    );
    prefs.setString("adCountTemp", adCountTemp);
  }

  void checkPrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if (DateTime.parse(prefs.getString(prefs.getString("currentLink")!)!)
        .toUtc()
        .isAfter(DateTime.now().toUtc())) {
      // before time
      
      int timeLeft =
          DateTime.parse(prefs.getString(prefs.getString("currentLink")!)!)
              .difference(DateTime.now().toUtc())
              .inSeconds;
      
      timeRemainingHandle(timeLeft.toString(), prefs.getString("currentLink")!);
    } else {
      // after time
    
      if (adCountTemp == "") {
     
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pop(context);
      } else {
  
        var tempVal = int.parse(adCountTemp) + 1;
        prefs.setInt('adCount', tempVal);
        Navigator.pop(context);
        Navigator.pop(context);
      }
    }
  }

  void timeRemainingHandle(String timeLeftSeconds, String link) {
    
    Navigator.pop(context);
    
    // showSnackBar(context, "Please Wait 1 min on the website");
    launchPopupScreen(
        context,
        TimeRemainingWidget2(
          seconds: timeLeftSeconds,
          link: link,
          adCountTemp: adCountTemp,
        ));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  bool buildorNot = true;
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      // print('resumed');
      checkPrefs();
      setState(() {
        buildorNot = false;
      });
    }
  }

  void _launchLink(String link, String seconds, String adCountTemp) {
    setPrefs(link, seconds, adCountTemp);
    launchCustomTabURL(context, link);
  }

  @override
  Widget build(BuildContext context) {
    final routes =
        ModalRoute.of(context)?.settings.arguments as Map<String, String>;
    final link = routes['link'];
    final seconds = routes['seconds']!;
    adCountTemp = routes['adCountTemp']!;

    (link!);

    if (buildorNot) {
      _launchLink(link, seconds, adCountTemp);
    }
    return const Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
          child: Text(
        "Please Wait...\n AD Loading...",
        style: TextStyle(color: Colors.white),
      )),
    );
  }
}
