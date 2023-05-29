import 'package:hello_world/login_register.dart';
import 'package:hello_world/auth.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';

final Logger _logger = Logger();

// das ist der main Aufruf der app
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => Auth(),
      child: MaterialApp(
        title: "Digital Bodyguard",
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Consumer<Auth>(
          builder: (context, auth, child) {
            return auth.isLoggedIn ? const HomePage() : LoginPage();
          },
        ),
      ),
    );
  }
}

// ### my app start
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Was soll ich für dich untersuchen...'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FractionallySizedBox(
              widthFactor: 0.6,
              child: NeumorphicButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const EmailPage()),
                  );
                },
                style: NeumorphicStyle(
                  shape: NeumorphicShape.concave,
                  boxShape:
                      NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                child: const Text(
                  'E-Mail',
                  style: TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(height: 30),
            FractionallySizedBox(
              widthFactor: 0.6,
              child: NeumorphicButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LanguagePage()),
                  );
                },
                style: NeumorphicStyle(
                  shape: NeumorphicShape.concave,
                  boxShape:
                      NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                child: const Text(
                  'Sprache',
                  style: TextStyle(fontSize: 24),
                ),
              ),
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
  // Liste fuer die emails
  List<File> selectedEmailsFiles = [];

  void _removeSelectedFile(File file) {
    selectedEmailsFiles.remove(file);
    _logger.i('### Remove file: $file');
    setState(() {}); // Aktualisiert die Anzeige der ausgewählten Dateien
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.isNotEmpty) {
      List<File> pickedFiles = result.paths.map((path) => File(path!)).toList();
      selectedEmailsFiles.addAll(pickedFiles);
      setState(() {}); // Aktualisiert die Anzeige der ausgewählten Dateien
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
    _logger.i('### Sending data...');

    // Handle the API response here

    // Clear the selected file
    setState(() {
      selectedEmailsFiles = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('E-Mail'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _pickFile,
              child: const Text('E-Mail auswählen'),
            ),
            if (selectedEmailsFiles.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: selectedEmailsFiles.length,
                  itemBuilder: (BuildContext context, int index) {
                    final file = selectedEmailsFiles[index];
                    return ListTile(
                      title: Text(file.path),
                      trailing: GestureDetector(
                        onTap: () {
                          _removeSelectedFile(file);
                        },
                        child: const Icon(Icons.delete),
                      ),
                    );
                  },
                ),
              ),
            ElevatedButton(
              onPressed:
                  selectedEmailsFiles.isNotEmpty ? _compressAndSendEmail : null,
              child: const Text('Senden'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Abbrechen'),
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
  String? filePath;

  Future<void> _startRecording() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
      );

      if (result != null && result.files.isNotEmpty) {
        String? path = result.files.first.path;
        if (path != null) {
          setState(() {
            isRecording = true;
            filePath = path;
          });
        }
      }
    } catch (e) {
      _logger.e('Error picking audio file: $e');
    }
  }

  Future<void> _stopRecordingAndSend() async {
    if (isRecording && filePath != null) {
      // Compress the file to a ZIP archive
      String zipFilePath = await compressFileToZip(filePath!);

      // Send the ZIP file to the backend API
      String apiUrl = '<api_url>/send_speech_to_back_end';
      await sendFileToApi(apiUrl, zipFilePath);

      // Delete the temporary ZIP file
      await File(zipFilePath).delete();

      setState(() {
        isRecording = false;
        filePath = null;
      });
    }
  }

  Future<String> compressFileToZip(String filePath) async {
    // Compress the file to a temporary ZIP archive
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    String zipFilePath = '$tempPath/recording.zip';

    // Compress the file using your preferred compression library
    // (e.g., archive, zip, flutter_archive, etc.)

    return zipFilePath;
  }

  Future<void> sendFileToApi(String apiUrl, String filePath) async {
    // Send the file to the API using http package or any other preferred method
    // (e.g., multipart/form-data, base64 encoding, etc.)
    _logger.i('Sending file to API: $filePath');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sprache'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: isRecording ? null : _startRecording,
              child: const Text('Aufnahme starten'),
            ),
            ElevatedButton(
              onPressed: isRecording ? _stopRecordingAndSend : null,
              child: const Text('Aufnahme beenden und senden'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Abbrechen'),
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
