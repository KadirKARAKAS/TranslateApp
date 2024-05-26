import 'dart:math';
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
        title: const Text("HOME PAGE"),
      ),
      body: const Center(child: TextToSpeechWithWaveform()),
    );
  }
}

class TextToSpeechWithWaveform extends StatefulWidget {
  const TextToSpeechWithWaveform({Key? key}) : super(key: key);

  @override
  _TextToSpeechWithWaveformState createState() =>
      _TextToSpeechWithWaveformState();
}

class _TextToSpeechWithWaveformState extends State<TextToSpeechWithWaveform> {
  final FlutterTts flutterTts = FlutterTts();
  final TextEditingController textEditingController = TextEditingController();
  bool isSpeaking = false;

  @override
  void initState() {
    super.initState();
    flutterTts.setCompletionHandler(() {
      setState(() {
        isSpeaking = false;
      });
    });
    flutterTts.setErrorHandler((msg) {
      setState(() {
        isSpeaking = false;
      });
    });
  }

  Future<void> speak(String text) async {
    setState(() {
      isSpeaking = true;
    });
    await flutterTts.setLanguage("tr-TR");
    await flutterTts.setPitch(1);
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
        padding: const EdgeInsets.all(32),
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            if (isSpeaking)
              const Positioned(
                top: 0,
                child: SoundWaveformWidget(
                  count: 10,
                  minHeight: 20,
                  maxHeight: 100,
                  isAnimating: true,
                ),
              )
            else
              const Positioned(
                top: 0,
                child: SoundWaveformWidget(
                  count: 10,
                  minHeight: 20,
                  maxHeight: 100,
                  isAnimating: false,
                ),
              ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const SizedBox(height: 120),
                TextFormField(
                  controller: textEditingController,
                  decoration: const InputDecoration(
                    labelText: "Enter text",
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  child: const Text("SESLİ OKU"),
                  onPressed: () => speak(textEditingController.text),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SoundWaveformWidget extends StatefulWidget {
  final int count;
  final double minHeight;
  final double maxHeight;
  final bool isAnimating;

  const SoundWaveformWidget({
    Key? key,
    this.count = 10,
    this.minHeight = 20,
    this.maxHeight = 100,
    this.isAnimating = false,
  }) : super(key: key);

  @override
  State<SoundWaveformWidget> createState() => _SoundWaveformWidgetState();
}

class _SoundWaveformWidgetState extends State<SoundWaveformWidget>
    with TickerProviderStateMixin {
  late AnimationController controller;
  late List<double> heights;
  final Random random = Random();

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.isAnimating ? 800 : 0),
    );

    if (widget.isAnimating) {
      controller.repeat();
    }

    heights = List<double>.filled(widget.count, widget.minHeight);

    if (widget.isAnimating) {
      _randomizeHeights();
    }
  }

  void _randomizeHeights() {
    Future.delayed(
      Duration(milliseconds: 800 ~/ widget.count),
      () {
        if (mounted && widget.isAnimating) {
          setState(() {
            for (int i = 0; i < heights.length; i++) {
              heights[i] = widget.minHeight +
                  random.nextDouble() * (widget.maxHeight - widget.minHeight);
            }
          });
          _randomizeHeights();
        }
      },
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.isAnimating
        ? AnimatedBuilder(
            animation: controller,
            builder: (context, child) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  widget.count,
                  (i) => AnimatedContainer(
                    duration: Duration(milliseconds: 800 ~/ widget.count),
                    margin: i == (widget.count - 1)
                        ? EdgeInsets.zero
                        : const EdgeInsets.only(right: 5),
                    height: heights[i],
                    width: 20,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                  ),
                ),
              );
            },
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              widget.count,
              (i) => Container(
                margin: i == (widget.count - 1)
                    ? EdgeInsets.zero
                    : const EdgeInsets.only(right: 5),
                height: widget.minHeight,
                width: 20,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(9999),
                ),
              ),
            ),
          );
  }
}
