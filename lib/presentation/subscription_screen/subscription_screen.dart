import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/app_export.dart';
import '../../services/revenuecat_service.dart';
import '../../services/revenuecat_offering_manager.dart';
import '../../services/subscription_status_manager.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({Key? key}) : super(key: key);

  static Widget builder(BuildContext context) {
    return SubscriptionScreen();
  }

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  bool _isMonthlySelected = true;
  bool _isProcessingPurchase = false;
  String _purchaseStatus = '';
  
  // New RevenueCat offering manager
  final RevenueCatOfferingManager _revenueCatManager = RevenueCatOfferingManager();
  
  // Cache of available packages
  Package? _monthlyPackage;
  Package? _lifetimePackage;
  
  @override
  void initState() {
    super.initState();
    // Load products immediately when screen is displayed
    _initializeSubscriptions();
    
    // Set a timer to retry if initial loading fails
    Future.delayed(Duration(seconds: 5), () {
      if (mounted && (_monthlyPackage == null && _lifetimePackage == null) && _isProcessingPurchase) {
        debugPrint('⚠️ Initial loading taking longer than expected, setting timeout...');
        
        // If still processing after 10 seconds, show retry option
        Future.delayed(Duration(seconds: 5), () {
          if (mounted && (_monthlyPackage == null && _lifetimePackage == null) && _isProcessingPurchase) {
            setState(() {
              _isProcessingPurchase = false;
              _purchaseStatus = 'Product loading timed out. Please tap Retry to try again.';
            });
          }
        });
      }
    });
  }
  
  Future<void> _initializeSubscriptions() async {
    setState(() {
      _isProcessingPurchase = true;
      _purchaseStatus = '';
    });
    
    try {
      debugPrint('🔄 Fetching subscription products...');
      final stopwatch = Stopwatch()..start();
      
      // Add a timeout to the offerings fetch
      final offerings = await _revenueCatManager.fetchAndDisplayOfferings().timeout(
        Duration(seconds: 15),
        onTimeout: () {
          debugPrint('⏱️ TIMEOUT: Offerings fetch took too long');
          throw TimeoutException('Offerings fetch timed out after 15 seconds');
        }
      );
      
      stopwatch.stop();
      debugPrint('⏱️ Products fetch completed in ${stopwatch.elapsedMilliseconds}ms');
      
      if (offerings != null && offerings.current != null) {
        // Get packages and check if they were successfully retrieved
        final monthlyPackage = _revenueCatManager.getMonthlyPackage();
        final lifetimePackage = _revenueCatManager.getLifetimePackage();
        
        // Debug packages found
        debugPrint('📦 Monthly package: ${monthlyPackage?.identifier ?? "null"}');
        debugPrint('📦 Lifetime package: ${lifetimePackage?.identifier ?? "null"}');
        
        setState(() {
          _monthlyPackage = monthlyPackage;
          _lifetimePackage = lifetimePackage;
          _isProcessingPurchase = false;
          
          if (monthlyPackage == null && lifetimePackage == null) {
            _purchaseStatus = 'No subscription products found. Try refreshing.';
          } else {
            _purchaseStatus = '';
            
            // If only one type of package is available, pre-select it
            if (monthlyPackage != null && lifetimePackage == null) {
              _isMonthlySelected = true;
            } else if (monthlyPackage == null && lifetimePackage != null) {
              _isMonthlySelected = false;
            }
          }
          
          // Clear the status message after a delay if products were found
          if (monthlyPackage != null || lifetimePackage != null) {
            Future.delayed(Duration(seconds: 2), () {
              if (mounted) {
                setState(() {
                  _purchaseStatus = '';
                });
              }
            });
          }
        });
      } else {
        debugPrint('❌ No valid offerings found');
        setState(() {
          _isProcessingPurchase = false;
          _purchaseStatus = 'No subscription products found. Tap Retry.';
        });
      }
    } on TimeoutException {
      debugPrint('⏱️ Product loading timed out');
      setState(() {
        _isProcessingPurchase = false;
        _purchaseStatus = 'Loading timed out. Please check your connection and tap Retry.';
      });
    } catch (e) {
      debugPrint('❌ Error loading products: $e');
      setState(() {
        _isProcessingPurchase = false;
        _purchaseStatus = 'Error loading products. Please tap Retry.';
      });
    }
  }
  
  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _refreshProducts() async {
    // Show progress immediately
    setState(() {
      _isProcessingPurchase = true;
      _purchaseStatus = '';
    });
    
    try {
      debugPrint('🔄 Refreshing subscription products...');
      final stopwatch = Stopwatch()..start();
      
      // Add timeout to the refresh call
      final offerings = await _revenueCatManager.fetchAndDisplayOfferings().timeout(
        Duration(seconds: 15),
        onTimeout: () {
          debugPrint('⏱️ TIMEOUT: Refresh took too long');
          throw TimeoutException('Product refresh timed out after 15 seconds');
        }
      );
      
      stopwatch.stop();
      debugPrint('⏱️ Products refresh completed in ${stopwatch.elapsedMilliseconds}ms');
      
      if (offerings != null && offerings.current != null) {
        // Get packages and check if they were successfully retrieved
        final monthlyPackage = _revenueCatManager.getMonthlyPackage();
        final lifetimePackage = _revenueCatManager.getLifetimePackage();
        
        // Debug packages found
        debugPrint('📦 Refreshed monthly package: ${monthlyPackage?.identifier ?? "null"}');
        debugPrint('📦 Refreshed lifetime package: ${lifetimePackage?.identifier ?? "null"}');
        
        setState(() {
          _monthlyPackage = monthlyPackage;
          _lifetimePackage = lifetimePackage;
          _isProcessingPurchase = false;
          
          if (monthlyPackage == null && lifetimePackage == null) {
            _purchaseStatus = 'No subscription products found. Try again later.';
          } else {
            _purchaseStatus = '';
            
            // If only one type of package is available, pre-select it
            if (monthlyPackage != null && lifetimePackage == null) {
              _isMonthlySelected = true;
            } else if (monthlyPackage == null && lifetimePackage != null) {
              _isMonthlySelected = false;
            }
          }
          
          // Clear the status message after a delay if products were found
          if (monthlyPackage != null || lifetimePackage != null) {
            Future.delayed(Duration(seconds: 2), () {
              if (mounted) {
                setState(() {
                  _purchaseStatus = '';
                });
              }
            });
          }
        });
      } else {
        setState(() {
          _isProcessingPurchase = false;
          _purchaseStatus = 'No subscription products found. Try again later.';
        });
      }
    } on TimeoutException {
      debugPrint('⏱️ Product refresh timed out');
      setState(() {
        _isProcessingPurchase = false;
        _purchaseStatus = 'Refresh timed out. Please check your connection and try again.';
      });
    } catch (e) {
      debugPrint('❌ Error refreshing products: $e');
      setState(() {
        _isProcessingPurchase = false;
        _purchaseStatus = 'Error refreshing products. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFF9F4),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Color(0xFF37251F)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: null,
        centerTitle: false,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Calculate spacing based on available height
            final availableHeight = constraints.maxHeight;
            final effectiveHeight = availableHeight - 8.h;
            
            // Adjust scaling factor based on screen height
            final scaleFactor = effectiveHeight / 700;
            final adjustedHeight = effectiveHeight > 700 ? 1.0 : 0.9;
            
            // Scale down spacing
            final initialSpacing = (effectiveHeight > 700 ? 42.h : 32.h) * adjustedHeight;
            final standardSpacing = (effectiveHeight > 700 ? 12.h : 8.h) * adjustedHeight;
            
            return Stack(
              alignment: Alignment.topCenter,
              children: [
                // Background wave SVG positioned at the top
                Positioned(
                  top: -20, // Move higher up to ensure it covers the top edge
                  left: -200, // Move SVG 200px to the left
                  right: 0,
                  child: Container(
                    width: MediaQuery.of(context).size.width + 300,
                    child: SvgPicture.asset(
                      'assets/images/background_wave.svg',
                      width: MediaQuery.of(context).size.width + 300,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                // Confetti decoration
                Positioned(
                  top: 20,
                  right: 0,
                  left: 0,
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/images/confetti.svg',
                      width: 480.h * adjustedHeight, // Increased from 450 to 480
                      height: 480.h * adjustedHeight, // Increased from 450 to 480
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                // Main content
                Padding(
                  padding: EdgeInsets.fromLTRB(16.h, 16.h, 16.h, 24.h),
                  child: Column(
                    children: [
                      SizedBox(height: initialSpacing),
                      _buildHeaderText(adjustedHeight),
                      SizedBox(height: standardSpacing),
                      Container(
                        margin: EdgeInsets.only(right: 12.h), // Add right margin to shift content left
                        child: _buildSubscriptionOptions(adjustedHeight),
                      ),
                      SizedBox(height: standardSpacing),
                      _buildSubscriptionNotice(),
                      SizedBox(height: standardSpacing),
                      _buildSubscribeButton(),
                      SizedBox(height: 8.h * adjustedHeight),
                      _buildSecurityNote(),
                      
                      // Status message
                      if (_purchaseStatus.isNotEmpty) ...[
                        SizedBox(height: 8.h * adjustedHeight),
                        Text(
                          _purchaseStatus,
                          style: TextStyle(
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w500,
                            fontSize: 15.fSize * adjustedHeight,
                            color: _purchaseStatus.contains('Error') || _purchaseStatus.contains('canceled') 
                                ? Colors.red 
                                : Color(0xFF80706B),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            );
          }
        ),
      ),
    );
  }

  Widget _buildHeaderText(double scale) {
    return Column(
      children: [
        SvgPicture.asset(
          'assets/images/gift_box.svg',
          height: 120.h * scale, // Increased from 110 to 120
          width: 120.h * scale, // Increased from 110 to 120
        ),
        SizedBox(height: 15.h * scale),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Container(
            constraints: BoxConstraints(maxWidth: 330.h),
            child: Text(
              "Support LinguaX & Start Your Arabic Learning Today",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Lato',
                fontWeight: FontWeight.w800,
                fontSize: 25.fSize * scale,
                color: Color(0xFF37251F),
              ),
              softWrap: true,
            ),
          ),
        ),
        SizedBox(height: 16.h),
        Container(
          constraints: BoxConstraints(maxWidth: 330.h),
          child: Text(
            "LinguaX is designed to help you master Arabic faster through immersive reading and listening.\n\nBy subscribing, you're supporting its growth and helping us build the best language learning experience.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Lato',
              fontWeight: FontWeight.w500,
              fontSize: 15.fSize * scale,
              color: Color(0xFF80706B),
            ),
            softWrap: true,
          ),
        ),
      ],
    );
  }

  Widget _buildSubscriptionOptions(double scale) {
    // Get pricing info from the package if available
    String lifetimePrice = "\$ 29.99";
    String monthlyPrice = "\$ 2.99/month";
    
    if (_revenueCatManager.getLifetimePackage() != null) {
      lifetimePrice = _revenueCatManager.getLifetimePackage()!.storeProduct.priceString;
    }
    
    if (_revenueCatManager.getMonthlyPackage() != null) {
      monthlyPrice = "${_revenueCatManager.getMonthlyPackage()!.storeProduct.priceString}/month";
    }
    
    return Column(
      children: [
        // Lifetime option
        _buildSubscriptionOption(
          title: "Lifetime Access",
          price: lifetimePrice,
          isSelected: !_isMonthlySelected,
          onTap: () {
            setState(() {
              _isMonthlySelected = false;
            });
          },
          scale: scale,
        ),
        SizedBox(height: 18.h),
        // Monthly option
        _buildSubscriptionOption(
          title: "Monthly",
          price: monthlyPrice,
          isSelected: _isMonthlySelected,
          onTap: () {
            setState(() {
              _isMonthlySelected = true;
            });
          },
          scale: scale,
        ),
      ],
    );
  }

  Widget _buildSubscriptionOption({
    required String title,
    required String price,
    required bool isSelected,
    required VoidCallback onTap,
    required double scale,
  }) {
    return GestureDetector(
      onTap: _isProcessingPurchase ? null : onTap,
      child: Container(
        width: double.infinity,
        height: 90.h,
        padding: EdgeInsets.symmetric(horizontal: 22.h, vertical: 15.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.h),
          border: Border.all(
            color: isSelected ? Color(0xFFFF9E71) : Color(0xFFEFECEB),
            width: isSelected ? 2.0.h : 1.0.h,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected ? Color(0xFFFF9E71) : Color(0xFFEFECEB),
              offset: Offset(0, 3), // Reduced from 4 to 3
              blurRadius: 0,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w700,
                      fontSize: 18.fSize * scale, // Increased from 17.fSize
                      color: Color(0xFF37251F),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h * scale), // Increased from 3.h
                  Text(
                    price,
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w800,
                      fontSize: 18.fSize * scale, // Increased from 17.fSize
                      color: Color(0xFFFF6F3E),
                      height: 1.0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.visible,
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.h * scale),
            Container(
              width: 28.h * scale, // Increased from 26.h
              height: 28.h * scale, // Increased from 26.h
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Color(0xFFFF9E71) : Color(0xFFEFECEB),
                  width: 1.5.h,
                ),
                color: isSelected ? Color(0xFFFF9E71) : Colors.white,
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16.h * scale, // Increased from 15.h
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionNotice() {
    // Extract just the price value (remove currency symbol)
    String price;
    
    if (_revenueCatManager.getMonthlyPackage() != null && _isMonthlySelected) {
      price = _revenueCatManager.getMonthlyPackage()!.storeProduct.priceString;
    } else if (_revenueCatManager.getLifetimePackage() != null && !_isMonthlySelected) {
      price = _revenueCatManager.getLifetimePackage()!.storeProduct.priceString;
    } else {
      // Fallback
      price = _isMonthlySelected ? "\$2.99" : "\$29.99";
    }
    
    // Shorter text that fits on two lines
    return Text(
      "Subscribe today for $price${_isMonthlySelected ? ' per month' : ''}. ${_isMonthlySelected ? 'Cancel anytime.' : ''}",
      textAlign: TextAlign.center,
      style: TextStyle(
        fontFamily: 'Lato',
        fontWeight: FontWeight.w500,
        fontSize: 14.fSize, // Reduced from 15.fSize
        color: Color(0xFF80706B),
      ),
    );
  }

  Widget _buildSubscribeButton() {
    return Container(
      width: double.maxFinite,
      height: 46.h,
      padding: EdgeInsets.only(bottom: 3.h),
      decoration: BoxDecoration(
        color: Color(0xFFD84918),
        borderRadius: BorderRadius.circular(10.h),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: _isProcessingPurchase ? Colors.grey : Color(0xFFFF6F3E),
          borderRadius: BorderRadius.circular(10.h),
        ),
        child: TextButton(
          onPressed: _isProcessingPurchase 
              ? null 
              : () => _processPurchase(),
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.h),
            backgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.h),
            ),
            minimumSize: Size(double.infinity, 0),
          ),
          child: _isProcessingPurchase
              ? SizedBox(
                  height: 20.h,
                  width: 20.h,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 2.h,
                  ),
                )
              : FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    "Subscribe now",
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w700,
                      fontSize: 16.fSize,
                      color: Colors.white,
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildSecurityNote() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.lock,
          size: 15.h,
          color: Color(0xFF80706B),
        ),
        SizedBox(width: 7.h),
        Text(
          "Secured by the App Store",
          style: TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w500,
            fontSize: 14.fSize,
            color: Color(0xFF80706B),
          ),
        ),
      ],
    );
  }
  
  // Process subscription purchase
  Future<void> _processPurchase() async {
    try {
      // Clear purchase status
      setState(() {
        _purchaseStatus = 'Preparing purchase...';
        _isProcessingPurchase = true;
      });
      
      // RevenueCat Purchase Flow
      
      // Check if packages are available
      Package? selectedPackage = _isMonthlySelected ? _monthlyPackage : _lifetimePackage;
      
      if (selectedPackage == null) {
        setState(() {
          _isProcessingPurchase = false;
          _purchaseStatus = 'Selected product not available. Try refreshing.';
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please refresh products before purchasing')),
        );
        return;
      }
      
      // Check if this is a lifetime purchase
      final bool isLifetime = !_isMonthlySelected;
      
      setState(() {
        _purchaseStatus = 'Starting purchase flow...';
      });
      
      // Purchase the selected package
      final result = await _revenueCatManager.purchasePackage(selectedPackage, isLifetime);
      
      setState(() {
        _isProcessingPurchase = false;
        _purchaseStatus = result.message;
      });
      
      if (result.success) {
        // Verify the subscription status after purchase
        await _verifySubscriptionStatusAfterPurchase(isLifetime);
        
        // Show success snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isLifetime 
            ? 'Lifetime access activated! Thank you for your support.'
            : 'Subscription activated. Thank you for your support!'))
        );
        
        // Navigate back after successful purchase
        Future.delayed(Duration(seconds: 2), () {
          Navigator.pop(context);
        });
      } else {
        // Show error in snackbar if it's not just a cancellation
        if (result.errorCode != PurchasesErrorCode.purchaseCancelledError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 5),
              action: SnackBarAction(
                label: 'Dismiss',
                textColor: Colors.white,
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
              ),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isProcessingPurchase = false;
        _purchaseStatus = 'Error: ${e.toString()}';
      });
      
      // Show error in snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Purchase failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  // Verify that subscription status was properly updated
  Future<void> _verifySubscriptionStatusAfterPurchase(bool isLifetime) async {
    try {
      // Double-check with RevenueCat that entitlements are active
      final customerInfo = await Purchases.getCustomerInfo();
      
      // Look for the Premium entitlement
      final isActive = customerInfo.entitlements.all['Premium']?.isActive ?? false;
      
      if (isActive) {
        debugPrint('✅ Verification confirms Premium access is active');
        
        // For lifetime purchases, check if the product ID indicates lifetime
        if (isLifetime) {
          final entitlement = customerInfo.entitlements.all['Premium'];
          if (entitlement != null) {
            final productId = entitlement.productIdentifier;
            debugPrint('📝 Premium entitlement product: $productId');
            
            if (productId.toLowerCase().contains('lifetime')) {
              debugPrint('✅ Confirmed lifetime product type');
            } else {
              debugPrint('⚠️ Product is active but does not appear to be lifetime');
            }
          }
        }
        
        // Force refresh of subscription status throughout the app
        await SubscriptionStatusManager.instance.checkSubscriptionStatus();
      } else {
        debugPrint('⚠️ Verification shows Premium access is NOT active - attempting to refresh');
        
        // One more attempt to refresh customer info
        await Future.delayed(Duration(seconds: 1));
        await Purchases.getCustomerInfo();
        await SubscriptionStatusManager.instance.checkSubscriptionStatus();
      }
    } catch (e) {
      debugPrint('❌ Error during subscription verification: $e');
    }
  }
} 