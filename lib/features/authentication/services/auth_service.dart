import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  //login
  Future<AppUser?> login(String email, String password) async {
    UserCredential cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
    var snapshot = await _db.collection('users').doc(cred.user!.uid).get();
    return AppUser.fromMap(cred.user!.uid, snapshot.data()!);
  }


  //signup
  Future<AppUser?> signup({
    required String name,
    required String email,
    required String password,
    required String role, 
  }) async {
    UserCredential cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    String uid = cred.user!.uid;

    AppUser newUser = AppUser(
      uid: uid,
      name: name,
      email: email,
      role: role,
      assignedOfficeId: null,
    );

    await _db.collection('users').doc(uid).set(newUser.toMap());
    return newUser;
  }


  //logout
  Future<void> logout() async {
    await _auth.signOut();
  }

    // Check if the current user is an admin
  Future<bool> isAdmin() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await _db.collection('users').doc(user.uid).get();
      return doc['role'] == 'admin';
    }
    return false;
  }

  //get currentuser
  User? get currentUser => _auth.currentUser;
}
