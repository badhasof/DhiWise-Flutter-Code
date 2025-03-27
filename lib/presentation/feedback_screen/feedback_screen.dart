import 'package:flutter/material.dart';
import '../../core/app_export.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({Key? key}) : super(key: key);

  static Widget builder(BuildContext context) {
    return FeedbackScreen();
  }

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  int _selectedRating = 3; // Default to 3rd emoji (smile)
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _answer1Controller = TextEditingController();
  TextEditingController _answer2Controller = TextEditingController();
  TextEditingController _answer3Controller = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _answer1Controller.dispose();
    _answer2Controller.dispose();
    _answer3Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFF9F4),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.h),
          child: Column(
            children: [
              SizedBox(height: 24.h),
              _buildHeader(),
              SizedBox(height: 32.h),
              _buildEmojiRatings(),
              SizedBox(height: 32.h),
              _buildTextField("Name", _nameController),
              SizedBox(height: 16.h),
              _buildTextField("Email address", _emailController),
              SizedBox(height: 32.h),
              _buildQuestionField(
                1,
                "What was the most valuable or enjoyable feature you discovered?",
                _answer1Controller,
              ),
              SizedBox(height: 24.h),
              _buildQuestionField(
                2,
                "From the self demo, what didn't you like or enjoy? Please share any complaints you may have.",
                _answer2Controller,
              ),
              SizedBox(height: 24.h),
              _buildQuestionField(
                3,
                "As a valuable user and customer, what would you love to see in an app like this? Don't hold back.",
                _answer3Controller,
              ),
              SizedBox(height: 32.h),
              _buildSubmitButton(),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          "Rate your experience!",
          style: TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w800,
            fontSize: 24.fSize,
            color: Color(0xFF37251F),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          "The app is in beta stage and we are looking\nfor your valuable feedback",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w500,
            fontSize: 16.fSize,
            color: Color(0xFF80706B),
          ),
        ),
      ],
    );
  }

  Widget _buildEmojiRatings() {
    List<String> emojis = ["😞", "🙁", "😐", "🙂", "😊"];
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(
        emojis.length,
        (index) => _buildEmojiButton(emojis[index], index),
      ),
    );
  }

  Widget _buildEmojiButton(String emoji, int index) {
    bool isSelected = _selectedRating == index;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRating = index;
        });
      },
      child: Container(
        width: 50.h,
        height: 50.h,
        decoration: BoxDecoration(
          color: Color(0xFFEFECEB),
          shape: BoxShape.circle,
          border: isSelected ? Border.all(
            color: Color(0xFFFF6F3E),
            width: 2.h,
          ) : null,
        ),
        child: Center(
          child: ColorFiltered(
            colorFilter: isSelected 
              ? ColorFilter.mode(Colors.transparent, BlendMode.multiply) // No filter for selected
              : ColorFilter.matrix([
                  0.2126, 0.7152, 0.0722, 0, 0,
                  0.2126, 0.7152, 0.0722, 0, 0,
                  0.2126, 0.7152, 0.0722, 0, 0,
                  0, 0, 0, 1, 0,
                ]), // Grayscale filter for unselected
            child: Text(
              emoji,
              style: TextStyle(
                fontSize: 28.fSize,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.h),
        border: Border.all(
          color: Color(0xFFEFECEB),
          width: 1.h,
        ),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: hint,
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          contentPadding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 12.h),
          border: InputBorder.none,
          labelStyle: TextStyle(
            fontFamily: 'Lato',
            fontSize: 16.fSize,
            color: Color(0xFF80706B),
          ),
        ),
        style: TextStyle(
          fontFamily: 'Lato',
          fontSize: 16.fSize,
          color: Color(0xFF37251F),
        ),
      ),
    );
  }

  Widget _buildQuestionField(int number, String question, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32.h,
              height: 32.h,
              decoration: BoxDecoration(
                color: Color(0xFFFF6F3E),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  number.toString(),
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w700,
                    fontSize: 16.fSize,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.h),
            Expanded(
              child: Text(
                question,
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w600,
                  fontSize: 16.fSize,
                  color: Color(0xFF37251F),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.h),
            border: Border.all(
              color: Color(0xFFEFECEB),
              width: 1.h,
            ),
          ),
          height: 100.h,
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: "",
              contentPadding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 12.h),
              border: InputBorder.none,
            ),
            style: TextStyle(
              fontFamily: 'Lato',
              fontSize: 16.fSize,
              color: Color(0xFF37251F),
            ),
            maxLines: null,
            expands: true,
            textAlign: TextAlign.justify,
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.maxFinite,
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
            // Submit feedback
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Feedback submitted. Thank you!')),
            );
            
            // Navigate to subscription/pricing screen
            Future.delayed(Duration(milliseconds: 1500), () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.subscriptionScreen,
                (route) => false,
              );
            });
          },
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.h),
            backgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.h),
            ),
            minimumSize: Size(double.infinity, 0),
          ),
          child: Text(
            "Send feedback",
            style: TextStyle(
              fontFamily: 'Lato',
              fontWeight: FontWeight.w700,
              fontSize: 16.fSize,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
} 