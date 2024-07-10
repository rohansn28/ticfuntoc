import 'package:flutter/material.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tic_fun_toc/menu.dart';
import 'package:tic_fun_toc/utils.dart';

class MusicSettings extends ChangeNotifier {
  bool _isMusicOn = true;

  bool get isMusicOn => _isMusicOn;

  Future<void> loadMusicSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isMusicOn = prefs.getBool('isMusicOn') ?? true;
    notifyListeners();
    if (_isMusicOn) {
      FlameAudio.bgm.resume();
    } else {
      FlameAudio.bgm.pause();
    }
  }

  void toggleMusic(BuildContext context, bool value) async {
    _isMusicOn = value;
    notifyListeners();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isMusicOn', _isMusicOn);
    if (_isMusicOn) {
      FlameAudio.bgm.play('bg.mp3', volume: 1.0);
    } else {
      FlameAudio.bgm.stop();
    }
  }
}

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
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
          child: Icon(Icons.arrow_back, color: Colors.white),
        ),
        elevation: 0, // Remove the shadow
        backgroundColor: Colors.transparent,
        title: Text(
          'Settings',
          style: TextStyle(
              fontFamily: 'Hello Graduation',
              fontSize: 36,
              color: Colors.white,
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: PopScope(
        onPopInvoked: (didPop) {
          WidgetsBinding.instance.addPostFrameCallback(
            (timeStamp) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => MenuScreen(),
                ),
              );
            },
          );
        },
        // onPopInvokedWithResult: (didPop, result) {
        //   // Navigator.pop(context);
        //   Navigator.pushReplacement(
        //     context,
        //     MaterialPageRoute(
        //       builder: (context) => MenuScreen(),
        //     ),
        //   );
        // },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              _buildSettingItem(
                title: 'Music',
                description: 'Turn on or off',
                value: context.watch<MusicSettings>().isMusicOn,
                onChanged: (value) => _toggleMusic(context, value),
              ),
              SizedBox(height: 20),
              // Add Reset Game button
              ElevatedButton(
                onPressed: () => _resetGame(context),
                child: Text('Reset Game'),
              )
              // Add more settings here
            ],
          ),
        ),
      ),
    );
  }

  void _resetGame(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Reset Game'),
        content: Text(
            'Are you sure you want to reset the game? This will reset your coins and level progress.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              resetGame(context);
              Navigator.pop(context);
            },
            child: Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _toggleMusic(BuildContext context, bool value) {
    FlameAudio.play('button.mp3');
    context.read<MusicSettings>().toggleMusic(context, value);
  }

  Widget _buildSettingItem({
    required String title,
    required String description,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 28,
            fontFamily: 'Hello Graduation',
            color: Colors.white,
          ),
        ),
        SizedBox(height: 10),
        Text(
          description,
          style: TextStyle(
            fontSize: 26,
            fontFamily: 'Hello Graduation',
            color: Colors.white,
          ),
        ),
        SizedBox(height: 20),
        Row(
          children: [
            Text(
              'Background Music',
              style: TextStyle(
                fontSize: 28,
                fontFamily: 'Hello Graduation',
                color: Colors.white,
              ),
            ),
            Spacer(),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: Colors.blue,
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: Colors.grey[400],
            ),
          ],
        ),
        Divider(height: 20, color: Colors.grey),
      ],
    );
  }
}
