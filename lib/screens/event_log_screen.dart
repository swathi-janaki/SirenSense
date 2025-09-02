import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import 'package:provider/provider.dart';

class EventLogScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final fs = context.read<FirestoreService>();
    return Scaffold(
      appBar: AppBar(title: Text('Event Log')),
      body: StreamBuilder<QuerySnapshot>(
        stream: fs.eventsStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs;
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (_, i){
              final d = docs[i].data() as Map<String,dynamic>;
              final t = (d['timestamp'] as Timestamp).toDate();
              return ListTile(
                leading: Icon(Icons.notifications),
                title: Text(d['type'] ?? 'event'),
                subtitle: Text('${t.toLocal()} • source: ${d['source'] ?? 'unknown'}'),
              );
            }
          );
        },
      ),
    );
  }
}
