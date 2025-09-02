import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final _col = FirebaseFirestore.instance.collection('events');

  Future<void> addEvent(Map<String, dynamic> data) async {
    data['timestamp'] = data['timestamp'] ?? FieldValue.serverTimestamp();
    await _col.add(data);
  }

  Stream<QuerySnapshot> eventsStream() {
    return _col.orderBy('timestamp', descending: true).limit(50).snapshots();
  }

  Stream<QuerySnapshot> eventsWithLocationStream() {
    return _col.where('lat', isNotEqualTo: null).snapshots();
  }
}
