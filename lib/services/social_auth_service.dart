import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import '../core/constants/social_auth_config.dart';

/// Result container for a social sign-in.
class SocialAuthResult {
  final String provider; // 'google' | 'facebook' | 'apple'
  final String? idToken; // Google ID token / Apple identity token
  final String? accessToken; // Facebook access token
  final String? fullName;
  final String? email;
  final String? avatar;

  const SocialAuthResult({
    required this.provider,
    this.idToken,
    this.accessToken,
    this.fullName,
    this.email,
    this.avatar,
  });
}

class SocialAuthService {
  // Whether GoogleSignIn has been initialized this app session.
  // NOT static — avoids stale-flag issues across instances.
  bool _googleInitialized = false;

  // ──────────────────────────────────────────────
  // Google Sign-In  (google_sign_in v7.x API)
  //
  // On Android:
  //   • serverClientId = Web Client ID (required to get an idToken back)
  //   • clientId is ignored on Android
  // On iOS:
  //   • clientId = iOS Client ID
  //   • serverClientId is optional
  // ──────────────────────────────────────────────
  Future<SocialAuthResult?> signInWithGoogle() async {
    try {
      if (!_googleInitialized) {
        debugPrint('GOOGLE_AUTH: Initializing GoogleSignIn...');
        await GoogleSignIn.instance.initialize(
          // iOS needs the iOS client ID; on Android clientId is ignored.
          clientId: Platform.isIOS ? SocialAuthConfig.googleClientIdIos : null,
          // Android Credential Manager requires serverClientId to issue an idToken.
          serverClientId: SocialAuthConfig.googleClientIdAndroid,
        );
        _googleInitialized = true;
        debugPrint('GOOGLE_AUTH: Initialized successfully');
      }

      debugPrint('GOOGLE_AUTH: Calling authenticate()...');
      final GoogleSignInAccount account =
          await GoogleSignIn.instance.authenticate();

      debugPrint('GOOGLE_AUTH: Signed in as ${account.email}');

      // In v7.x, authentication is a synchronous getter backed by the token
      // data returned by the platform during authenticate(). On Android, the
      // idToken is always present when serverClientId is correctly configured.
      final String? idToken = account.authentication.idToken;

      if (idToken == null || idToken.isEmpty) {
        debugPrint(
          'GOOGLE_AUTH: ERROR — idToken is null.\n'
          'Fix: Ensure SocialAuthConfig.googleClientIdAndroid is the '
          'WEB client ID from Google Cloud Console (not the Android client ID). '
          'In google-services.json this is the client with client_type:3.',
        );
        throw Exception(
          'Google sign-in failed: could not obtain an ID token. '
          'Please contact support.',
        );
      }

      debugPrint('GOOGLE_AUTH: idToken obtained (${idToken.length} chars) ✓');

      return SocialAuthResult(
        provider: 'google',
        idToken: idToken,
        email: account.email,
        avatar: account.photoUrl,
        fullName: account.displayName,
      );
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        debugPrint('GOOGLE_AUTH: User cancelled sign-in');
        return null; // silent — user chose to cancel
      }
      debugPrint('GOOGLE_AUTH: GoogleSignInException: ${e.code} — ${e.description}');
      // Re-throw so loginWithGoogle() shows a snackbar
      rethrow;
    } catch (e) {
      debugPrint('GOOGLE_AUTH: Error: $e');
      rethrow;
    }
  }

  // ──────────────────────────────────────────────
  // Facebook Sign-In
  // ──────────────────────────────────────────────
  Future<SocialAuthResult?> signInWithFacebook() async {
    try {
      debugPrint('FACEBOOK_AUTH: Starting Facebook login...');
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      debugPrint('FACEBOOK_AUTH: Status: ${result.status}');

      if (result.status == LoginStatus.success) {
        final accessToken = result.accessToken?.tokenString;
        if (accessToken == null) {
          debugPrint('FACEBOOK_AUTH: accessToken is null after success');
          throw Exception('Facebook sign-in failed: could not obtain an access token.');
        }

        debugPrint('FACEBOOK_AUTH: Got access token, fetching profile...');
        final userData = await FacebookAuth.instance.getUserData(
          fields: 'name,email,picture.width(200)',
        );
        debugPrint('FACEBOOK_AUTH: Profile fetched: email=${userData['email']}');

        return SocialAuthResult(
          provider: 'facebook',
          accessToken: accessToken,
          email: userData['email'] as String?,
          fullName: userData['name'] as String?,
          avatar: (userData['picture']?['data']?['url']) as String?,
        );
      }

      // cancelled or failed
      if (result.status == LoginStatus.cancelled) {
        debugPrint('FACEBOOK_AUTH: User cancelled');
        return null;
      }

      debugPrint('FACEBOOK_AUTH: Login failed: ${result.message}');
      throw Exception('Facebook sign-in failed: ${result.message}');
    } catch (e) {
      debugPrint('FACEBOOK_AUTH: Error: $e');
      rethrow;
    }
  }

  // ──────────────────────────────────────────────
  // Apple Sign-In
  // ──────────────────────────────────────────────
  Future<SocialAuthResult?> signInWithApple() async {
    try {
      debugPrint('APPLE_AUTH: Starting Apple sign-in...');
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final identityToken = appleCredential.identityToken;
      if (identityToken == null || identityToken.isEmpty) {
        debugPrint('APPLE_AUTH: identityToken is null');
        throw Exception('Apple sign-in failed: could not obtain an identity token.');
      }

      debugPrint('APPLE_AUTH: identityToken obtained ✓');

      // Apple only gives fullName on the very first sign-in
      final fullName = [
        appleCredential.givenName,
        appleCredential.familyName,
      ].where((s) => s != null && s.isNotEmpty).join(' ').trim();

      return SocialAuthResult(
        provider: 'apple',
        idToken: identityToken,
        fullName: fullName.isEmpty ? null : fullName,
        email: appleCredential.email,
      );
    } catch (e) {
      debugPrint('APPLE_AUTH: Error: $e');
      rethrow;
    }
  }

  // ──────────────────────────────────────────────
  // Sign out helpers
  // ──────────────────────────────────────────────
  Future<void> signOut() async {
    _googleInitialized = false; // Allow re-initialization after sign out
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {}
    try {
      await FacebookAuth.instance.logOut();
    } catch (_) {}
  }
}
