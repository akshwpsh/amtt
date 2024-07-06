import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addKeyword(String keyword) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    if (uid.isNotEmpty && keyword.isNotEmpty) {
      await _firestore.collection('keywords').add({
        'uid': uid,
        'keyword': keyword,
      });
    }
  }
}
