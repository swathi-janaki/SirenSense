import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/audio_recorder.dart';
import '../services/tflite_service.dart';
import '../services/firestore_service.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../services/fcm_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AudioRecorder _recorder = AudioRecorder();
  String _detected = 'Idle';
  bool _alert = false;

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  void _startListening() async {
    await _recorder.init();
    _recorder.onChunkReady = (bufferPath) async {
      final label = await TFLiteService.instance.classifyFile(bufferPath);
      if (label != null) {
        setState(() => _detected = label);
        if (_isDangerous(label)) _onAlert(label);
      }
    };
    _recorder.startRecordingLoop();
  }

  bool _isDangerous(String label){
    final lowered = label.toLowerCase();
    return lowered.contains('siren') || lowered.contains('alarm') || lowered.contains('horn');
  }

  void _onAlert(String label) async {
    if (_alert) return;
    setState(() => _alert = true);
    // vibrate
    if (await Vibration.hasVibrator() ?? false) Vibration.vibrate(pattern: [0,500,200,500]);
    // write event to firestore
    final fs = context.read<FirestoreService>();
    await fs.addEvent({
      'type': label,
      'timestamp': DateTime.now().toUtc(),
      'lat': null,
      'lng': null,
      'source': 'device',
    });
    // local & push notification via FCM service
    await FCMService.instance.showLocalNotification('Siren detected', label);
    // revert after 8s
    Future.delayed(Duration(seconds:8), () => setState(()=>_alert=false));
  }

  void _sendHelp() async {
    final fs = context.read<FirestoreService>();
    await fs.addEvent({
      'type': 'help_request',
      'timestamp': DateTime.now().toUtc(),
      'lat': null,
      'lng': null,
      'source': 'user',
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Send help request')));
  }

  @override
  void dispose(){
    _recorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final red = Colors.red[900];
    return Scaffold(
      appBar: AppBar(title: Text('Siren Detector'), backgroundColor: red),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(18),
        child: Column(
          children: [
            if(_alert)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(color: red, borderRadius: BorderRadius.circular(8)),
                child: Column(
                  children: [
                    Icon(Icons.warning_amber_rounded, size: 60, color: Colors.white),
                    SizedBox(height:10),
                    Text('SIREN DETECTED NEARBY', style: TextStyle(fontSize:22, fontWeight: FontWeight.bold)),
                    SizedBox(height:8),
                    Text('Stay alert. Vibration triggered.', textAlign: TextAlign.center),
                    SizedBox(height:12),
                    ElevatedButton(
                      onPressed: _sendHelp,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: red),
                      child: Padding(padding: EdgeInsets.symmetric(vertical:12,horizontal:20), child: Text('SEND')),
                    )
                  ],
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.blueGrey[900], borderRadius: BorderRadius.circular(8)),
                child: Column(
                  children: [
                    Text('Listening for sounds...', style: TextStyle(fontSize:18)),
                    SizedBox(height:8),
                    Text('Detected: $_detected', style: TextStyle(fontSize:16, color: Colors.lightBlueAccent)),
                    SizedBox(height:12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton.icon(onPressed: ()=> Navigator.pushNamed(context,'/events'),
                            icon: Icon(Icons.list), label: Text('Events')),
                        ElevatedButton.icon(onPressed: ()=> Navigator.pushNamed(context,'/map'),
                            icon: Icon(Icons.map), label: Text('Map')),
                      ],
                    )
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
