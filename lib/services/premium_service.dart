import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PremiumService {
  
  // Singleton
  PremiumService._internal();
  static final PremiumService instance = PremiumService._internal();

  static const String _premiumKey = '_isPremium';
  final InAppPurchase _iap = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  bool _isPremium = false;
  bool get isPremium => _isPremium;

  // initialize the service
  Future<void> init() async {
    // Load premium flag from local storage
    final prefs = await SharedPreferences.getInstance();
    _isPremium = prefs.getBool(_premiumKey) ?? false; // True for premium, false for not
    // listen to purchase updates
    _subscription = _iap.purchaseStream.listen(_onPurchaseUpdated, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      debugPrint('Purchase stream error: $error');
    });
  }

  // set premium flag locally
  Future<void> _setPremium(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_premiumKey, value);
    _isPremium = value;
  }

  // start the purchase flow
  Future<void> buyPremium() async {
    final available = await _iap.isAvailable();
    if (!available) {
      debugPrint('IAP not available');
      return;
    }

    const Set<String> _kIds = {'com.cii.renomate.premium'}; // TODO: replace with product ID
    final response = await _iap.queryProductDetails(_kIds);
    if (response.notFoundIDs.isNotEmpty) {
      debugPrint('Product not found: ${response.notFoundIDs}');
      return;
    }

    final product = response.productDetails.first;
    final purchaseParam = PurchaseParam(productDetails: product);

    _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  // restore purchases (important for IOS)
  Future<void> restorePurchases() async {
    await _iap.restorePurchases();
  }

  // handle purchase updates
  Future<void> _onPurchaseUpdated(List<PurchaseDetails> purchases) async {
    for (var purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        // verify purchase if needed (optional for offline apps)
        await _setPremium(true);
        debugPrint('Purchase successful: ${purchase.productID}');
      } else if (purchase.status == PurchaseStatus.error) {
        debugPrint('Purchase error: ${purchase.error}');
      }
    }
  }

  // dispose the stream subscription
  void dispose() {
    _subscription.cancel();
  }
}