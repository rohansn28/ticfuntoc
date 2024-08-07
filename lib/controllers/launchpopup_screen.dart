import 'package:flutter/material.dart';

void launchPopupScreen(context, var screen) {
  Navigator.of(context).push(PageRouteBuilder(
      opaque: false, pageBuilder: (BuildContext context, _, __) => screen));
}
