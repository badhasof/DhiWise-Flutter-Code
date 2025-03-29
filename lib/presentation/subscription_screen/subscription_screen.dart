import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../core/app_export.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../services/subscription_service.dart';
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
  
  // Subscription service instance
  final SubscriptionService _subscriptionService = SubscriptionService();
  
  // Subscription for purchase status updates
  StreamSubscription<PurchaseStatus>? _purchaseStatusSubscription;

  @override
  void initState() {
    super.initState();
    _initializeSubscriptions();
  }
  
  Future<void> _initializeSubscriptions() async {
    setState(() {
      _isProcessingPurchase = true;
      _purchaseStatus = 'Loading products...';
    });
    
    // Initialize the subscription service
    await _subscriptionService.initialize();
    
    setState(() {
      _isProcessingPurchase = false;
      _purchaseStatus = _subscriptionService.products.isEmpty ? 
        'No subscription products found. Pull down to refresh.' : '';
    });
    
    // Listen for purchase status updates
    _purchaseStatusSubscription = _subscriptionService.purchaseStatusStream.listen((status) {
      setState(() {
        _isProcessingPurchase = status == PurchaseStatus.pending;
        
        // Update status message
        switch(status) {
          case PurchaseStatus.pending:
            _purchaseStatus = 'Processing purchase...';
            break;
          case PurchaseStatus.purchased:
            _purchaseStatus = 'Purchase successful!';
            break;
          case PurchaseStatus.restored:
            _purchaseStatus = 'Purchase restored!';
            break;
          case PurchaseStatus.error:
            // Check if we have detailed error information from our custom error stream
            final errorDetails = _subscriptionService.lastErrorDetails;
            if (errorDetails != null && 
                errorDetails.containsKey('domain') && 
                errorDetails.containsKey('code')) {
              
              // Handle specific error types with better messages
              if (errorDetails['domain'] == 'ASDErrorDomain' && errorDetails['code'] == 500) {
                _purchaseStatus = 'Purchase could not be completed. Please check your App Store account settings and try again later.';
              } else if (errorDetails['domain'] == 'SKErrorDomain') {
                // Handle SKErrorDomain errors with specific messages
                switch (errorDetails['code']) {
                  case 0: // Unknown error
                    _purchaseStatus = 'An unexpected error occurred. Please try again later.';
                    break;
                  case 2: // Payment cancelled
                    _purchaseStatus = 'Purchase was cancelled.';
                    break;
                  case 4: // Payment not allowed
                    _purchaseStatus = 'Your device is not allowed to make payments. Please check your restrictions.';
                    break;
                  default:
                    _purchaseStatus = 'Error occurred during purchase. Please try again later.';
                }
              } else {
                _purchaseStatus = 'Error occurred during purchase. Please try again later.';
              }
            } else {
              _purchaseStatus = 'Error occurred during purchase. Please try again later.';
            }
            break;
          case PurchaseStatus.canceled:
            _purchaseStatus = 'Purchase canceled.';
            break;
        }
      });
      
      // Show success snackbar if purchase was successful
      if (status == PurchaseStatus.purchased || status == PurchaseStatus.restored) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Subscription processed. Thank you!')),
        );
        
        // Navigate back after successful purchase
        Future.delayed(Duration(seconds: 2), () {
          Navigator.pop(context);
        });
      } else if (status == PurchaseStatus.error) {
        // Show error snackbar with more specific messaging
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_purchaseStatus),
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
    });
  }
  
  @override
  void dispose() {
    _purchaseStatusSubscription?.cancel();
    super.dispose();
  }

  Future<void> _refreshProducts() async {
    setState(() {
      _isProcessingPurchase = true;
      _purchaseStatus = 'Refreshing products...';
    });
    
    await _subscriptionService.loadProducts();
    
    setState(() {
      _isProcessingPurchase = false;
      _purchaseStatus = _subscriptionService.products.isEmpty ? 
        'No subscription products found. Try again later.' : 'Products refreshed';
        
      // Clear the status message after a delay if products were found
      if (_subscriptionService.products.isNotEmpty) {
        Future.delayed(Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _purchaseStatus = '';
            });
          }
        });
      }
    });
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
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Color(0xFF37251F)),
            onPressed: _isProcessingPurchase ? null : _refreshProducts,
          ),
        ],
        title: null,
        centerTitle: false,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshProducts,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Calculate spacing based on available height
              final availableHeight = MediaQuery.of(context).size.height;
              final topPadding = MediaQuery.of(context).padding.top;
              final effectiveHeight = availableHeight - topPadding - 8.h;
              
              // Adjust spacing based on screen height
              final initialSpacing = effectiveHeight > 700 ? 60.h : 52.h;
              final standardSpacing = effectiveHeight > 700 ? 18.h : 14.h;
              
              return Stack(
                alignment: Alignment.topCenter,
                children: [
                  // Background wave SVG positioned at the top
                  Positioned(
                    top: -1, // Negative value to ensure it covers the top edge
                    left: -200, // Move SVG 200px to the left
                    right: 0,
                    child: SvgPicture.asset(
                      'assets/images/background_wave.svg',
                      width: MediaQuery.of(context).size.width + 200, // Increase width to maintain coverage
                      fit: BoxFit.fitWidth,
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
                        width: 500.h,
                        height: 500.h,
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
                        _buildHeaderText(),
                        SizedBox(height: standardSpacing),
                        _buildSubscriptionOptions(),
                        SizedBox(height: standardSpacing),
                        _buildSubscriptionNotice(),
                        SizedBox(height: standardSpacing),
                        _buildSubscribeButton(),
                        SizedBox(height: 12.h),
                        _buildSecurityNote(),
                        
                        // Status message
                        if (_purchaseStatus.isNotEmpty) ...[
                          SizedBox(height: 12.h),
                          Text(
                            _purchaseStatus,
                            style: TextStyle(
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.w500,
                              fontSize: 15.fSize,
                              color: _purchaseStatus.contains('Error') || _purchaseStatus.contains('canceled') 
                                  ? Colors.red 
                                  : Color(0xFF80706B),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                        
                        // Restore purchases button
                        SizedBox(height: 20.h),
                        TextButton(
                          onPressed: _isProcessingPurchase 
                              ? null 
                              : () => _restorePurchases(),
                          child: Text(
                            'Restore purchases',
                            style: TextStyle(
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.w500,
                              fontSize: 15.fSize,
                              color: Color(0xFF80706B),
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        
                        // Debug product test button (only visible in debug mode)
                        SizedBox(height: 10.h),
                        if (kDebugMode) 
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, AppRoutes.productTestScreen);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[300],
                              foregroundColor: Colors.black87,
                            ),
                            child: Text(
                              'Debug: Test Products',
                              style: TextStyle(
                                fontFamily: 'Lato',
                                fontWeight: FontWeight.w500,
                                fontSize: 14.fSize,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              );
            }
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderText() {
    return Column(
      children: [
        SvgPicture.asset(
          'assets/images/gift_box.svg',
          height: 115.h,
          width: 115.h,
        ),
        SizedBox(height: 20.h),
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
                fontSize: 24.fSize,
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
              fontSize: 15.fSize,
              color: Color(0xFF80706B),
            ),
            softWrap: true,
          ),
        ),
      ],
    );
  }

  Widget _buildSubscriptionOptions() {
    return Column(
      children: [
        // Lifetime option
        _buildSubscriptionOption(
          title: "Lifetime Access",
          price: "\$ 29.99",
          isSelected: !_isMonthlySelected,
          onTap: () {
            setState(() {
              _isMonthlySelected = false;
            });
          },
        ),
        SizedBox(height: 18.h),
        // Monthly option
        _buildSubscriptionOption(
          title: "Monthly",
          price: "\$ 2.99/month",
          isSelected: _isMonthlySelected,
          onTap: () {
            setState(() {
              _isMonthlySelected = true;
            });
          },
        ),
      ],
    );
  }

  Widget _buildSubscriptionOption({
    required String title,
    required String price,
    required bool isSelected,
    required VoidCallback onTap,
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
              offset: Offset(0, 4),
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
                      fontSize: 18.fSize,
                      color: Color(0xFF37251F),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    price,
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w800,
                      fontSize: 18.fSize,
                      color: Color(0xFFFF6F3E),
                      height: 1.0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.visible,
                  ),
                ],
              ),
            ),
            SizedBox(width: 16.h),
            Container(
              width: 30.h,
              height: 30.h,
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
                      size: 17.h,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionNotice() {
    return Text(
      "Subscribe today and you'll be charged\n\$${_isMonthlySelected ? '2.99' : '29.99'} ${_isMonthlySelected ? 'per month' : ''}. ${_isMonthlySelected ? 'Cancel anytime.' : ''}",
      textAlign: TextAlign.center,
      style: TextStyle(
        fontFamily: 'Lato',
        fontWeight: FontWeight.w500,
        fontSize: 16.fSize,
        color: Color(0xFF80706B),
      ),
    );
  }

  Widget _buildSubscribeButton() {
    return Container(
      width: double.maxFinite,
      height: 48.h,
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
                      fontSize: 15.fSize,
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
          size: 16.h,
          color: Color(0xFF80706B),
        ),
        SizedBox(width: 8.h),
        Text(
          "Secured by the App Store",
          style: TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w500,
            fontSize: 15.fSize,
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
      
      // Check if products are available
      if (_subscriptionService.products.isEmpty) {
        setState(() {
          _isProcessingPurchase = false;
          _purchaseStatus = 'No products available. Try refreshing first.';
        });
        
        // Show a toast or snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please refresh products before purchasing')),
        );
        
        return;
      }
      
      // Get the product ID based on selection
      final String productId = _isMonthlySelected 
          ? SubscriptionService.monthlyProductId 
          : SubscriptionService.lifetimeProductId;
      
      setState(() {
        _purchaseStatus = 'Starting purchase flow...';
      });
      
      // Purchase the selected product
      await _subscriptionService.purchaseProduct(productId);
      
      // We don't set _isProcessingPurchase to false here since 
      // the purchase status listener will handle that
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
  
  // Restore previous purchases
  Future<void> _restorePurchases() async {
    try {
      setState(() {
        _purchaseStatus = 'Restoring purchases...';
        _isProcessingPurchase = true;
      });
      
      await _subscriptionService.restorePurchases();
    } catch (e) {
      setState(() {
        _isProcessingPurchase = false;
        _purchaseStatus = 'Error restoring purchases: ${e.toString()}';
      });
    }
  }
} 