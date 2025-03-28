import 'dart:io';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';

class ProductConnectionTest extends StatefulWidget {
  const ProductConnectionTest({Key? key}) : super(key: key);

  @override
  _ProductConnectionTestState createState() => _ProductConnectionTestState();
}

class _ProductConnectionTestState extends State<ProductConnectionTest> {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  List<ProductDetails> _products = [];
  bool _isLoading = true;
  String _statusMessage = 'Initializing...';
  bool _isAvailable = false;
  
  // Product IDs
  static const String monthlyProductId = 'com.linguax.subscription.monthly';
  static const String lifetimeProductId = 'com.linguax.subscription.lifetimeaccess';

  @override
  void initState() {
    super.initState();
    _initStore();
  }

  Future<void> _initStore() async {
    setState(() {
      _statusMessage = 'Checking store availability...';
    });

    _isAvailable = await _inAppPurchase.isAvailable();
    
    if (!_isAvailable) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Store is not available';
      });
      return;
    }

    setState(() {
      _statusMessage = 'Store is available. Checking StoreKit configuration...';
    });
    
    if (Platform.isIOS) {
      final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
          _inAppPurchase.getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      
      await iosPlatformAddition.setDelegate(TestPaymentQueueDelegate());
      
      setState(() {
        _statusMessage = 'StoreKit delegate configured. Loading products...';
      });
    }
    
    await _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _statusMessage = 'Querying product details...';
    });
    
    final Set<String> productIds = <String>{
      monthlyProductId,
      lifetimeProductId,
    };
    
    try {
      final ProductDetailsResponse response = 
          await _inAppPurchase.queryProductDetails(productIds);
      
      setState(() {
        _isLoading = false;
        _products = response.productDetails;
        
        if (response.notFoundIDs.isNotEmpty) {
          _statusMessage = 'Some products not found: ${response.notFoundIDs.join(", ")}';
        } else if (response.productDetails.isEmpty) {
          _statusMessage = 'No products found. Check App Store Connect configuration.';
        } else {
          _statusMessage = 'Found ${_products.length} products. Connection successful!';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Error loading products: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Store Connection Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: _isAvailable ? Colors.green[100] : Colors.red[100],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Store Available: ${_isAvailable ? 'Yes' : 'No'}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Status: $_statusMessage'),
                    if (Platform.isIOS)
                      Text(
                        'Environment: ${_isDebugMode() ? "Sandbox" : "Production"}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _isDebugMode() ? Colors.blue[800] : Colors.black,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Products (${_products.length}):',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _products.isEmpty
                      ? Center(
                          child: Text(
                            'No products found',
                            style: TextStyle(color: Colors.red[800]),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _products.length,
                          itemBuilder: (context, index) {
                            final product = _products[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                title: Text(product.title),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('ID: ${product.id}'),
                                    Text('Description: ${product.description}'),
                                    Text('Price: ${product.price}'),
                                  ],
                                ),
                                isThreeLine: true,
                              ),
                            );
                          },
                        ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _loadProducts,
              child: const Text('Refresh Products'),
            ),
          ],
        ),
      ),
    );
  }
  
  bool _isDebugMode() {
    bool inDebugMode = false;
    assert(inDebugMode = true);
    return inDebugMode;
  }
}

class TestPaymentQueueDelegate implements SKPaymentQueueDelegateWrapper {
  @override
  bool shouldContinueTransaction(
      SKPaymentTransactionWrapper transaction, SKStorefrontWrapper storefront) {
    return true;
  }

  @override
  bool shouldShowPriceConsent() {
    return true;
  }
} 