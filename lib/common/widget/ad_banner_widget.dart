// lib/common/widget/ad_banner_widget.dart
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io';

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
    debugPrint('AdBannerWidget - initState called');
    _loadAd();
  }

  void _loadAd() {
    debugPrint('AdBannerWidget - Loading ad...');
    
    // 플랫폼별 광고 단위 ID 분기 (iOS는 실제 광고 단위)
    final adUnitId = Platform.isAndroid
        ? 'ca-app-pub-4542840362692423/4003152127' // Android 광고 단위 ID
        : 'ca-app-pub-4542840362692423/8125225348'; // iOS 실제 광고 단위 ID
    
    debugPrint('AdBannerWidget - Creating BannerAd with ID: $adUnitId');

    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          debugPrint('AdBannerWidget - Ad loaded successfully');
          if (mounted) {
            setState(() {
              _isLoaded = true;
              debugPrint('AdBannerWidget - State updated, isLoaded: $_isLoaded');
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('AdBannerWidget - Ad failed to load: ${error.message}');
          debugPrint('AdBannerWidget - Error code: ${error.code}');
          debugPrint('AdBannerWidget - Error domain: ${error.domain}');
          ad.dispose();
          _bannerAd = null;
        },
        onAdOpened: (_) => debugPrint('AdBannerWidget - Ad opened'),
        onAdClosed: (_) => debugPrint('AdBannerWidget - Ad closed'),
        onAdImpression: (_) => debugPrint('AdBannerWidget - Ad impression'),
      ),
    );

    debugPrint('AdBannerWidget - Calling load() on BannerAd');
    _bannerAd?.load();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('AdBannerWidget - build called, isLoaded: $_isLoaded, bannerAd: ${_bannerAd != null}');
    
    if (_bannerAd == null || !_isLoaded) {
      debugPrint('AdBannerWidget - Returning empty container because ad is not ready');
      return Container(
        width: double.infinity,
        height: 50, // AdSize.banner의 기본 높이
        color: Colors.grey[200],
        child: const Center(
          child: Text('광고 로딩 중...', style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    debugPrint('AdBannerWidget - Returning ad container');
    return Container(
      width: double.infinity,
      height: _bannerAd!.size.height.toDouble(),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.grey[200],
      ),
      child: SizedBox(
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      ),
    );
  }

  @override
  void dispose() {
    debugPrint('AdBannerWidget - dispose called');
    _bannerAd?.dispose();
    _bannerAd = null;
    super.dispose();
  }
}
