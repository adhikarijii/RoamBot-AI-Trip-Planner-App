import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<void> createTrip(
    String destination,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await _firestore.collection('users').doc(uid).collection('trips').add({
      'destination': destination,
      'start_date': startDate,
      'end_date': endDate,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getTrips() {
    final uid = _auth.currentUser?.uid;
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('trips')
        .snapshots();
  }
}
