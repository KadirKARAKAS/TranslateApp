import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("HOME PAGE"),
      ),
      body: Center(child: TextToSpeech()),
    );
  }
}

class TextToSpeech extends StatefulWidget {
  @override
  _TextToSpeechState createState() => _TextToSpeechState();
}

class _TextToSpeechState extends State<TextToSpeech> {
  final FlutterTts flutterTts = FlutterTts();
  final TextEditingController textEditingController = TextEditingController();

  Future<void> speak(String text) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1); //0.5-1.5
    await flutterTts.speak(text);
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextFormField(
              controller: textEditingController,
              decoration: InputDecoration(
                labelText: "Enter text",
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text("SESLİ OKU"),
              onPressed: () => speak(textEditingController.text),
            )
          ],
        ),
      ),
    );
  }
}
