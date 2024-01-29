import 'package:flutter/material.dart';
import 'audio_recorder.dart';

const Color inactive = Colors.blueGrey;
const Color active = Colors.redAccent;

class RecordingControls extends StatelessWidget {
  final AudioState audioState;
  final VoidCallback onRecordPressed;
  final VoidCallback onUploadPressed;
  final VoidCallback onResetPressed;
  final bool isUploading;

  const RecordingControls({
    Key? key,
    required this.audioState,
    required this.onRecordPressed,
    required this.onUploadPressed,
    required this.onResetPressed,
    required this.isUploading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildRecordButton(),
        const SizedBox(width: 20),
        if (audioState == AudioState.playing ||
            audioState == AudioState.stopped)
          _buildResetButton(),
        const SizedBox(width: 20),
        if (audioState == AudioState.playing ||
            audioState == AudioState.stopped)
          _buildUploadButton(),
      ],
    );
  }

  Widget _buildRecordButton() {
    Icon icon;
    Color buttonColor;

    switch (audioState) {
      case AudioState.recording:
        icon = const Icon(Icons.stop, size: 50);
        buttonColor = active;
        break;
      case AudioState.playing:
        icon = const Icon(Icons.pause, size: 50);
        buttonColor = active;
        break;
      case AudioState.stopped:
        icon = const Icon(Icons.play_arrow, size: 50);
        buttonColor = inactive;
        break;
      default:
        icon = const Icon(Icons.mic, size: 50);
        buttonColor = inactive;
        break;
    }

    return CircleAvatar(
      radius: 35,
      backgroundColor: buttonColor,
      child: IconButton(
        icon: icon,
        iconSize: 50,
        color: Colors.white,
        onPressed: onRecordPressed,
      ),
    );
  }

  Widget _buildResetButton() {
    return CircleAvatar(
      radius: 35,
      backgroundColor: Colors.blueGrey,
      child: IconButton(
        icon: const Icon(Icons.delete, size: 50),
        color: Colors.white,
        onPressed: onResetPressed,
      ),
    );
  }

  Widget _buildUploadButton() {
    Color buttonColor = (isUploading) ? active : inactive;

    return CircleAvatar(
      radius: 35,
      backgroundColor: buttonColor,
      child: IconButton(
        icon: const Icon(Icons.upload, size: 50),
        color: Colors.white,
        onPressed: onUploadPressed,
      ),
    );
  }
}

class ResponseDisplay extends StatelessWidget {
  final String text;

  const ResponseDisplay({
    Key? key,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.blueGrey,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 18),
        textAlign: TextAlign.center,
      ),
    );
  }
}
