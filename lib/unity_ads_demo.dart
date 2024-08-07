import 'package:unity_ads_plugin/unity_ads_plugin.dart';

// void showUnityInterstitial() {
//   showUnityAd(AdManager.rewardedVideoAdPlacementId);
// }

class AdManager {
  static String get gameId {
    return '5655040';
  }

  static String get interstitialVideoAdPlacementId {
    return 'TicInterstitial';
  }

  static String get rewardedVideoAdPlacementId {
    return 'Rewarded_Android';
  }
}

Map<String, bool> unityPlacements = {
  AdManager.interstitialVideoAdPlacementId: false,
  AdManager.rewardedVideoAdPlacementId: false,
};

void initUnityAds() {
   UnityAds.init(
      gameId: AdManager.gameId,
      // testMode: true,
      onComplete: () {
        print('Initialization Complete');
        _loadAds();
      },
      onFailed: (error, message) => print('Initialization Failed: $error $message'),
    );
}

void _loadAds() {
     for (var placementId in unityPlacements.keys) {
      _loadAd(placementId);
    }
}

void _loadAd(String placementId) {
  UnityAds.load(
    placementId: placementId,
    onComplete: (placementId) {
      print('Load Complete $placementId');
      unityPlacements[placementId] = true;
    },
    onFailed: (placementId, error, message) =>
        print('Load Failed $placementId: $error $message'),
  );
}

void showUnityAd(String placementId) {
  unityPlacements[placementId] = false;
  UnityAds.showVideoAd(
    placementId: placementId,
    onComplete: (placementId) {
      print('Video Ad $placementId completed');
      _loadAd(placementId);
    },
    onFailed: (placementId, error, message) {
      print('Video Ad $placementId failed: $error $message');
      _loadAd(placementId);
    },
    onStart: (placementId) {},
    onClick: (placementId) => print('Video Ad $placementId click'),
    onSkipped: (placementId) {
      print('Video Ad $placementId skipped');
      _loadAd(placementId);
    },
  );
}
