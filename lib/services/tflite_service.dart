import 'dart:io';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;

class TFLiteService {
  TFLiteService._private();
  static final TFLiteService instance = TFLiteService._private();

  Interpreter? _interpreter;
  List<String> _labels = [];

  Future<void> loadModel() async {
    final modelData = await rootBundle.load('assets/models/yamnet.tflite');
    _interpreter = await Interpreter.fromBuffer(modelData.buffer);
    final labelsData = await rootBundle.loadString('assets/models/yamnet_labels.txt');
    _labels = labelsData.split('\n').map((s) => s.trim()).where((s)=>s.isNotEmpty).toList();
  }

 
  Future<String?> classifyFile(String wavPath) async {
    if (_interpreter == null) return null;
    
    final fake = ['Siren', 'Car horn', 'Alarm', 'Speech', 'Silence'];
    final idx = DateTime.now().millisecondsSinceEpoch % fake.length;
    return fake[idx];
  }
}
