import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:audio_recorder/audio_recorder.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Intro app",
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

// ### my app start
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EmailPage()),
                );
              },
              child: const Text('E-Mail'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LanguagePage()),
                );
              },
              child: const Text('Sprache'),
            ),
          ],
        ),
      ),
    );
  }
}

class EmailPage extends StatefulWidget {
  const EmailPage({super.key});

  @override
  _EmailPageState createState() => _EmailPageState();
}

class _EmailPageState extends State<EmailPage> {
  File? selectedFile;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null) {
      setState(() {
        selectedFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _compressAndSendEmail() async {
    // Compress selected file as a ZIP file
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    String zipFilePath = '$tempPath/email.zip';
    // Compress the file here (using a library like archive)

    // Send the ZIP file to the backend API
    String apiUrl = '<api_url>/send_email_to_back_end';
    // Use http package to make the API call, sending the zipFilePath

    // Handle the API response here

    // Clear the selected file
    setState(() {
      selectedFile = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('E-Mail'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _pickFile,
              child: Text('E-Mail auswählen'),
            ),
            if (selectedFile != null) Text(selectedFile!.path),
            ElevatedButton(
              onPressed: selectedFile != null ? _compressAndSendEmail : null,
              child: Text('Senden'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Abbrechen'),
            ),
          ],
        ),
      ),
    );
  }
}

class LanguagePage extends StatefulWidget {
  const LanguagePage({super.key});

  @override
  _LanguagePageState createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  bool isRecording = false;
  Recording? recording;

  Future<void> _startRecording() async {
    if (await Permission.microphone.request().isGranted) {
      setState(() {
        isRecording = true;
      });

      Directory tempDir = await getTemporaryDirectory();
      String tempPath = tempDir.path;
      String filePath = '$tempPath/recording.wav';

      await AudioRecorder.start(
        path: filePath,
        audioOutputFormat: AudioOutputFormat.WAV,
      );

      bool isRecording = await AudioRecorder.isRecording;

      setState(() {
        recording = Recording(path: filePath, duration: Duration.zero);
      });
    } else {
      // Permission denied
    }
  }

  Future<void> _pauseRecording() async {
    if (isRecording) {
      await AudioRecorder.pause();
      setState(() {
        isRecording = false;
      });
    }
  }

  Future<void> _resumeRecording() async {
    if (!isRecording) {
      await AudioRecorder.resume();
      setState(() {
        isRecording = true;
      });
    }
  }

  Future<void> _stopRecordingAndSend() async {
    if (isRecording) {
      Recording status = await AudioRecorder.stop();
      setState(() {
        isRecording = false;
        recording = Recording(
          path: status.path,
          duration: Duration(milliseconds: status.duration.inMilliseconds),
        );
      });

      // Send the recording to the backend API
      String apiUrl = '<api_url>/send_speech_to_back_end';
      // Use http package to make the API call, sending the recording.filePath

      // Handle the API response here
    }
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await AudioRecorder.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sprache'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                if (isRecording) {
                  _pauseRecording();
                } else {
                  _startRecording();
                }
              },
              child: Text(isRecording ? 'Pause' : 'Aufnahme starten'),
            ),
            ElevatedButton(
              onPressed: isRecording ? _stopRecordingAndSend : null,
              child: Text('Aufnahme beenden und senden'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Abbrechen'),
            ),
          ],
        ),
      ),
    );
  }
}

// ###### template start
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.
  // This class is the configuration for the state.
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: const Text('Flutter Demo Click Counter'),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: const TextStyle(fontSize: 25),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
