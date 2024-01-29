import 'package:http/http.dart' as http;
import 'dart:convert';
import 'audio_recorder.dart';

class NetworkHelper {
  final String endpoint;

  NetworkHelper(this.endpoint);

  Future<String> uploadRecording(AudioRecorder recorder) async {
    var uri = Uri.parse(endpoint);
    var request = http.MultipartRequest('POST', uri)
      ..fields['file'] = base64Encode(await recorder.toBytes());

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        return responseData;
      } else {
        return "Failed to upload file: ${response.statusCode}";
      }
    } on http.ClientException catch (e) {
      return "Client Exception: $e";
    } catch (e) {
      return "Error: $e";
    }
  }
}
