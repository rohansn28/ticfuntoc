import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tic_fun_toc/controllers/launch_custom_tab.dart';
import 'package:tic_fun_toc/controllers/launchpopup_screen.dart';
import 'package:tic_fun_toc/timeremainingwidget.dart';

class ResumeTrackingScreen2 extends StatefulWidget {
  const ResumeTrackingScreen2({super.key});

  @override
  State<ResumeTrackingScreen2> createState() => _ResumeTrackingScreenState2();
}

class _ResumeTrackingScreenState2 extends State<ResumeTrackingScreen2>
    with WidgetsBindingObserver {
  String fRoute = "";
  late Widget nextPage;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  void setPrefs(String link, String seconds) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("currentLink", link);
    prefs.setString(
      link,
      DateTime.now()
          .add(Duration(seconds: int.parse(seconds)))
          .toUtc()
          .toString(),
    );
  }

  void checkPrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if (DateTime.parse(prefs.getString(prefs.getString("currentLink")!)!)
        .toUtc()
        .isAfter(DateTime.now().toUtc())) {
      // before time
      print('before time');
      int timeLeft =
          DateTime.parse(prefs.getString(prefs.getString("currentLink")!)!)
              .difference(DateTime.now().toUtc())
              .inSeconds;
      timeRemainingHandle(timeLeft.toString(), prefs.getString("currentLink")!);
    } else {
      // after time
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => nextPage),
      );
    }
  }

  void timeRemainingHandle(String timeLeftSeconds, String link) {
    Navigator.pop(context);
    // showSnackBar(context, "Please Wait 1 min on the website");
    launchPopupScreen(
        context,
        TimeRemainingWidget(
          seconds: timeLeftSeconds,
          link: link, nextPage: nextPage, fRoute: fRoute,
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

  void _launchLink(String link, String seconds) {
    setPrefs(link, seconds,);
    launchCustomTabURL(context, link);
  }

  @override
  Widget build(BuildContext context) {
    // final routes =
    //     ModalRoute.of(context)?.settings.arguments as Map<String, String>;
    // final link = routes['link'];

    // fRoute = routes['fRoute']!;

    final Map<String, dynamic> args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String link = args["link"];
    final String seconds = args['seconds']!;
    fRoute = args["fRoute"];
    setState(() {
      nextPage = args["nextPage"];
    });

    (link);

    if (buildorNot) {
      _launchLink(link,seconds);
      // Future.delayed(const Duration(seconds: 2), () {
      //   _launchLink(link);
      // });
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
