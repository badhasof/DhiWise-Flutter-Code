# RevenueCat Integration

## Overview
This project integrates RevenueCat for subscription management in the LinguaX Flutter application. RevenueCat provides cross-platform in-app purchase infrastructure, making it easier to manage subscriptions across iOS and Android platforms.

## Implementation Phases

### Phase 1: Setup and Configuration ✅
- Added RevenueCat SDK (`purchases_flutter` package)
- Setup API keys for iOS and Android
- Initialized RevenueCat SDK in the application
- Configured offering identifiers and entitlements

### Phase 2: Purchase Flow Implementation ✅
- Built UI to display subscription options
- Implemented purchase methods using RevenueCat API
- Added error handling and purchase state management
- Created offering manager to handle products and offerings

### Phase 3: User Access Management ✅
- Integrated RevenueCat with Firebase Auth for user identification
- Setup entitlement verification throughout the app
- Implemented trial period management

### Phase 4: Subscription Status and Store Integration ✅
- Created SubscriptionStatusManager for real-time subscription status tracking
- Added subscription management access via the platform's subscription management page
- Updated UI components to reflect subscription status
- Documented App Store Connect and Google Play Console integration

## Key Components

### 1. Main RevenueCat Services
- **RevenueCatService**: Core service for initializing the SDK and common operations
- **RevenueCatOfferingManager**: Manages offerings and products
- **SubscriptionStatusManager**: Tracks subscription status and updates throughout the app

### 2. User Interface Components
- **Subscription Screen**: Displays available plans for purchase
- **Settings Screen**: Offers subscription management and restoration options
- **CountdownTimerWidget**: Respects subscription status to show/hide trial timer

### 3. Firebase Integration
- Syncs subscription status with Firestore user documents
- Updates premium status flags throughout the app

## Usage Guide

### Basic Subscription Checking
```dart
// Check if user has active subscription
bool isSubscribed = await SubscriptionStatusManager.instance.checkSubscriptionStatus();

// Listen to subscription status changes
SubscriptionStatusManager.instance.subscriptionStatusStream.listen((isSubscribed) {
  // Update UI based on subscription status
});
```

### Making Purchases
```dart
// Get available offerings
final offerings = await RevenueCatOfferingManager.getOfferings();

// Purchase a product
await RevenueCatOfferingManager.purchasePackage(package);
```

### Subscription Management
```dart
// Open subscription management page
await SubscriptionStatusManager.instance.openSubscriptionManagement();

// Restore purchases
await SubscriptionStatusManager.instance.restorePurchases();
```

## Testing Subscriptions

### Sandbox Testing (iOS)
1. Use sandbox tester accounts created in App Store Connect
2. Sign out of the App Store on the test device
3. Sign in with the sandbox tester account
4. Make purchases in the app (you won't be charged)

### Testing on Android
1. Use test accounts configured in Google Play Console
2. Ensure test accounts are set up for license testing
3. Test purchases will not be charged

## Store Integration

See detailed instructions in the [Store Integration Guide](lib/docs/store_integration_guide.md) for:
- App Store Connect (iOS) setup
- Google Play Console (Android) setup
- Server-to-server notification configuration
- Testing environment setup

## Troubleshooting

### Common Issues
- **Products not showing**: Check product IDs match between RevenueCat dashboard and app stores
- **Purchases failing**: Verify sandbox/test accounts are correctly configured
- **Subscription status not updating**: Check listener implementation and network connectivity

For detailed store integration instructions, see [Store Integration Guide](lib/docs/store_integration_guide.md). 