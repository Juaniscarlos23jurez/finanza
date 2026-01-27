import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/ad_service.dart';

class NativeAdWidget extends StatefulWidget {
  const NativeAdWidget({super.key});

  @override
  State<NativeAdWidget> createState() => _NativeAdWidgetState();
}

class _NativeAdWidgetState extends State<NativeAdWidget> {
  NativeAd? _nativeAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    AdService().adsEnabled.addListener(_onAdsEnabledChanged);
    _onAdsEnabledChanged();
  }

  void _onAdsEnabledChanged() {
    if (!mounted) return;
    if (AdService().adsEnabled.value && _nativeAd == null) {
      _loadAd();
    }
    setState(() {});
  }

  void _loadAd() {
    _nativeAd = AdService().createNativeAd(
      onAdLoaded: (ad) {
        if (!mounted) {
          ad.dispose();
          return;
        }
        setState(() {
          _isLoaded = true;
        });
      },
      onAdFailedToLoad: (error) {
        debugPrint('Native ad load failed: $error');
        if (!mounted) return;
        setState(() {
          _nativeAd = null;
          _isLoaded = false;
        });
      },
    );
  }

  @override
  void dispose() {
    AdService().adsEnabled.removeListener(_onAdsEnabledChanged);
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!AdService().adsEnabled.value || _nativeAd == null || !_isLoaded) {
      return const SizedBox.shrink(); // Hide if disabled or not loaded
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: 300, // Native ads are typically taller
      child: AdWidget(ad: _nativeAd!),
    );
  }
}
