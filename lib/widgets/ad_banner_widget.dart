import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/ad_service.dart';

class AdBannerWidget extends StatefulWidget {
  const AdBannerWidget({super.key});

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    AdService().adsEnabled.addListener(_onAdsEnabledChanged);
    // Use Future.microtask to ensure context is available for MediaQuery
    Future.microtask(() => _onAdsEnabledChanged());
  }

  void _onAdsEnabledChanged() {
    if (!mounted) return;
    if (AdService().adsEnabled.value && _bannerAd == null) {
      _loadAd();
    }
    setState(() {});
  }

  void _loadAd() {
    _loadAdaptiveAd();
  }

  Future<void> _loadAdaptiveAd() async {
    final AdSize? size = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
      MediaQuery.of(context).size.width.truncate(),
    );

    if (size == null) {
      debugPrint('AdMob: Could not get adaptive banner size');
      return;
    }

    _bannerAd = AdService().createBannerAd(
      size: size,
      onAdLoaded: (ad) {
        if (!mounted) {
          ad.dispose();
          return;
        }
        setState(() {
          _isLoaded = true;
        });
      },
      onAdFailedToLoad: (ad, error) {
        if (!mounted) return;
        setState(() {
          _bannerAd = null;
          _isLoaded = false;
        });
      },
    )..load();
  }

  @override
  void dispose() {
    AdService().adsEnabled.removeListener(_onAdsEnabledChanged);
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!AdService().adsEnabled.value || _bannerAd == null || !_isLoaded) {
      return const SizedBox.shrink(); 
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      alignment: Alignment.center,
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
