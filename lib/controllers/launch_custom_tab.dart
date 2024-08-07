import 'package:flutter/material.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';

void launchCustomTabURL(BuildContext context, String link) async {
  final theme = Theme.of(context);
  try {
    await launchUrl(
      Uri.parse(link),
      customTabsOptions: CustomTabsOptions(
        colorSchemes: CustomTabsColorSchemes.defaults(
          // toolbarColor: theme.colorScheme.surface,
          toolbarColor: Color.fromARGB(255, 31, 198, 213),
          // navigationBarColor: theme.colorScheme.background,
          navigationBarColor: Color.fromARGB(255, 31, 198, 213),
        ),
        shareState: CustomTabsShareState.off,
        urlBarHidingEnabled: true,
        showTitle: true,
        closeButton: CustomTabsCloseButton(icon: CustomTabsCloseButtonIcons.back)
      ),
      safariVCOptions: SafariViewControllerOptions(
        preferredBarTintColor: theme.colorScheme.surface,
        preferredControlTintColor: theme.colorScheme.onSurface,
        barCollapsingEnabled: true,
        entersReaderIfAvailable: false,
      ),
    );
  } catch (e) {
    // An exception is thrown if browser app is not installed on Android device.
    print('Failed to launch URL: $e');
    debugPrint(e.toString());
  }
}
