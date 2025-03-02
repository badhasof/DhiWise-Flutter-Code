import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../core/app_export.dart';
import '../../core/utils/validation_functions.dart';


import '../../theme/custom_button_style.dart';
import '../../widgets/app_bar/appbar_leading_image.dart';
import '../../widgets/app_bar/appbar_title.dart';
import '../../widgets/app_bar/custom_app_bar.dart';
import '../../widgets/custom_elevated_button.dart';
import '../../widgets/custom_text_form_field.dart';
import 'bloc/sign_in_bloc.dart';
import 'models/sign_in_model.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

// ignore_for_file: must_be_immutable
class SignInScreen extends StatelessWidget {
  SignInScreen({Key? key})
      : super(
          key: key,
        );


  static Widget builder(BuildContext context) {
    return BlocProvider<SignInBloc>(
      create: (context) => SignInBloc(SignInState(
        signInModelObj: SignInModel(),
      ))
        ..add(SignInInitialEvent()),
      child: SignInScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.gray50,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Form(
          child: Container(
            width: double.maxFinite,
            margin: EdgeInsets.only(bottom: 32.h),
            child: SingleChildScrollView(
              child: Container(
                width: double.maxFinite,
                padding: EdgeInsets.only(top: 14.h),
                decoration: AppDecoration.fillGray,
                child: Column(
                  children: [
                    SizedBox(
                      width: double.maxFinite,
                      child: _buildAppBar(context),
                    ),
                    SizedBox(height: 22.h),
                    _buildUsernameField(context),
                    SizedBox(height: 16.h),
                    _buildPasswordField(context),
                    SizedBox(height: 24.h),
                    _buildSignInButton(context),
                    SizedBox(height: 24.h),
                    Text(
                      "Forgot Password",
                      style: CustomTextStyles.titleMediumDeeporangeA200,
                    ),
                    SizedBox(height: 138.h),
                    _buildGoogleSignInButton(context),
                    SizedBox(height: 12.h),
                    _buildFacebookSignInButton(context),
                    SizedBox(height: 12.h),
                    _buildAppleSignInButton(context),
                    SizedBox(height: 24.h),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "By signing in to LinguaX, you agree to our ",
                            style: CustomTextStyles.bodyMediumGray700,
                          ),
                          TextSpan(
                            text: "Terms of Service",
                            style: CustomTextStyles.titleSmallBold,
                          ),
                          TextSpan(
                            text: " and ",
                            style: CustomTextStyles.bodyMediumGray700,
                          ),
                          TextSpan(
                            text: "Privacy Policy",
                            style: CustomTextStyles.titleSmallBold,
                          )
                        ],
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Section Widget
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return CustomAppBar(
      height: 26.h,
      leadingWidth: 38.h,
      leading: AppbarLeadingImage(
        imagePath: ImageConstant.imgArrowDown,
        margin: EdgeInsets.only(left: 14.h),
      ),
      centerTitle: true,
      title: AppbarTitle(
        text: "Sign In",
      ),
    );
  }

  /// Section Widget
  Widget _buildUsernameField(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.h),
      child: BlocSelector<SignInBloc, SignInState, TextEditingController?>(
        selector: (state) => state.usernameFieldController,
        builder: (context, usernameFieldController) {
          return CustomTextFormField(
            controller: usernameFieldController,
            hintText: "Username or Email",
            hintStyle: CustomTextStyles.titleMediumGray500Medium,
            textInputType: TextInputType.emailAddress,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.h,
              vertical: 20.h,
            ),
            fillColor: theme.colorScheme.onPrimaryContainer,
            filled: true,
            borderDecoration: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.h),
              borderSide: BorderSide.none,
            ),
            validator: (value) {
              if (value == null || (!isValidEmail(value, isRequired: true))) {
                return "Please enter a valid email";
              }
              return null;
            },
          );
        },
      ),
    );
  }

