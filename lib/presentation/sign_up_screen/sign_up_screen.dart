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
import 'bloc/sign_up_bloc.dart';
import 'models/sign_up_model.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

// ignore_for_file: must_be_immutable
class SignUpScreen extends StatelessWidget {
  SignUpScreen({Key? key})
      : super(
          key: key,
        );

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ValueNotifier<String> _passwordNotifier = ValueNotifier<String>('');

  static Widget builder(BuildContext context) {
    return BlocProvider<SignUpBloc>(
      create: (context) => SignUpBloc(SignUpState(
        signUpModelObj: SignUpModel(),
      ))
        ..add(SignUpInitialEvent()),
      child: SignUpScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.gray50,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Form(
          key: _formKey,
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
                    _buildEmailField(context),
                    SizedBox(height: 16.h),
                    _buildPasswordField(context),
                    SizedBox(height: 16.h),
                    _buildConfirmPasswordField(context),
                    SizedBox(height: 24.h),
                    _buildSignUpButton(context),
                    SizedBox(height: 24.h),
                    Text(
                      "OR",
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontSize: 24.h,
                      ),
                    ),
                    SizedBox(height: 40.h),
                    _buildGoogleSignUpButton(context),
                    SizedBox(height: 12.h),
                    _buildFacebookSignUpButton(context),
                    SizedBox(height: 12.h),
                    _buildAppleSignUpButton(context),
                    SizedBox(height: 24.h),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "By signing up to LinguaX, you agree to our ",
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
        onTap: () {
          Navigator.pop(context);
        },
      ),
      centerTitle: true,
      title: AppbarTitle(
        text: "Sign Up",
      ),
    );
  }

  /// Section Widget
  Widget _buildEmailField(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.h),
      child: BlocSelector<SignUpBloc, SignUpState, TextEditingController?>(
        selector: (state) => state.emailFieldController,
        builder: (context, emailFieldController) {
          return CustomTextFormField(
            controller: emailFieldController,
            hintText: "Email Address",
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
      child: BlocBuilder<SignUpBloc, SignUpState>(
        builder: (context, state) {
          // Update the ValueNotifier when the state is built
          if (state.passwordFieldController != null) {
            state.passwordFieldController!.addListener(() {
              _passwordNotifier.value = state.passwordFieldController!.text;
            });
          }
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextFormField(
                controller: state.passwordFieldController,
                hintText: "Password",
                hintStyle: CustomTextStyles.titleMediumGray500Medium,
                textInputType: TextInputType.visiblePassword,
                suffix: InkWell(
                  onTap: () {
                    context.read<SignUpBloc>().add(ChangePasswordVisibilityEvent(
                        value: !state.isShowPassword));
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: 16.h,
                      vertical: 20.h,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_passwordNotifier.value.isNotEmpty && isValidPassword(_passwordNotifier.value, isRequired: true))
                          Padding(
                            padding: EdgeInsets.only(right: 8.h),
                            child: Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 16.h,
                            ),
                          ),
                        CustomImageView(
                          imagePath: ImageConstant.imgSettingsGray500,
                          height: 24.h,
                          width: 24.h,
                          fit: BoxFit.contain,
                        ),
                      ],
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
                  
                  // Validate password match whenever password changes
                  if (state.confirmPasswordFieldController?.text.isNotEmpty == true) {
                    context.read<SignUpBloc>().add(ValidatePasswordMatchEvent());
                  }
                  
                  return null;
                },
              ),
              ValueListenableBuilder<String>(
                valueListenable: _passwordNotifier,
                builder: (context, password, child) {
                  if (password.isEmpty) {
                    return SizedBox.shrink();
                  }
                  return Padding(
                    padding: EdgeInsets.only(top: 8.h, left: 8.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPasswordRequirement(
                          "At least 8 characters",
                          password.length >= 8,
                        ),
                        _buildPasswordRequirement(
                          "At least one uppercase letter",
                          RegExp(r'[A-Z]').hasMatch(password),
                        ),
                        _buildPasswordRequirement(
                          "At least one lowercase letter",
                          RegExp(r'[a-z]').hasMatch(password),
                        ),
                        _buildPasswordRequirement(
                          "At least one number",
                          RegExp(r'[0-9]').hasMatch(password),
                        ),
                        _buildPasswordRequirement(
                          "At least one special character",
                          RegExp(r'[\W]').hasMatch(password),
                        ),
                        _buildPasswordRequirement(
                          "No whitespace",
                          !RegExp(r'\s').hasMatch(password),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPasswordRequirement(String requirement, bool isMet) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.cancel,
            color: isMet ? Colors.green : appTheme.deepOrangeA200,
            size: 16.h,
          ),
          SizedBox(width: 8.h),
          Expanded(
            child: Text(
              requirement,
              style: CustomTextStyles.bodyMediumGray700.copyWith(
                fontSize: 12.fSize,
                color: isMet ? Colors.green : appTheme.gray700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Section Widget
  Widget _buildConfirmPasswordField(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.h),
      child: BlocBuilder<SignUpBloc, SignUpState>(
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextFormField(
                controller: state.confirmPasswordFieldController,
                hintText: "Confirm Password",
                hintStyle: CustomTextStyles.titleMediumGray500Medium,
                textInputAction: TextInputAction.done,
                textInputType: TextInputType.visiblePassword,
                suffix: InkWell(
                  onTap: () {
                    context.read<SignUpBloc>().add(ChangeConfirmPasswordVisibilityEvent(
                        value: !state.isShowConfirmPassword));
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
                obscureText: state.isShowConfirmPassword,
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
                  if (value == null || value.isEmpty) {
                    return "Please confirm your password";
                  }
                  if (value != state.passwordFieldController?.text) {
                    return "Passwords do not match";
                  }
                  
                  // Validate password match whenever confirm password changes
                  context.read<SignUpBloc>().add(ValidatePasswordMatchEvent());
                  
                  return null;
                },
              ),
              if (!state.passwordsMatch && state.confirmPasswordFieldController?.text.isNotEmpty == true)
                Padding(
                  padding: EdgeInsets.only(top: 8.h, left: 16.h),
                  child: Text(
                    "Passwords do not match",
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  /// Section Widget
  Widget _buildSignUpButton(BuildContext context) {
    return CustomElevatedButton(
      height: 48.h,
      text: "Sign Up",
      margin: EdgeInsets.symmetric(horizontal: 16.h),
      buttonStyle: CustomButtonStyles.fillDeepOrange,
      onPressed: () {
        if (_formKey.currentState?.validate() ?? false) {
          _signUpWithEmailPassword(context);
        }
      },
    );
  }

  /// Section Widget
  Widget _buildGoogleSignUpButton(BuildContext context) {
    return CustomElevatedButton(
      height: 48.h,
      text: "Sign up with Google",
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
        _signUpWithGoogle(context);
      },
    );
  }

  /// Section Widget
  Widget _buildFacebookSignUpButton(BuildContext context) {
    return CustomElevatedButton(
      height: 48.h,
      text: "Sign up with Facebook",
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
        _signUpWithFacebook(context);
      },
    );
  }

  /// Section Widget
  Widget _buildAppleSignUpButton(BuildContext context) {
    return CustomElevatedButton(
      height: 48.h,
      text: "Sign up with Apple",
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
  void _signUpWithEmailPassword(BuildContext context) async {
    try {
      final bloc = context.read<SignUpBloc>();
      final state = bloc.state;
      final email = state.emailFieldController?.text ?? '';
      final password = state.passwordFieldController?.text ?? '';
      final confirmPassword = state.confirmPasswordFieldController?.text ?? '';
      
      // Validate email and password
      if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
        throw Exception('Email and password cannot be empty');
      }
      
      // Validate passwords match
      if (password != confirmPassword) {
        throw Exception('Passwords do not match');
      }
      
      // Create user with email and password
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Navigate to create profile screen
      Navigator.pushNamed(context, AppRoutes.createProfileTwoScreen);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Account created successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  void _signUpWithGoogle(BuildContext context) async {
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
      
      // Navigate to create profile screen
      Navigator.pushNamed(context, AppRoutes.createProfileTwoScreen);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Successfully signed up with Google')),
      );
    } catch (e) {
      print("Google Sign-Up Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  void _signUpWithFacebook(BuildContext context) async {
    try {
      // Trigger the sign-in flow
      final LoginResult result = await FacebookAuth.instance.login();

      // Check if login was successful
      if (result.status == LoginStatus.success) {
        // Get the access token
        final AccessToken accessToken = result.accessToken!;
        
        // Create a credential from the access token
        final OAuthCredential credential = FacebookAuthProvider.credential(accessToken.token);
        
        // Sign in to Firebase with the Facebook credential
        await FirebaseAuth.instance.signInWithCredential(credential);
        
        // Navigate to create profile screen
        Navigator.pushNamed(context, AppRoutes.createProfileTwoScreen);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Successfully signed up with Facebook')),
        );
      } else {
        throw Exception('Facebook login failed: ${result.status}');
      }
    } catch (e) {
      print("Facebook Sign-Up Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }
} 