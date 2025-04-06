# RevenueCat Store Integration Guide

This guide provides instructions for setting up RevenueCat with App Store Connect (iOS) and Google Play Console (Android) for LinguaX.

## App Store Connect Integration (iOS)

### 1. Create App-Specific Shared Secret

1. Log in to [App Store Connect](https://appstoreconnect.apple.com/)
2. Navigate to **My Apps** > **[Your App]** > **App Information**
3. Find the **App-Specific Shared Secret** section and click **Generate**
4. Copy the generated secret (it will only be shown once)

### 2. Connect to RevenueCat

1. Log in to [RevenueCat Dashboard](https://app.revenuecat.com/)
2. Navigate to **Project Settings** > **App Store Connect**
3. Enter your **App-Specific Shared Secret** in the provided field
4. Click **Connect App Store**

### 3. Configure IAP Products in App Store Connect

1. In App Store Connect, go to **My Apps** > **[Your App]** > **Features** > **In-App Purchases**
2. Click the **+** button to add new in-app purchases
3. For LinguaX, create the following products:
   - **Auto-Renewable Subscription**: Monthly Premium
   - **Non-Consumable**: Lifetime Access
4. For each product, configure:
   - Reference Name (internal only)
   - Product ID (use the same IDs configured in RevenueCat)
   - Pricing
   - Subscription duration
   - Localized information (display name, description)

### 4. Create Subscription Group

1. When creating the first auto-renewable subscription, you'll be prompted to create a Subscription Group
2. Name the group "LinguaX Premium"
3. Add the monthly subscription option to this group
4. Set up subscription tiers if offering different levels of service

### 5. Set Up App Store Server Notifications

1. In App Store Connect, go to **My Apps** > **[Your App]** > **App Information**
2. Under **App Store Server Notifications**, select **Production Server URL**
3. Enter the RevenueCat server URL: `https://api.revenuecat.com/v1/receipts/apple`

## Google Play Console Integration (Android)

### 1. Create Service Account

1. Log in to [Google Play Console](https://play.google.com/console/)
2. Navigate to **Settings** > **Developer account** > **API access**
3. Click **Create Service Account**
4. Follow the link to the Google Cloud Platform
5. Create a new service account with a descriptive name (e.g., "RevenueCat Integration")
6. Grant the service account the **Service Account User** role
7. Create a new JSON key and download it (keep this secure!)

### 2. Connect to RevenueCat

1. Log in to [RevenueCat Dashboard](https://app.revenuecat.com/)
2. Navigate to **Project Settings** > **Google Play**
3. Upload the JSON key file you downloaded
4. Click **Connect Google Play**

### 3. Configure IAP Products in Google Play Console

1. In Google Play Console, go to **All apps** > **[Your App]** > **Monetize** > **Products** > **In-app products**
2. Click **Create subscription** to add new subscription products and **Create managed product** for one-time purchases
3. For LinguaX, create the following products:
   - Monthly Premium Subscription
   - Lifetime Access (as a one-time purchase)
4. For each product, configure:
   - Product ID (use the same IDs configured in RevenueCat)
   - Name
   - Description
   - Price
   - Subscription period (for subscription)

### 4. Set Up Real-Time Developer Notifications

1. In Google Play Console, go to **All apps** > **[Your App]** > **Monetize** > **Monetization setup**
2. Under **Real-time developer notifications**, click **Edit**
3. Enter the RevenueCat server URL: `https://api.revenuecat.com/v1/receipts/google/rtdn`

## Testing Subscriptions

### iOS Sandbox Testing

1. Create sandbox testers in App Store Connect:
   - Go to **Users and Access** > **Sandbox** > **Testers**
   - Click **+** to add a new sandbox tester
   - Fill in the required information

2. On a test device:
   - Sign out of the App Store
   - Sign in with the sandbox tester account
   - Make test purchases in your app

### Android Testing

1. Create a test track in Google Play Console:
   - Go to **Testing** > **Internal testing**
   - Create a release and upload your APK
   - Add testers via email

2. Set up test accounts:
   - Go to **Settings** > **License Testing**
   - Add test accounts (email addresses)
   - These accounts will not be charged for purchases

## Troubleshooting

### Common iOS Issues

- **Purchases don't complete**: Verify the sandbox tester account is properly set up
- **Missing products**: Ensure products are approved in App Store Connect
- **Receipt validation fails**: Check that the shared secret is correctly entered in RevenueCat

### Common Android Issues

- **Products not showing**: Check that products have the correct status in Google Play Console
- **Authentication failures**: Verify the service account has proper permissions
- **Purchase failures**: Make sure test accounts are properly configured for license testing

## Product IDs Reference

For LinguaX, use the following product IDs:

- iOS:
  - Monthly: `com.linguax.subscription.monthly`
  - Lifetime: `com.linguax.subscription.lifetimeaccess`

- Android:
  - Monthly: `com.linguax.subscription.monthly`
  - Lifetime: `com.linguax.subscription.lifetimeaccess`

These IDs should be consistent across both platforms and match the configuration in your RevenueCat dashboard. 