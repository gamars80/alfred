import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

class MicrophoneHook {
  final bool isPermissionGranted;
  final bool isPermissionDenied;
  final bool isRecording;
  final Future<bool> Function() requestPermission;
  final Future<void> Function() startRecording;
  final Future<void> Function() stopRecording;

  MicrophoneHook({
    required this.isPermissionGranted,
    required this.isPermissionDenied,
    required this.isRecording,
    required this.requestPermission,
    required this.startRecording,
    required this.stopRecording,
  });
}

MicrophoneHook useMicrophone() {
  final isPermissionGranted = useState(false);
  final isPermissionDenied = useState(false);
  final isRecording = useState(false);
  final recorder = useState<AudioRecorder?>(null);

  Future<bool> requestPermission() async {
    final status = await Permission.microphone.request();
    
    if (status.isGranted) {
      isPermissionGranted.value = true;
      isPermissionDenied.value = false;
      return true;
    } else {
      isPermissionDenied.value = true;
      return false;
    }
  }

  Future<void> startRecording() async {
    if (!isPermissionGranted.value) {
      final granted = await requestPermission();
      if (!granted) return;
    }

    try {
      final record = AudioRecorder();
      await record.start(
        const RecordConfig(),
        path: '${DateTime.now().millisecondsSinceEpoch}.m4a',
      );
      recorder.value = record;
      isRecording.value = true;
    } catch (e) {
      print('Error starting recording: $e');
    }
  }

  Future<void> stopRecording() async {
    if (recorder.value != null && isRecording.value) {
      await recorder.value!.stop();
      isRecording.value = false;
    }
  }

  return MicrophoneHook(
    isPermissionGranted: isPermissionGranted.value,
    isPermissionDenied: isPermissionDenied.value,
    isRecording: isRecording.value,
    requestPermission: requestPermission,
    startRecording: startRecording,
    stopRecording: stopRecording,
  );
} 