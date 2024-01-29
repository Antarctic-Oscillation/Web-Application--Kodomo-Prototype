import 'dart:async';

import 'package:flutter/microphone.dart';
import 'package:flutter/just_audio.dart';

enum AudioState { none, recording, playing, stopped }

class AudioRecorder {
  late MicrophoneRecorder _microphoneRecorder;
  late AudioPlayer _audioPlayer;

  void initialize() {
    _microphoneRecorder = MicrophoneRecorder()..init();
    _audioPlayer = AudioPlayer();
  }

  AudioState toggleRecording(AudioState currentState) {
    switch (currentState) {
      case AudioState.none:
        _microphoneRecorder.start();
        return AudioState.recording;
      case AudioState.stopped:
        return AudioState.playing;
      case AudioState.recording:
        _microphoneRecorder.stop();
        return AudioState.stopped;
      default:
        return AudioState.stopped;
    }
  }

  void playRecording() {
    _audioPlayer.setUrl(_microphoneRecorder.value.recording!.url).then((_) {
      _audioPlayer.play();
    });
  }

  void reset() {
    _microphoneRecorder.dispose();
    _microphoneRecorder = MicrophoneRecorder()..init();
  }

  Stream<ProcessingState> get playbackStateStream => _audioPlayer.processingStateStream;

  Future<List<int>> toBytes() async {
    if (_microphoneRecorder.value.recording != null) {
      return _microphoneRecorder.toBytes();
    } else {
      throw Exception('No recording found');
    }
  }
}
