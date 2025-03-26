import 'package:flutter/material.dart';
import '../../core/app_export.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
      body: SingleChildScrollView(
        physics: ClampingScrollPhysics(),
        child: Stack(
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
              padding: EdgeInsets.fromLTRB(16.h, 16.h, 16.h, 32.h),
              child: Column(
                children: [
                  SizedBox(height: 85.h), // Reduced by 25 pixels from 110.h
                  _buildHeaderText(),
                  SizedBox(height: 24.h),
                  _buildSubscriptionOptions(),
                  SizedBox(height: 24.h),
                  _buildSubscriptionNotice(),
                  SizedBox(height: 24.h),
                  _buildSubscribeButton(),
                  SizedBox(height: 16.h),
                  _buildSecurityNote(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderText() {
    return Column(
      children: [
        SvgPicture.asset(
          'assets/images/gift_box.svg',
          height: 120.h,
          width: 120.h,
        ),
        SizedBox(height: 24.h),
        Text(
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
        SizedBox(height: 16.h),
        Text(
          "LinguaX is designed to help you master Arabic faster through immersive reading and listening.\n\nBy subscribing, you're not just unlocking the app—you're supporting its growth and helping us build the best language learning experience.",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w500,
            fontSize: 14.fSize,
            color: Color(0xFF80706B),
          ),
          softWrap: true,
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
          height: 88.h,
        ),
        SizedBox(height: 16.h),
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
          height: 88.h,
        ),
      ],
    );
  }

  Widget _buildSubscriptionOption({
    required String title,
    required String price,
    required bool isSelected,
    required VoidCallback onTap,
    required double height,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: height,
        padding: EdgeInsets.symmetric(horizontal: 20.h, vertical: 12.h),
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
                      fontWeight: FontWeight.w600,
                      fontSize: 16.fSize,
                      color: Color(0xFF37251F),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    price,
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w700,
                      fontSize: 18.fSize,
                      color: Color(0xFFFF6F3E),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.h),
            Container(
              width: 26.h,
              height: 26.h,
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
                      size: 16.h,
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
      height: 55.h,
      padding: EdgeInsets.only(bottom: 4.h),
      decoration: BoxDecoration(
        color: Color(0xFFD84918), // Deep orange outer frame
        borderRadius: BorderRadius.circular(12.h),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFFFF6F3E), // Inner orange content wrapper
          borderRadius: BorderRadius.circular(12.h),
        ),
        child: TextButton(
          onPressed: () {
            // Handle subscription
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Subscription processed. Thank you!')),
            );
            Navigator.pop(context);
          },
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.h),
            backgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.h),
            ),
            minimumSize: Size(double.infinity, 0),
          ),
          child: FittedBox(
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
          size: 16.h,
          color: Color(0xFF80706B),
        ),
        SizedBox(width: 8.h),
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
} 