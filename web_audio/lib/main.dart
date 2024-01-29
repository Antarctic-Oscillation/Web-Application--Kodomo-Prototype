import 'package:flutter/just_audio.dart';
import 'package:flutter/material.dart';
import 'include/audio_recorder.dart'; // Handling audio recording
import 'include/network_helper.dart'; // Handling network requests
import 'include/ui_components.dart'; // Reusable UI components

const String endpoint = 'http://192.168.100.39:8080/upload';
const Color veryDarkBlue = Color(0xff172133);
const Color kindaDarkBlue = Color(0xff202641);

void main() => runApp(const RecordingScreen());

class RecordingScreen extends StatefulWidget {
  const RecordingScreen({super.key});

  @override
  State<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen> {
  final AudioRecorder recorder = AudioRecorder();
  final NetworkHelper networkHelper = NetworkHelper(endpoint);
  AudioState audioState = AudioState.none;
  String serverResponse = '';
  bool isUploading = false;

  @override
  void initState() {
    super.initState();
    recorder.initialize();
  }

  void handleAudioState() {
    setState(() {
      audioState = recorder.toggleRecording(audioState);
      if (audioState == AudioState.playing) {
        recorder.playRecording();
        recorder.playbackStateStream.listen((state) {
          if (state == ProcessingState.completed) {
            setState(() {
              audioState = AudioState.stopped;
            });
          }
        });
      }
    });
  }

  void handleUpload() async {
    setState(() =>isUploading = true);
    final response = await networkHelper.uploadRecording(recorder);
    setState(() {
      serverResponse = response;
      isUploading = false;
    });
  }

  void handleReset() {
    setState(() {
      audioState = AudioState.none;
      serverResponse = '';
      isUploading = false;
      recorder.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Microphone Flutter Web',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: veryDarkBlue,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RecordingControls(
                audioState: audioState,
                onRecordPressed: handleAudioState,
                onUploadPressed: handleUpload,
                onResetPressed: handleReset,
                isUploading: isUploading,
              ),
              if (serverResponse.isNotEmpty || isUploading)
                ResponseDisplay(
                  text: serverResponse.isEmpty && isUploading
                      ? 'Uploading...'
                      : serverResponse,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
