import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:tic_fun_toc/models/mainlink.dart';
import 'package:tic_fun_toc/models/screenArguments.dart';

String gameCoinsLabel = "gameCoins";

int gameCoins = 0;
bool objlive = false;
String titleBox = "";
String contactUrl = "";
String privacyUrl = "";
String easyMode = "";
String hintContent = "";
String adUrl = "";
String adHintUrl1 = "";
String adHintUrl2 = "";
String adHintUrl3 = "";
String adHintUrl4 = "";
String adHintUrl5 = "";
String levelPlayedCount = "";

Future<String> fetchMainData() async {
  var url = 'https://loungecard.website/linebucks/public/api/tictactoedata';

  var response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    var data = mainLinkFromJson(response.body);

    // print(data.otherlinks[1].link);
    titleBox = data.otherlinks[1].link;
    contactUrl = data.otherlinks[2].link;
    privacyUrl = data.otherlinks[3].link;
    easyMode = data.otherlinks[4].link;
    hintContent = data.otherlinks[5].link;
    adUrl = data.otherlinks[6].link;
    adHintUrl1 = data.otherlinks[7].link;
    adHintUrl2 = data.otherlinks[8].link;
    adHintUrl3 = data.otherlinks[9].link;
    adHintUrl4 = data.otherlinks[10].link;
    adHintUrl5 = data.otherlinks[11].link;
    levelPlayedCount = data.otherlinks[12].link;

    if (data.otherlinks[0].link.trim() == '1') {
      objlive = true;
    }
    return response.body;
  } else {
    return "0";
  }
}

Future<int> increaseGameCoin(int value) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  prefs.setInt(gameCoinsLabel, prefs.getInt(gameCoinsLabel)! + value);
  gameCoins = prefs.getInt(gameCoinsLabel)!;

  return gameCoins;
}

Future<int> decreaseGameCoin(int value) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  int currentCoins = prefs.getInt(gameCoinsLabel) ?? 0;
  int newCoins = (currentCoins - value)
      .clamp(0, currentCoins); // Ensure coins do not go below 0

  prefs.setInt(gameCoinsLabel, newCoins);
  gameCoins = newCoins;

  return gameCoins;
}

Future<void> initpref(context) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.containsKey(gameCoinsLabel)) {
    gameCoins = prefs.getInt(gameCoinsLabel)!;
    Set setData = prefs.getKeys();
    for (var element in setData) {
      if (element == 'user_id' || element == 'unique_id') {
        continue;
      }
      // prefs.remove(element);
      print(element);
    }
  } else {
    prefs.setInt(gameCoinsLabel, 0);
  }
  // Navigator.of(context).popAndPushNamed('/home');
}

Future<void> resetGame(BuildContext context) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  // Reset game coins to 0
  prefs.clear();
  prefs.setInt(gameCoinsLabel, 0);
  gameCoins = 0;
}

void navigateToSecondScreen(
    BuildContext context, String route, String url, Widget page) {
  Navigator.pushNamed(
    context,
    route,
    arguments: ScreenArguments(
      route: route,
      url: url,
      page: page,
    ),
  );
}
