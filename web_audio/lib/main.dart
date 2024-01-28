import 'package:flutter/material.dart';
import 'package:flutter/microphone.dart';
import 'package:flutter/just_audio.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

// ignore: constant_identifier_names
enum AudioState { Null, recording, stop, play }

const String endpoint = 'http://192.168.100.44:8080';
const veryDarkBlue = Color(0xff172133);
const kindaDarkBlue = Color(0xff202641);

Future<void> main() async {
  runApp(const RecordingScreen());
}

class RecordingScreen extends StatefulWidget {
  const RecordingScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RecordingScreenState createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen> {
  late AudioState audioState;
  late MicrophoneRecorder _recorder;
  late AudioPlayer player;
  String serverResponse = '';
  bool uploading = false;

  @override
  void initState() {
    super.initState();
    audioState = AudioState.Null;
    _recorder = MicrophoneRecorder()..init();
  }

  void handleAudioState(AudioState state) {
    setState(() {
      if (audioState == AudioState.Null) {
        // Starts recording
        audioState = AudioState.recording;
        _recorder.start();
        // Finished recording
      } else if (audioState == AudioState.recording) {
        audioState = AudioState.play;
        _recorder.stop();

        // Play recorded audio
      } else if (audioState == AudioState.play) {
        audioState = AudioState.stop;
        player = AudioPlayer();
        player.setUrl(_recorder.value.recording!.url).then((_) {
          return player.play().then((_) {
            setState(() {
              audioState = AudioState.play;
            });
          });
        });

        // Stop recorded audio
      } else if (audioState == AudioState.stop) {
        audioState = AudioState.play;
        player.stop();
      }
    });
  }

  void post(MicrophoneRecorder _recorder) async {
    var uri = Uri.parse('http://192.168.100.44:8080/upload');
    var request = http.MultipartRequest('POST', uri)
      ..fields['file'] = base64Encode(await _recorder.toBytes());

    try {
      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        print("File uploaded successfully. Server response: $responseData");

        // Update the server response state
        setState(() {
          serverResponse = responseData;
        });
      } else {
        print("Failed to upload file: ${response.statusCode}");
        setState(() {
          serverResponse = "Failed to upload file: ${response.statusCode}";
        });
      }
    } catch (e) {
      print("Error: $e");
      setState(() {
        serverResponse = "Error: $e";
      });
    }
  }

  Future<void> fetchFromServer(String url) async {
    try {
      var response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // If the server did return a 200 OK response,
        // then parse the JSON.
        print('Response data: ${response.body}');
      } else {
        // If the server did not return a 200 OK response,
        // then throw an exception.
        print('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
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
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: handleAudioColour(),
                    ),
                    child: RawMaterialButton(
                      fillColor: Colors.white,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(30),
                      onPressed: () => handleAudioState(audioState),
                      child: getIcon(audioState),
                    ),
                  ),
                  const SizedBox(width: 20),
                  if (audioState == AudioState.play ||
                      audioState == AudioState.stop)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: kindaDarkBlue,
                      ),
                      child: RawMaterialButton(
                        fillColor: Colors.white,
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(30),
                        onPressed: () => setState(() {
                          audioState = AudioState.Null;
                          serverResponse = '';
                          uploading = false;
                          _recorder.dispose();
                          _recorder = MicrophoneRecorder()..init();
                        }),
                        child: const Icon(Icons.replay, size: 50),
                      ),
                    ),
                  const SizedBox(width: 20),
                  if (audioState == AudioState.play)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: kindaDarkBlue,
                      ),
                      child: RawMaterialButton(
                        fillColor: Colors.white,
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(30),
                        onPressed: () => setState(() {
                          post(_recorder);
                          uploading = true;
                        }),
                        child: const Icon(Icons.upload, size: 50),
                      ),
                    ),
                ],
              ),
              if (serverResponse.isEmpty && audioState == AudioState.play)
                buildServerResponse('awaiting upload..'),
              if (serverResponse.isEmpty &&
                  audioState == AudioState.play &&
                  uploading)
                buildServerResponse('awaiting result..'),
              if (serverResponse.isNotEmpty && audioState == AudioState.play)
                buildServerResponse(serverResponse),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildServerResponse(String text) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: kindaDarkBlue,
        borderRadius: BorderRadius.circular(15), // Rounded corners
      ),
      child: Text(
        text,
        style: TextStyle(color: Colors.white, fontSize: 18),
        textAlign: TextAlign.center,
      ),
    );
  }

  Color handleAudioColour() {
    if (audioState == AudioState.recording) {
      return Colors.deepOrangeAccent.shade700.withOpacity(0.5);
    } else if (audioState == AudioState.stop) {
      return Colors.green.shade900;
    } else {
      return kindaDarkBlue;
    }
  }

  Icon getIcon(AudioState state) {
    switch (state) {
      case AudioState.play:
        return const Icon(Icons.play_arrow, size: 50);
      case AudioState.stop:
        return const Icon(Icons.stop, size: 50);
      case AudioState.recording:
        return const Icon(Icons.mic, color: Colors.redAccent, size: 50);
      default:
        return const Icon(Icons.mic, size: 50);
    }
  }
}
