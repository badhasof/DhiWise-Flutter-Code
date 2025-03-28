import 'package:flutter/material.dart';
import '../../core/app_export.dart';
import '../../theme/custom_button_style.dart';
import '../../widgets/custom_elevated_button.dart';
import '../../widgets/custom_floating_text_field.dart';
import '../../widgets/custom_text_form_field.dart';
import '../../widgets/countdown_timer_widget.dart';
import 'bloc/profile_bloc.dart';
import 'models/profile_model.dart'; // ignore_for_file: must_be_immutable
import 'package:firebase_auth/firebase_auth.dart';
import '../settings_screen/settings_screen.dart';
import '../../services/user_service.dart';
import '../subscription_screen/subscription_screen.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key})
      : super(
          key: key,
        );

  static Widget builder(BuildContext context) {
    return BlocProvider<ProfileBloc>(
      create: (context) => ProfileBloc(ProfileState(
        profileModelObj: ProfileModel(),
      ))
        ..add(ProfileInitialEvent()),
      child: ProfilePage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc(ProfileState(
        profileModelObj: ProfileModel(),
      ))..add(ProfileInitialEvent()),
      child: _ProfilePageContent(),
    );
  }
}

class _ProfilePageContent extends StatefulWidget {
  @override
  State<_ProfilePageContent> createState() => _ProfilePageContentState();
}

class _ProfilePageContentState extends State<_ProfilePageContent> {
  // User service instance
  final UserService _userService = UserService();
  bool _isPremium = false;
  String _subscriptionType = "";
  bool _isCheckingSubscription = true;
  
  @override
  void initState() {
    super.initState();
    _checkSubscriptionStatus();
  }
  
  Future<void> _checkSubscriptionStatus() async {
    setState(() {
      _isCheckingSubscription = true;
    });
    
    try {
      final userData = await _userService.getUserData();
      final isPremium = await _userService.hasPremiumAccess();
      
      String subscriptionType = "";
      if (userData != null && userData.containsKey('subscription')) {
        final subscription = userData['subscription'];
        if (subscription != null && subscription.containsKey('type')) {
          subscriptionType = subscription['type'] == 'monthly' ? 'Monthly' : 'Lifetime';
        }
      }
      
      setState(() {
        _isPremium = isPremium;
        _subscriptionType = subscriptionType;
        _isCheckingSubscription = false;
      });
    } catch (e) {
      print('Error checking subscription: $e');
      setState(() {
        _isCheckingSubscription = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Attempt to get user data from Firebase
    _fetchUserData(context);
    
    return Scaffold(
      backgroundColor: appTheme.gray50,
      body: SafeArea(
        child: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTrialTimeColumn(context),
                _buildProfileTitleColumn(context),
                SizedBox(height: 16.h),
                _buildProfileAvatar(context),
                SizedBox(height: 10.h),
                _buildChangeAvatarRow(context),
                SizedBox(height: 22.h),
                
                // Subscription status section
                _buildSubscriptionStatusSection(context),
                SizedBox(height: 22.h),
                
                _buildNameFieldColumn(context),
                SizedBox(height: 14.h),
                _buildUsernameFieldColumn(context),
                SizedBox(height: 16.h),
                _buildPasswordField(context),
                SizedBox(height: 14.h),
                _buildEmailFieldColumn(context),
                SizedBox(height: 24.h),
                _buildDeleteAccountButton(context),
                SizedBox(height: 24.h), // Add extra space at the bottom to prevent overflow
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Profile Avatar Widget
  Widget _buildProfileAvatar(BuildContext context) {
    return Container(
      height: 108.h,
      width: 110.h,
      decoration: AppDecoration.outlineDeeporangeA100.copyWith(
        borderRadius: BorderRadiusStyle.circleBorder54,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "JP",
            style: theme.textTheme.displayMedium,
          )
        ],
      ),
    );
  }

  /// Change Avatar Button Row
  Widget _buildChangeAvatarRow(BuildContext context) {
    return BlocSelector<ProfileBloc, ProfileState, bool>(
      selector: (state) => state.isEditing,
      builder: (context, isEditing) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.center,
              child: Text(
                "Change avatar",
                style: CustomTextStyles.titleMediumDeeporangeA200.copyWith(
                  color: isEditing ? appTheme.deepOrangeA200 : appTheme.deepOrangeA200.withOpacity(0.5),
                ),
              ),
            ),
            SizedBox(width: 8.h),
            CustomImageView(
              imagePath: ImageConstant.imgUserDeepOrangeA200,
              height: 16.h,
              width: 16.h,
              color: isEditing ? null : Colors.black.withOpacity(0.5),
            )
          ],
        );
      },
    );
  }

