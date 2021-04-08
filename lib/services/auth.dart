import 'package:apple_sign_in/apple_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io' show Platform;

class AuthService {
  // Determine if Apple SignIn is available
  Future<bool> get appleSignInAvailable => AppleSignIn.isAvailable();
  int j = 0;
  int length = 0;

  /// Sign in with Apple
  Future<FirebaseUser> appleSignIn() async {
    try {
      final AuthorizationResult appleResult =
          await AppleSignIn.performRequests([
        AppleIdRequest(requestedScopes: [Scope.email, Scope.fullName])
      ]);

      if (appleResult.error != null) {
        // handle errors from Apple here
      }

      final AuthCredential credential =
          OAuthProvider(providerId: 'apple.com').getCredential(
        accessToken:
            String.fromCharCodes(appleResult.credential.authorizationCode),
        idToken: String.fromCharCodes(appleResult.credential.identityToken),
      );

      AuthResult firebaseResult =
          await FirebaseAuth.instance.signInWithCredential(credential);
      FirebaseUser user = firebaseResult.user;
      Firestore.instance.collection('Users').snapshots().forEach((element) {
        length = element.documents.length;
        print(length);
        for (int i = 0; i < element.documents.length; i++) {
          if (element.documents[i]['mail'] != appleResult.credential.email) {
            print(element.documents[i]['mail']);
            j++;
            print(j.toString());
          }
        }
        if (j == length) {
          List<String> titles = [];
          Firestore.instance.collection('Users').document(user.uid).setData({
            'Name': appleResult.credential.fullName,
            'id': user.uid,
            'mail': appleResult.credential.email,
            'pUrl':
                'https://emojipedia-us.s3.dualstack.us-west-1.amazonaws.com/thumbs/160/apple/155/lion-face_1f981.png',
            'couponUsed': titles,
            'role': 'user'
          });
        }
      });

      // Optional, Update user data in Firestore
//      updateUserData(user);

      return user;
    } catch (error) {
      print(error);
      return null;
    }
  }
}
