import 'dart:async';
import 'dart:io';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

typedef ChunkCallback = Future<void> Function(String path);

class AudioRecorder {
  final Record _rec = Record();
  ChunkCallback? onChunkReady;
  bool _running = false;

  Future<void> init() async {
    // permissions handled by record plugin
  }

  Future<void> startRecordingLoop() async {
    _running = true;
    while(_running){
      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/chunk_${DateTime.now().millisecondsSinceEpoch}.wav';
      await _rec.start(path: path, encoder: AudioEncoder.wav);
      // record for 1.5 seconds
      await Future.delayed(Duration(milliseconds:1500));
      await _rec.stop();
      if(onChunkReady != null) await onChunkReady!(path);
      // small delay between chunks
      await Future.delayed(Duration(milliseconds:200));
    }
  }

  Future<void> dispose() async {
    _running = false;
    if(await _rec.isRecording()) await _rec.stop();
  }
}
