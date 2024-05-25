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

// Text-to-speech ve dalgalanma animasyonunun durumu
class _TextToSpeechWithWaveformState extends State<TextToSpeechWithWaveform> {
  final FlutterTts flutterTts = FlutterTts(); // Text-to-speech nesnesi
  final TextEditingController textEditingController =
      TextEditingController(); // Metin girişi kontrolcüsü
  bool isSpeaking = false; // Konuşma durumu

  @override
  void initState() {
    super.initState();
    flutterTts.setCompletionHandler(() {
      setState(() {
        isSpeaking = false; // Konuşma bittiğinde durumu güncelle
      });
    });
    flutterTts.setErrorHandler((msg) {
      setState(() {
        isSpeaking = false; // Hata oluştuğunda durumu güncelle
      });
    });
  }

  // Metni sesli okuma fonksiyonu
  Future<void> speak(String text) async {
    setState(() {
      isSpeaking = true; // Konuşma başladığında durumu güncelle
    });
    await flutterTts.setLanguage("tr-TR"); // Dil ayarı
    await flutterTts.setPitch(1); // Ses tonu ayarı (0.5-1.5 arası)
    await flutterTts.speak(text); // Metni oku
  }

  @override
  void dispose() {
    textEditingController.dispose(); // Kaynakları serbest bırak
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.all(32), // Kenar boşlukları
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            if (isSpeaking) // Konuşma durumuna göre dalgalanma animasyonu göster
              const Positioned(
                top: 0,
                child: SoundWaveformWidget(
                  count: 10, // Çubuk sayısı
                  minHeight: 20, // Çubukların minimum yüksekliği
                  maxHeight: 100, // Çubukların maksimum yüksekliği
                ),
              ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const SizedBox(
                    height: 120), // TextFormField'ı aşağı taşımak için boşluk
                TextFormField(
                  controller: textEditingController, // Metin giriş kontrolcüsü
                  decoration: const InputDecoration(
                    labelText: "Enter text", // Giriş kutusu etiketi
                  ),
                ),
                const SizedBox(
                    height: 20), // Giriş kutusu ile buton arasındaki boşluk
                ElevatedButton(
                  child: const Text("SESLİ OKU"), // Buton metni
                  onPressed: () => speak(
                      textEditingController.text), // Butona basılınca metni oku
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Dalgalanma animasyonu widget'ı
class SoundWaveformWidget extends StatefulWidget {
  final int count; // Çubuk sayısı
  final double minHeight; // Çubukların minimum yüksekliği
  final double maxHeight; // Çubukların maksimum yüksekliği
  final int durationInMilliseconds; // Animasyon süresi

  const SoundWaveformWidget({
    Key? key,
    this.count = 10, // Artırılmış çubuk sayısı
    this.minHeight = 20, // Artırılmış minimum yükseklik
    this.maxHeight = 100, // Artırılmış maksimum yükseklik
    this.durationInMilliseconds = 800, // Animasyon süresi
  }) : super(key: key);

  @override
  State<SoundWaveformWidget> createState() => _SoundWaveformWidgetState();
}

// Dalgalanma animasyonunun durumu
class _SoundWaveformWidgetState extends State<SoundWaveformWidget>
    with TickerProviderStateMixin {
  late AnimationController controller; // Animasyon kontrolcüsü
  late List<double> heights; // Çubukların yükseklik listesi
  final Random random = Random(); // Rastgele sayı üretici

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync:
          this, // TickerProviderStateMixin'den gelen animasyon senkronizasyonu
      duration: Duration(
          milliseconds: widget.durationInMilliseconds), // Animasyon süresi
    )..repeat(); // Animasyonu tekrar et
    heights = List<double>.filled(
        widget.count, widget.minHeight); // Çubuk yüksekliklerini başlat
    _randomizeHeights(); // Çubuk yüksekliklerini rastgele ayarla
  }

  // Çubuk yüksekliklerini rastgele ayarlayan fonksiyon
  void _randomizeHeights() {
    Future.delayed(
      Duration(milliseconds: widget.durationInMilliseconds ~/ widget.count),
      () {
        if (mounted) {
          setState(() {
            for (int i = 0; i < heights.length; i++) {
              heights[i] = widget.minHeight +
                  random.nextDouble() *
                      (widget.maxHeight -
                          widget.minHeight); // Rastgele yükseklik ayarla
            }
          });
          _randomizeHeights(); // Yeniden çağırarak sürekli güncelle
        }
      },
    );
  }

  @override
  void dispose() {
    controller.dispose(); // Kaynakları serbest bırak
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller, // Animasyon kontrolcüsüne bağlı
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            widget.count, // Çubuk sayısına göre çubuk oluştur
            (i) => AnimatedContainer(
              duration: Duration(
                  milliseconds: widget.durationInMilliseconds ~/ widget.count),
              margin: i == (widget.count - 1)
                  ? EdgeInsets.zero
                  : const EdgeInsets.only(right: 5), // Çubuklar arasına boşluk
              height: heights[i], // Çubuğun yüksekliği
              width: 20, // Çubuğun genişliği
              decoration: BoxDecoration(
                color: Colors.black, // Çubuğun rengi
                borderRadius:
                    BorderRadius.circular(9999), // Çubuğun köşe yuvarlaklığı
              ),
            ),
          ),
        );
      },
    );
  }
}
