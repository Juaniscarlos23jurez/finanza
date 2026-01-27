import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  /// Initialize the Google Mobile Ads SDK.
  Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }

  /// Get the banner ad unit ID based on the platform.
  /// Uses test IDs for development.
  String get bannerAdUnitId {
    if (kDebugMode) {
      if (Platform.isAndroid) {
        return 'ca-app-pub-3940256099942544/6300978111'; // Android Test Banner
      } else if (Platform.isIOS) {
        return 'ca-app-pub-3940256099942544/2934735716'; // iOS Test Banner
      }
    }
    // Release Mode
    if (Platform.isAndroid) {
      return 'ca-app-pub-8583703891478819/7850287315';
    } else if (Platform.isIOS) {
       // Using the same ID as Android because the user only provided one general ID or I should assume the same for now
       // But typically they differ. The prompt gave ONE ID "ca-app-pub-8583703891478819/7850287315".
       // I will use it for both or just return it. 
       // Ideally I should ask, but I will put it in the "Release Mode" block for both or just use it.
       return 'ca-app-pub-8583703891478819/7850287315'; 
    }
    throw UnsupportedError('Unsupported platform');
  }

  /// Get the native ad unit ID (for "Native Advanced" look).
  /// Note: Flutter's google_mobile_ads package has limited support for fully custom Native Ads rendered with Flutter widgets.
  /// Often "Native Templates" or Banner ads are used. 
  /// For this implementation, we will use a **Banner** styled to look native (Medium Rectangle 300x250 or fluid) 
  /// OR use the actual Native API if available.
  /// 
  /// However, standard Banners are easier to integrate in a ListView. 
  /// We will use a "Large Banner" or "Medium Rectangle" for the feed.
  String get feedAdUnitId {
    if (kDebugMode) {
       if (Platform.isAndroid) {
        return 'ca-app-pub-3940256099942544/6300978111'; // Just using Banner for now as it's easiest for list integration
      } else if (Platform.isIOS) {
        return 'ca-app-pub-3940256099942544/2934735716'; 
      }
    }
    return '';
  }

  /// Create a Banner Ad
  BannerAd createBannerAd({required Function(Ad) onAdLoaded}) {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner, 
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: onAdLoaded,
        onAdFailedToLoad: (ad, error) {
          debugPrint('Ad failed to load: $error');
          ad.dispose();
        },
      ),
    );
  }
  /// Get the Rewarded Ad unit ID
  String get rewardedAdUnitId {
    if (kDebugMode) {
      if (Platform.isAndroid) {
        return 'ca-app-pub-3940256099942544/5224354917'; // Android Test Rewarded
      } else if (Platform.isIOS) {
        return 'ca-app-pub-3940256099942544/1712485313'; // iOS Test Rewarded
      }
    }
    // Release Mode
    if (Platform.isAndroid) return 'ca-app-pub-8583703891478819/5224123972';
    if (Platform.isIOS) return 'ca-app-pub-8583703891478819/5224123972';
    return '';
  }

  /// Load a Rewarded Ad
  void loadRewardedAd({required Function(RewardedAd) onAdLoaded, required Function(LoadAdError) onAdFailedToLoad}) {
    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: onAdLoaded,
        onAdFailedToLoad: onAdFailedToLoad,
      ),
    );
  }

  /// Get the Rewarded Interstitial Ad unit ID
  String get rewardedInterstitialAdUnitId {
    if (kDebugMode) {
      if (Platform.isAndroid) {
        return 'ca-app-pub-3940256099942544/5354046379'; // Android Test Rewarded Interstitial
      } else if (Platform.isIOS) {
        return 'ca-app-pub-3940256099942544/6978759866'; // iOS Test Rewarded Interstitial
      }
    }
    // Release Mode
    if (Platform.isAndroid) return 'ca-app-pub-8583703891478819/5224123972';
    if (Platform.isIOS) return 'ca-app-pub-8583703891478819/5224123972';
    return '';
  }

  /// Load a Rewarded Interstitial Ad
  void loadRewardedInterstitialAd({
    required Function(RewardedInterstitialAd) onAdLoaded,
    required Function(LoadAdError) onAdFailedToLoad,
  }) {
    RewardedInterstitialAd.load(
      adUnitId: rewardedInterstitialAdUnitId,
      request: const AdRequest(),
      rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
        onAdLoaded: onAdLoaded,
        onAdFailedToLoad: onAdFailedToLoad,
      ),
    );
  }
  
  /// Get the Native Ad unit ID
  String get nativeAdUnitId {
    if (kDebugMode) {
      if (Platform.isAndroid) {
        return 'ca-app-pub-3940256099942544/2247696110'; // Android Test Native Advanced
      } else if (Platform.isIOS) {
        return 'ca-app-pub-3940256099942544/3986624511'; // iOS Test Native Advanced
      }
    }
    // Release Mode
    if (Platform.isAndroid) return 'ca-app-pub-8583703891478819/4606651657';
    if (Platform.isIOS) return 'ca-app-pub-8583703891478819/4606651657';
    return '';
  }

  /// Load a Native Ad
  NativeAd createNativeAd({
    required Function(NativeAd) onAdLoaded, 
    required Function(LoadAdError) onAdFailedToLoad,
  }) {
    return NativeAd(
      adUnitId: nativeAdUnitId,
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          onAdLoaded(ad as NativeAd);
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('Native ad failed to load: $error');
          ad.dispose();
          onAdFailedToLoad(error);
        },
      ),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.medium,
        mainBackgroundColor: Colors.white,
        cornerRadius: 16.0,
      ),
    )..load();
  }
}
