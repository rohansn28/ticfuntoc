import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:tic_fun_toc/models/mainlink.dart';

String gameCoinsLabel = "gameCoins";

int gameCoins = 0;
bool objlive = false;

Future<String> fetchMainData() async {
  var url = 'https://loungecard.website/linebucks/public/api/tictactoedata';

  var response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    var data = mainLinkFromJson(response.body);
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
  } else {
    prefs.setInt(gameCoinsLabel, 0);
  }
  Navigator.of(context).popAndPushNamed('/home');
}

Future<void> resetGame(BuildContext context) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  // Reset game coins to 0
  prefs.clear();
  prefs.setInt(gameCoinsLabel, 0);
  gameCoins = 0;
}