  /// Section Widget
  Widget _buildPasswordField(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.h),
      child: BlocBuilder<SignInBloc, SignInState>(
        builder: (context, state) {
          return CustomTextFormField(
            controller: state.passwordFieldController,
            hintText: "Password",
            hintStyle: CustomTextStyles.titleMediumGray500Medium,
            textInputAction: TextInputAction.done,
            textInputType: TextInputType.visiblePassword,
            suffix: InkWell(
              onTap: () {
                context.read<SignInBloc>().add(ChangePasswordVisibilityEvent(
                    value: !state.isShowPassword));
              },
              child: Container(
                margin: EdgeInsets.symmetric(
                  horizontal: 16.h,
                  vertical: 20.h,
                ),
                child: CustomImageView(
                  imagePath: ImageConstant.imgSettingsGray500,
                  height: 24.h,
                  width: 24.h,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            suffixConstraints: BoxConstraints(
              maxHeight: 64.h,
            ),
            obscureText: state.isShowPassword,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.h,
              vertical: 20.h,
            ),
            fillColor: theme.colorScheme.onPrimaryContainer,
            filled: true,
            borderDecoration: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.h),
              borderSide: BorderSide.none,
            ),
            validator: (value) {
              if (value == null ||
                  (!isValidPassword(value, isRequired: true))) {
                return "Please enter a valid password";
              }
              return null;
            },
          );
        },
      ),
    );
  }

  /// Section Widget
  Widget _buildSignInButton(BuildContext context) {
    return CustomElevatedButton(
      height: 48.h,
      text: "Sign In",
      margin: EdgeInsets.symmetric(horizontal: 16.h),
      buttonStyle: CustomButtonStyles.fillDeepOrange,
      onPressed: () {
        _signInWithEmailPassword(context);
      },
    );
  }

  /// Section Widget
  Widget _buildGoogleSignInButton(BuildContext context) {
    return CustomElevatedButton(
      height: 48.h,
      text: "Sign in with Google",
      margin: EdgeInsets.symmetric(horizontal: 16.h),
      leftIcon: Container(
        margin: EdgeInsets.only(right: 8.h),
        child: CustomImageView(
          imagePath: ImageConstant.imgGoogle,
          height: 24.h,
          width: 24.h,
          fit: BoxFit.contain,
        ),
      ),
      buttonTextStyle: CustomTextStyles.titleMediumOnPrimary_1,
      onPressed: () {
        // Use the direct Google Sign-In method
        _signInWithGoogle(context);
      },
    );
  }

  /// Section Widget
  Widget _buildFacebookSignInButton(BuildContext context) {
    return CustomElevatedButton(
      height: 48.h,
      text: "Sign in with Facebook",
      margin: EdgeInsets.symmetric(horizontal: 16.h),
      leftIcon: Container(
        margin: EdgeInsets.only(right: 8.h),
        child: CustomImageView(
          imagePath: ImageConstant.imgFacebook,
          height: 24.h,
          width: 24.h,
          fit: BoxFit.contain,
        ),
      ),
      buttonTextStyle: CustomTextStyles.titleMediumOnPrimary_1,
      onPressed: () {
        _signInWithFacebook(context);
      },
    );
  }

  /// Section Widget
  Widget _buildAppleSignInButton(BuildContext context) {
    return CustomElevatedButton(
      height: 48.h,
      text: "Sign in with Apple",
      margin: EdgeInsets.symmetric(horizontal: 16.h),
      leftIcon: Container(
        margin: EdgeInsets.only(right: 8.h),
        child: CustomImageView(
          imagePath: ImageConstant.imgApple,
          height: 24.h,
          width: 24.h,
          fit: BoxFit.contain,
        ),
      ),
      buttonTextStyle: CustomTextStyles.titleMediumOnPrimary_1,
    );
  }

  // Firebase Authentication Methods
  void _signInWithEmailPassword(BuildContext context) async {
    try {
      final bloc = context.read<SignInBloc>();
      final state = bloc.state;
      final email = state.usernameFieldController?.text ?? '';
      final password = state.passwordFieldController?.text ?? '';
      
      // Validate email and password
      if (email.isEmpty || password.isEmpty) {
        throw Exception('Email and password cannot be empty');
      }
      
      // Sign in with email and password
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Navigate to home screen or next screen
      // Navigator.pushReplacementNamed(context, AppRoutes.homeScreen);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Successfully signed in with email')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  void _signInWithGoogle(BuildContext context) async {
    try {
      // Use the iOS client ID from firebase_options.dart
      final clientId = '861015223952-bp6a6en3rtf4d2jrvk1l1jf2765q47et.apps.googleusercontent.com';
      
      // Create a GoogleSignIn instance with the iOS client ID
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: clientId,
        scopes: ['email', 'profile'],
      );
      
      // Start the sign-in process
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      
      // If the user canceled the sign-in, return
      if (googleUser == null) return;
      
      // Get the authentication details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      // Sign in to Firebase with the Google credential
      await FirebaseAuth.instance.signInWithCredential(credential);
      
      // Navigate to home screen or next screen
      // Navigator.pushReplacementNamed(context, AppRoutes.homeScreen);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Successfully signed in with Google')),
      );
    } catch (e) {
      print("Google Sign-In Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  void _signInWithFacebook(BuildContext context) async {
    try {
      // Import the flutter_facebook_auth package
      final LoginResult result = await FacebookAuth.instance.login();
      
      // Check if the login was successful
      if (result.status == LoginStatus.success) {
        // Get the access token
        final AccessToken accessToken = result.accessToken!;
        
        // Create a credential from the access token
        final OAuthCredential credential = FacebookAuthProvider.credential(
          accessToken.token,
        );
        
        // Sign in to Firebase with the Facebook credential
        await FirebaseAuth.instance.signInWithCredential(credential);
        
        // Navigate to home screen or next screen
        // Navigator.pushReplacementNamed(context, AppRoutes.homeScreen);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Successfully signed in with Facebook')),
        );
      } else {
        throw Exception('Facebook login failed: ${result.message}');
      }
    } catch (e) {
      print("Facebook Sign-In Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }
}
