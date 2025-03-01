import 'dart:convert';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'facebook_user.dart';

/// A helper class to manage Facebook authentication processes.
class FacebookAuthHelper {
  /// Handle Facebook Login process and authenticates the users.
  ///
  /// Returns a [FacebookUser] object if login is successful, or `null` if it fails.
  Future<FacebookUser?> facebookSignInProcess() async {
    try {
      var permission = ['email', 'public_profile'];
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: permission,
      );
      if (result.status == LoginStatus.success) {
        return await fetchUserProfile();
      } else {
        print("Login Failed: ${result.status}");
        print("Message: ${result.message}");
      }
    } catch (e) {
      print("Error during Facebook login: $e");
    }
    return null;
  }

  /// Checks if the user is currently logged in to Facebook.
  ///
  /// Returns `true` if the user is logged in, otherwise `false`.
  Future<bool> userLoggedIn() async {
    final AccessToken? accessToken = await FacebookAuth.instance.accessToken;
    return accessToken != null;
  }

  /// Fetches the profile data of the currently logged-in Facebook user.
  ///
  /// Returns a [FacebookUser] object containing the user's profile information.
  Future<FacebookUser> fetchUserProfile() async {
    final userData = await FacebookAuth.instance.getUserData(
      fields:
          "name,email,birthday,gender,first_name,last_name,middle_name,picture",
    );
    return FacebookUser.fromMap(jsonDecode(jsonEncode(userData)));
  }

  /// Logs out the user from Facebook.
  void facebookSignOutProcess() async {
    await FacebookAuth.instance.logOut();
    print("Facebook: Signed Out..");
  }
}
