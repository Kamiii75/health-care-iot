import 'package:firebase_auth/firebase_auth.dart';
import 'package:health_care_iot/helper/helperFunction.dart';
import 'package:health_care_iot/models/userMdl.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  UserModel? _userFromFirebaseUser(User usr) {
    return usr != null ? UserModel(userId: usr.uid) : null;
  }

  Future signInwithEmailAndPassword(String email, String pass) async {
    try {
      UserCredential result =
          await _auth.signInWithEmailAndPassword(email: email, password: pass);
      User? firebaseUser = result.user;
      return _userFromFirebaseUser(firebaseUser!);
    } catch (error) {
      print(error.toString());
    }
  }

  Future signUpwithEmailAndPassword(
      String email, String pass, String name, String type) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: pass);
      User? firebaseUser = result.user;
      return _userFromFirebaseUser(firebaseUser!);
    } catch (error) {
      print(error.toString());
    }
  }

  Future resetPass(String email) async {
    try {
      return await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print(e.toString());
    }
  }

  Future signOut() async {
    try {
      HelperFunction.saveUserLoggedInSharedPreference(false);

      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
    }
  }
}
