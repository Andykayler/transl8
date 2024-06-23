import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

enum TranslationDirection { EnglishToChichewa, ChichewaToEnglish, TumbukaToEnglish, EnglishToTumbuka }

class SpeechTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: const Color.fromARGB(255, 18, 32, 47)),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: SpeechButton(),
        ),
      ),
    );
  }
}

class SpeechButton extends StatefulWidget {
  @override
  _SpeechButtonState createState() => _SpeechButtonState();
}

class _SpeechButtonState extends State<SpeechButton> with TickerProviderStateMixin {
  static const _kToggleDuration = Duration(milliseconds: 300);
  static const _kRotationDuration = Duration(seconds: 5);

  bool isListening = false;
  late stt.SpeechToText _speech;
  late AnimationController _rotationController;
  late AnimationController _scaleController;
  double _rotation = 0;
  double _scale = 0.85;
  String _translatedText = '';
  String _translation = '';
  TextEditingController _textEditingController = TextEditingController();
  TranslationDirection _selectedDirection = TranslationDirection.EnglishToChichewa;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _rotationController = AnimationController(vsync: this, duration: _kRotationDuration)
      ..addListener(() => setState(() => _rotation = _rotationController.value * 2 * pi))
      ..repeat();

    _scaleController = AnimationController(vsync: this, duration: _kToggleDuration)
      ..addListener(() => setState(() => _scale = (_scaleController.value * 0.2) + 0.85));
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _rotationController.dispose();
    _speech.stop();
    super.dispose();
  }

  Future<void> _translateAndSaveText(String inputText) async {
    try {
      final directionMap = {
        TranslationDirection.EnglishToChichewa: 'en-ny',
        TranslationDirection.ChichewaToEnglish: 'ny-en',
        TranslationDirection.TumbukaToEnglish: 'tum-en',
        TranslationDirection.EnglishToTumbuka: 'en-tum',
      };

      final response = await http.post(
        Uri.parse('http://192.168.43.76:5000/translate'), // Use correct IP for emulator/device
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(<String, dynamic>{
          'text': inputText,
          'direction': directionMap[_selectedDirection],
        }),
      );

      print('Request payload: ${jsonEncode(<String, dynamic>{
        'text': inputText,
        'direction': directionMap[_selectedDirection],
      })}');
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final translatedText = jsonDecode(response.body)['translated_text'];
        setState(() {
          _translation = translatedText;
        });
        print('Translated text: $_translation');

        final User? user = FirebaseAuth.instance.currentUser;
        final String? userId = user?.uid;

        if (userId != null) {
          await FirebaseFirestore.instance.collection('translations').add({
            'userId': userId,
            'original_text': inputText,
            'translated_text': translatedText,
            'direction': directionMap[_selectedDirection],
            'timestamp': DateTime.now(),
          });
        } else {
          print('User not authenticated.');
        }
      } else {
        print('Failed to load translation: ${response.statusCode}');
        throw Exception('Failed to load translation');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _onToggle() async {
    setState(() {
      isListening = !isListening;
      _translation = '';
    });

    if (isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) => print('onStatus: $status'),
        onError: (error) => print('onError: $error'),
      );
      if (available) {
        _speech.listen(
          onResult: (val) async {
            if (val.finalResult) {
              setState(() {
                _translatedText = val.recognizedWords;
              });
              print('Recognized text: $_translatedText');
              await _translateAndSaveText(_translatedText);
            }
          },
        );
      } else {
        print('Speech recognition not available');
      }
      _scaleController.forward();
    } else {
      _speech.stop();
      _scaleController.reverse();
    }
  }

  Widget _buildIcon(bool isListening) {
    return SizedBox.expand(
      key: ValueKey<bool>(isListening),
      child: IconButton(
        icon: isListening
            ? const Icon(Icons.mic, color: Colors.black, size: 90)
            : const Icon(Icons.mic_none, color: Colors.black, size: 90),
        onPressed: _onToggle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        DropdownButton<TranslationDirection>(
          value: _selectedDirection,
          onChanged: (TranslationDirection? newValue) {
            setState(() {
              _selectedDirection = newValue!;
            });
          },
          items: TranslationDirection.values.map((TranslationDirection direction) {
            return DropdownMenuItem<TranslationDirection>(
              value: direction,
              child: Text(
                direction.toString().split('.').last.replaceAll('To', ' to '),
                style: const TextStyle(color: Colors.white),
              ),
            );
          }).toList(),
        ),
        Flexible(
          child: AspectRatio(
            aspectRatio: 1,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (!_scaleController.isDismissed) ...[
                  Blob(color: const Color(0xff0092ff), scale: _scale, rotation: _rotation),
                  Blob(color: const Color(0xff4ac7b7), scale: _scale, rotation: _rotation * 2 - 30),
                  Blob(color: const Color(0xffa4a6f6), scale: _scale, rotation: _rotation * 3 - 45),
                ],
                Container(
                  constraints: const BoxConstraints.expand(),
                  child: AnimatedSwitcher(
                    child: _buildIcon(isListening),
                    duration: _kToggleDuration,
                  ),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Flexible(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SingleChildScrollView(
              child: Text(
                _translation,
                style: const TextStyle(color: Colors.white, fontSize: 20),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class Blob extends StatelessWidget {
  final double rotation;
  final double scale;
  final Color color;

  const Blob({this.color = Colors.blue, this.rotation = 0, this.scale = 1});

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scale,
      child: Transform.rotate(
        angle: rotation,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(150),
              topRight: Radius.circular(150),
              bottomLeft: Radius.circular(150),
              bottomRight: Radius.circular(150),
            ),
          ),
        ),
      ),
    );
  }
}