  /// Section Widget
  Widget _buildTrialButton(BuildContext context) {
    return CountdownTimerWidget();
  }

  /// Section Widget
  Widget _buildTrialTimeColumn(BuildContext context) {
    return Container(
      width: double.maxFinite,
      decoration: AppDecoration.fillGray,
      child: Column(
        children: [_buildTrialButton(context)],
      ),
    );
  }

  /// Section Widget
  Widget _buildProfileTitleColumn(BuildContext context) {
    return Container(
      width: double.maxFinite,
      padding: EdgeInsets.symmetric(vertical: 4.h),
      decoration: AppDecoration.outlinePrimary12,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(left: 40.h),
              child: Text(
                "Profile",
                style: CustomTextStyles.titleMediumOnPrimaryExtraBold,
              ),
            ),
          ),
          ),
          BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Edit/Save toggle button
                  GestureDetector(
                    onTap: () {
                      if (state.isEditing) {
                        // If we're in edit mode, save changes
                        _saveUserData(context);
                      }
                      // Toggle edit mode
                      context.read<ProfileBloc>().add(ToggleEditModeEvent());
                    },
                    child: Padding(
                      padding: EdgeInsets.only(right: 16.h),
                      child: Icon(
                        state.isEditing ? Icons.check : Icons.edit,
                        color: appTheme.deepOrangeA200,
                        size: 24.h,
                      ),
                    ),
                  ),
                  // Settings button
          GestureDetector(
            onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SettingsScreen.builder(context),
                        ),
                      );
            },
            child: Padding(
              padding: EdgeInsets.only(right: 16.h),
              child: Icon(
                Icons.settings,
                color: appTheme.deepOrangeA200,
                size: 24.h,
              ),
            ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // Method to save user data when editing is complete
  void _saveUserData(BuildContext context) {
    try {
      // Get the current state
      final state = context.read<ProfileBloc>().state;
      
      // Get the Firebase auth instance
      final auth = FirebaseAuth.instance;
      final user = auth.currentUser;
      
      if (user != null) {
        // Update user profile if possible
        if (state.nameFieldController?.text != null && 
            state.nameFieldController!.text.isNotEmpty) {
          user.updateDisplayName(state.nameFieldController!.text);
        }
        
        if (state.emailFieldController?.text != null && 
            state.emailFieldController!.text.isNotEmpty &&
            state.emailFieldController!.text != user.email) {
          // Email updates require re-authentication in Firebase
          // This would need more complex implementation with re-auth
          // For now, just show a message that email can't be changed directly
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Email changes require verification. Please update through settings."),
              duration: Duration(seconds: 3),
            ),
          );
        }
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Profile updated successfully"),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error saving user data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to update profile: $e"),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  /// Section Widget
  Widget _buildNameField(BuildContext context) {
    return BlocSelector<ProfileBloc, ProfileState, TextEditingController?>(
      selector: (state) => state.nameFieldController,
      builder: (context, nameFieldController) {
        return BlocSelector<ProfileBloc, ProfileState, bool>(
          selector: (state) => state.isEditing,
          builder: (context, isEditing) {
            return Stack(
              children: [
                Opacity(
                  opacity: isEditing ? 1.0 : 0.7,
                  child: CustomFloatingTextField(
          width: double.infinity,
          controller: nameFieldController,
          labelText: "Name",
          labelStyle: CustomTextStyles.titleMediumOnPrimary,
          hintText: "Name",
          contentPadding: EdgeInsets.all(12.h),
          borderDecoration: FloatingTextFormFieldStyleHelper.custom,
          filled: false,
                    readOnly: !isEditing,
                  ),
                ),
                if (!isEditing)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12.h),
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  /// Section Widget
  Widget _buildNameFieldColumn(BuildContext context) {
    return Container(
      width: double.maxFinite,
      margin: EdgeInsets.symmetric(horizontal: 14.h),
      padding: EdgeInsets.symmetric(horizontal: 14.h, vertical: 6.h),
      decoration: AppDecoration.outlinePrimary14.copyWith(
        borderRadius: BorderRadiusStyle.roundedBorder12,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_buildNameField(context)],
      ),
    );
  }

  /// Section Widget
  Widget _buildUsernameField(BuildContext context) {
    return BlocSelector<ProfileBloc, ProfileState, TextEditingController?>(
      selector: (state) => state.usernameFieldController,
      builder: (context, usernameFieldController) {
        return BlocSelector<ProfileBloc, ProfileState, bool>(
          selector: (state) => state.isEditing,
          builder: (context, isEditing) {
            return Stack(
              children: [
                Opacity(
                  opacity: isEditing ? 1.0 : 0.7,
                  child: CustomFloatingTextField(
          width: double.infinity,
          controller: usernameFieldController,
          labelText: "Username",
          labelStyle: CustomTextStyles.titleMediumOnPrimary,
          hintText: "Username",
          contentPadding: EdgeInsets.all(12.h),
          borderDecoration: FloatingTextFormFieldStyleHelper.custom,
          filled: false,
                    readOnly: !isEditing,
                  ),
                ),
                if (!isEditing)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12.h),
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  /// Section Widget
  Widget _buildUsernameFieldColumn(BuildContext context) {
    return Container(
      width: double.maxFinite,
      margin: EdgeInsets.symmetric(horizontal: 14.h),
      padding: EdgeInsets.symmetric(horizontal: 14.h, vertical: 6.h),
      decoration: AppDecoration.outlinePrimary14.copyWith(
        borderRadius: BorderRadiusStyle.roundedBorder12,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_buildUsernameField(context)],
      ),
    );
  }

  /// Section Widget
  Widget _buildPasswordField(BuildContext context) {
    return Container(
      width: double.maxFinite,
      margin: EdgeInsets.symmetric(horizontal: 14.h),
      padding: EdgeInsets.symmetric(horizontal: 14.h, vertical: 6.h),
      decoration: AppDecoration.outlinePrimary14.copyWith(
        borderRadius: BorderRadiusStyle.roundedBorder12,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BlocSelector<ProfileBloc, ProfileState, TextEditingController?>(
            selector: (state) => state.passwordFieldController,
            builder: (context, passwordFieldController) {
              return BlocSelector<ProfileBloc, ProfileState, bool>(
                selector: (state) => state.isEditing,
                builder: (context, isEditing) {
                  return Stack(
                    children: [
                      Opacity(
                        opacity: isEditing ? 1.0 : 0.7,
                        child: CustomFloatingTextField(
                width: double.infinity,
                controller: passwordFieldController,
                labelText: "Password",
                labelStyle: CustomTextStyles.titleMediumOnPrimary,
                hintText: "Password",
                textInputType: TextInputType.visiblePassword,
                obscureText: true,
                contentPadding: EdgeInsets.all(12.h),
                borderDecoration: FloatingTextFormFieldStyleHelper.custom,
                filled: false,
                          readOnly: !isEditing,
                        ),
                      ),
                      if (!isEditing)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12.h),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  /// Section Widget
  Widget _buildEmailField(BuildContext context) {
    return BlocSelector<ProfileBloc, ProfileState, TextEditingController?>(
      selector: (state) => state.emailFieldController,
      builder: (context, emailFieldController) {
        return BlocSelector<ProfileBloc, ProfileState, bool>(
          selector: (state) => state.isEditing,
          builder: (context, isEditing) {
            return Stack(
              children: [
                Opacity(
                  opacity: isEditing ? 1.0 : 0.7,
                  child: CustomFloatingTextField(
          width: double.infinity,
          controller: emailFieldController,
          labelText: "Email",
          labelStyle: CustomTextStyles.titleMediumOnPrimary,
          hintText: "Email",
          textInputAction: TextInputAction.done,
          textInputType: TextInputType.emailAddress,
          contentPadding: EdgeInsets.all(12.h),
          borderDecoration: FloatingTextFormFieldStyleHelper.custom,
          filled: false,
                    readOnly: !isEditing,
                  ),
                ),
                if (!isEditing)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12.h),
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  /// Section Widget
  Widget _buildEmailFieldColumn(BuildContext context) {
    return Container(
      width: double.maxFinite,
      margin: EdgeInsets.symmetric(horizontal: 14.h),
      padding: EdgeInsets.symmetric(horizontal: 14.h, vertical: 6.h),
      decoration: AppDecoration.outlinePrimary14.copyWith(
        borderRadius: BorderRadiusStyle.roundedBorder12,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_buildEmailField(context)],
      ),
    );
  }

  /// Section Widget
  Widget _buildDeleteAccountButton(BuildContext context) {
    return BlocSelector<ProfileBloc, ProfileState, bool>(
      selector: (state) => state.isEditing,
      builder: (context, isEditing) {
    return CustomElevatedButton(
      height: 48.h,
      text: "DELETE ACCOUNT",
      margin: EdgeInsets.symmetric(horizontal: 14.h),
      buttonTextStyle: CustomTextStyles.titleMediumRedA200,
          onPressed: isEditing ? () => _showDeleteAccountDialog(context) : null,
          buttonStyle: isEditing 
              ? null 
              : CustomButtonStyles.none.copyWith(
                  backgroundColor: MaterialStateProperty.all(Colors.grey[300]),
                ),
        );
      },
    );
  }

  // Show confirmation dialog for account deletion
  void _showDeleteAccountDialog(BuildContext context) {
    // Get user data from the bloc state
    final state = context.read<ProfileBloc>().state;
    final userName = state.nameFieldController?.text ?? "";
    
    // Text controller for the confirmation input
    final confirmationController = TextEditingController();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(
            "Delete Account",
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "This action cannot be undone. All your data will be permanently deleted.",
                style: TextStyle(
                  fontSize: 14.fSize,
                  color: appTheme.gray700,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                "To confirm, please type your name: \"$userName\"",
                style: TextStyle(
                  fontSize: 14.fSize,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: confirmationController,
                decoration: InputDecoration(
                  hintText: "Type your name",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.h),
                    borderSide: BorderSide(
                      color: appTheme.gray300,
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12.h,
                    vertical: 10.h,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close the dialog
              },
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: appTheme.gray700,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                // Check if the confirmation text matches the user's name
                if (confirmationController.text.trim() == userName.trim()) {
                  Navigator.of(dialogContext).pop(); // Close the dialog
                  _deleteAccount(context); // Delete the account
                } else {
                  // Show error if names don't match
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Names don't match. Please try again."),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Text(
                "Delete",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Delete account and redirect to onboarding
  void _deleteAccount(BuildContext context) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          return Center(
            child: CircularProgressIndicator(
              color: appTheme.deepOrangeA200,
            ),
          );
        },
      );

      // Get the current user
      final auth = FirebaseAuth.instance;
      final user = auth.currentUser;

      if (user != null) {
        // Delete the user account
        await user.delete();
        
        // Sign out
        await auth.signOut();
        
        // Close loading dialog
        Navigator.of(context, rootNavigator: true).pop();
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Your account has been deleted."),
            backgroundColor: Colors.green,
          ),
        );
        
        // Navigate to onboarding page
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.onboardimgScreen, 
          (route) => false, // Remove all previous routes
        );
      } else {
        // Close loading dialog
        Navigator.of(context, rootNavigator: true).pop();
        
        // Show error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("No user is currently signed in."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      Navigator.of(context, rootNavigator: true).pop();
      
      // Show error message 
      String errorMessage = "Failed to delete account.";
      
      // Handle specific Firebase errors
      if (e is FirebaseAuthException) {
        if (e.code == 'requires-recent-login') {
          errorMessage = "Please log out and log in again before deleting your account.";
        } else {
          errorMessage = e.message ?? errorMessage;
        }
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _fetchUserData(BuildContext context) {
    // Get the Firebase auth instance
    try {
      final auth = FirebaseAuth.instance;
      final user = auth.currentUser;
      
      if (user != null) {
        // Update the text controllers with user data
        context.read<ProfileBloc>().add(UpdateUserDataEvent(
          email: user.email,
          displayName: user.displayName,
        ));
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  /// Subscription Status Section Widget
  Widget _buildSubscriptionStatusSection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Subscription",
            style: CustomTextStyles.titleMediumOnPrimary,
          ),
          SizedBox(height: 10.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.h),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _isPremium 
                            ? Icons.star_rounded 
                            : Icons.star_border_rounded,
                          color: _isPremium 
                            ? appTheme.deepOrangeA200 
                            : appTheme.gray500,
                          size: 24.h,
                        ),
                        SizedBox(width: 10.h),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isCheckingSubscription
                                ? "Checking status..."
                                : _isPremium 
                                  ? "Premium Access" 
                                  : "Basic Access",
                              style: CustomTextStyles.titleMediumOnPrimary.copyWith(
                                fontWeight: FontWeight.w700,
                                color: _isPremium 
                                  ? appTheme.deepOrangeA200 
                                  : appTheme.gray800,
                              ),
                            ),
                            if (_isPremium && _subscriptionType.isNotEmpty)
                              Text(
                                _subscriptionType,
                                style: CustomTextStyles.bodyMediumGray600,
                              ),
                          ],
                        ),
                      ],
                    ),
                    _isCheckingSubscription
                        ? SizedBox(
                            width: 20.h,
                            height: 20.h,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.h,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                appTheme.deepOrangeA200,
                              ),
                            ),
                          )
                        : TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SubscriptionScreen.builder(context),
                                ),
                              ).then((_) {
                                // Check subscription status again when returning from subscription screen
                                _checkSubscriptionStatus();
                              });
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.h,
                                vertical: 8.h,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.h),
                                side: BorderSide(
                                  color: appTheme.deepOrangeA200,
                                  width: 1.h,
                                ),
                              ),
                              backgroundColor: Colors.white,
                            ),
                            child: Text(
                              _isPremium ? "Manage" : "Upgrade",
                              style: TextStyle(
                                color: appTheme.deepOrangeA200,
                                fontWeight: FontWeight.w600,
                                fontSize: 14.fSize,
                              ),
                            ),
                          ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
