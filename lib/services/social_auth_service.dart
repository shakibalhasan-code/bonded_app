import 'dart:convert';
import 'dart:math';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../core/constants/social_auth_config.dart';

class SocialAuthResult {
  final String provider;
  final String? accessToken; // Facebook only
  final String? fullName;
  final String? email;
  final String? avatar;

  const SocialAuthResult({
    required this.provider,
    this.accessToken,
    this.fullName,
    this.email,
    this.avatar,
  });
}

class SocialAuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: Platform.isIOS ? SocialAuthConfig.googleClientIdIos : null,
  );

  // ─── Google ───────────────────────────────────────────────────────────────
  Future<SocialAuthResult?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // user cancelled

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user;

      return SocialAuthResult(
        provider: 'google',
        email: user?.email,
        fullName: user?.displayName,
        avatar: user?.photoURL,
      );
    } catch (e) {
      debugPrint('GOOGLE_AUTH: $e');
      rethrow;
    }
  }

  // ─── Apple ────────────────────────────────────────────────────────────────
  Future<SocialAuthResult?> signInWithApple() async {
    try {
      final rawNonce = _generateNonce();
      final nonce = _sha256(rawNonce);

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );

      final userCredential =
          await _firebaseAuth.signInWithCredential(oauthCredential);
      final user = userCredential.user;

      // Apple only provides name on the very first sign-in; prefer it over Firebase cache.
      final fullName = [appleCredential.givenName, appleCredential.familyName]
          .where((s) => s != null && s.isNotEmpty)
          .join(' ')
          .trim();

      return SocialAuthResult(
        provider: 'apple',
        email: user?.email ?? appleCredential.email,
        fullName: fullName.isNotEmpty ? fullName : user?.displayName,
        avatar: null,
      );
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) return null;
      rethrow;
    } catch (e) {
      debugPrint('APPLE_AUTH: $e');
      rethrow;
    }
  }

  // ─── Facebook ─────────────────────────────────────────────────────────────
  // Backend verifies the access token against Facebook Graph API, so we send
  // the raw token — not Firebase user data.
  Future<SocialAuthResult?> signInWithFacebook() async {
    try {
      final result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      if (result.status == LoginStatus.cancelled) return null;
      if (result.status != LoginStatus.success) {
        throw Exception('Facebook sign-in failed: ${result.message}');
      }

      final accessToken = result.accessToken?.tokenString;
      if (accessToken == null) {
        throw Exception('Facebook sign-in failed: no access token');
      }

      return SocialAuthResult(provider: 'facebook', accessToken: accessToken);
    } catch (e) {
      debugPrint('FACEBOOK_AUTH: $e');
      rethrow;
    }
  }

  // ─── Sign out ─────────────────────────────────────────────────────────────
  Future<void> signOut() async {
    try { await _googleSignIn.signOut(); } catch (_) {}
    try { await FacebookAuth.instance.logOut(); } catch (_) {}
    try { await _firebaseAuth.signOut(); } catch (_) {}
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────
  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  String _sha256(String input) =>
      sha256.convert(utf8.encode(input)).toString();
}
