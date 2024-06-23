import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_samples/samples/ui/rive_app/on_boarding/signin_view.dart';
import 'package:flutter_samples/samples/ui/rive_app/speach.dart';
import 'package:rive/rive.dart' hide LinearGradient;
import 'dart:math' as math;
import 'package:flutter_samples/samples/ui/rive_app/navigation/home_tab_view.dart';
import 'package:flutter_samples/samples/ui/rive_app/on_boarding/onboarding_view.dart';
import 'package:flutter_samples/samples/ui/rive_app/navigation/side_menu.dart';
import 'package:flutter_samples/samples/ui/rive_app/theme.dart';
import 'package:flutter_samples/samples/ui/rive_app/assets.dart' as app_assets;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:camera/camera.dart';
import 'dart:io';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';



// Common Tab Scene for the tabs other than 1st one, showing only tab name in center
Widget commonTabScene(String tabName) {
  return Container(
    color: RiveAppTheme.background,
    alignment: Alignment.center,
    child: Text(
      tabName,
      style: const TextStyle(
        fontSize: 28,
        fontFamily: "Poppins",
        color: Colors.black,
      ),
    ),
  );
}

class RiveAppHome extends StatefulWidget {
  const RiveAppHome({Key? key}) : super(key: key);

  static const String route = '/course-rive';

  @override
  State<RiveAppHome> createState() => _RiveAppHomeState();
}

class _RiveAppHomeState extends State<RiveAppHome> with TickerProviderStateMixin {
  late AnimationController? _animationController;
  late AnimationController? _onBoardingAnimController;
  late Animation<double> _onBoardingAnim;
  late Animation<double> _sidebarAnim;

  late SMIBool _menuBtn;

  bool _showOnBoarding = false;
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    const HomeTabView(),
    const TranslateTab(),
    const CaptureTab(),
    SpeechTab(),
  ];

  final springDesc = const SpringDescription(
    mass: 0.1,
    stiffness: 40,
    damping: 5,
  );

  void _onMenuIconInit(Artboard artboard) {
    final controller = StateMachineController.fromArtboard(artboard, "State Machine");
    artboard.addController(controller!);
    _menuBtn = controller.findInput<bool>("isOpen") as SMIBool;
    _menuBtn.value = true;
  }

  void _presentOnBoarding(bool show) {
    if (show) {
      setState(() {
        _showOnBoarding = true;
      });
      final springAnim = SpringSimulation(springDesc, 0, 1, 0);
      _onBoardingAnimController?.animateWith(springAnim);
    } else {
      _onBoardingAnimController?.reverse().whenComplete(() => {
            setState(() {
              _showOnBoarding = false;
            })
          });
    }
  }

  void onMenuPress() {
    if (_menuBtn.value) {
      final springAnim = SpringSimulation(springDesc, 0, 1, 0);
      _animationController?.animateWith(springAnim);
    } else {
      _animationController?.reverse();
    }
    _menuBtn.change(!_menuBtn.value);

    SystemChrome.setSystemUIOverlayStyle(_menuBtn.value
        ? SystemUiOverlayStyle.dark
        : SystemUiOverlayStyle.light);
  }

  @override
  void initState() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      upperBound: 1,
      vsync: this,
    );
    _onBoardingAnimController = AnimationController(
      duration: const Duration(milliseconds: 350),
      upperBound: 1,
      vsync: this,
    );

    _sidebarAnim = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _animationController!,
      curve: Curves.linear,
    ));

    _onBoardingAnim = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _onBoardingAnimController!,
      curve: Curves.linear,
    ));

    super.initState();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    _onBoardingAnimController?.dispose();
    super.dispose();
  }

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SignInView()), // Adjust this according to your actual SignInView widget
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          Positioned(child: Container(color: RiveAppTheme.background2)),
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: _sidebarAnim,
              builder: (BuildContext context, Widget? child) {
                return Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(((1 - _sidebarAnim.value) * -30) * math.pi / 180)
                    ..translate((1 - _sidebarAnim.value) * -300),
                  child: child,
                );
              },
              child: FadeTransition(
                opacity: _sidebarAnim,
                child: const SideMenu(),
              ),
            ),
          ),
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: _showOnBoarding ? _onBoardingAnim : _sidebarAnim,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1 -
                      (_showOnBoarding
                          ? _onBoardingAnim.value * 0.08
                          : _sidebarAnim.value * 0.1),
                  child: Transform.translate(
                    offset: Offset(_sidebarAnim.value * 265, 0),
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY((_sidebarAnim.value * 30) * math.pi / 180),
                      child: child,
                    ),
                  ),
                );
              },
              child: _screens[_selectedIndex],
            ),
          ),
          AnimatedBuilder(
            animation: _sidebarAnim,
            builder: (context, child) {
              return Positioned(
                top: MediaQuery.of(context).padding.top + 20,
                right: (_sidebarAnim.value * -100) + 16,
                child: child!,
              );
            },
            child: GestureDetector(
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: RiveAppTheme.shadow.withOpacity(0.2),
                        blurRadius: 5,
                        offset: const Offset(0, 5),
                      )
                    ],
                  ),
                  child: const Icon(Icons.logout),
                ),
              ),
              onTap: _logout,
            ),
          ),
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: _sidebarAnim,
              builder: (context, child) {
                return SafeArea(
                  child: Row(
                    children: [
                      SizedBox(width: _sidebarAnim.value * 216),
                      child!,
                    ],
                  ),
                );
              },
              child: GestureDetector(
                onTap: onMenuPress,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Container(
                    width: 44,
                    height: 44,
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(44 / 2),
                      boxShadow: [
                        BoxShadow(
                          color: RiveAppTheme.shadow.withOpacity(0.2),
                          blurRadius: 5,
                          offset: const Offset(0, 5),
                        )
                      ],
                    ),
                    child: RiveAnimation.asset(
                      app_assets.menuButtonRiv,
                      stateMachines: const ["State Machine"],
                      animations: const ["open", "close"],
                      onInit: _onMenuIconInit,
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_showOnBoarding)
            RepaintBoundary(
              child: AnimatedBuilder(
                animation: _onBoardingAnim,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                        0,
                        -(MediaQuery.of(context).size.height +
                                MediaQuery.of(context).padding.bottom) *
                            (1 - _onBoardingAnim.value)),
                    child: child!,
                  );
                },
                child: SafeArea(
                  top: false,
                  maintainBottomViewPadding: true,
                  child: Container(
                    clipBehavior: Clip.hardEdge,
                    margin: EdgeInsets.only(
                        bottom: MediaQuery.of(context).padding.bottom + 18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30)),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 40,
                            offset: const Offset(0, 40))
                      ],
                    ),
                    child: OnBoardingView(
                      closeModal: () {
                        _presentOnBoarding(false);
                      },
                    ),
                  ),
                ),
              ),
            ),
          IgnorePointer(
            ignoring: true,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: AnimatedBuilder(
                  animation: !_showOnBoarding
                      ? _sidebarAnim
                      : const AlwaysStoppedAnimation(0.0),
                  builder: (context, child) {
                    return SafeArea(
                      top: false,
                      bottom: true,
                      child: FractionallySizedBox(
                        alignment: Alignment.bottomCenter,
                        heightFactor:
                            _sidebarAnim.value > 0.7 ? 1.0 : 0.0,
                      ),
                    );
                  }),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomNavBar(
        currentIndex: _selectedIndex,
        onTabSelected: _onTabSelected,
        isVisible: !_showOnBoarding,
      ),
    );
  }
}class CustomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabSelected;
  final bool isVisible;

  const CustomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTabSelected,
    this.isVisible = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900], // Adjust the background color here
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 5,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTabSelected,
        selectedItemColor: Color.fromARGB(255, 8, 36, 59), // Customize the selected item color
        unselectedItemColor: Colors.grey, // Customize the unselected item color
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.translate),
            label: 'Translate',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera),
            label: 'Capture',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mic),
            label: 'Speech',
          ),
        ],
      ),
    );
  }
}
// Translation direction enum
enum TranslationDirection { 
  EnglishToChichewa, 
  ChichewaToEnglish, 
  EnglishToTumbuka, 
  TumbukaToEnglish, 
  KoreanToChichewa, 
  KoreanToTumbuka,
  ChichewaToKorean,
  TumbukaToKorean 
}

// TranslateTab class
class TranslateTab extends StatefulWidget {
  const TranslateTab({Key? key}) : super(key: key);

  @override
  _TranslateTabState createState() => _TranslateTabState();
}

class _TranslateTabState extends State<TranslateTab> {
  String _translation = '';
  TranslationDirection _selectedDirection = TranslationDirection.EnglishToChichewa;
  TextEditingController _textEditingController = TextEditingController();
  
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> _getCurrentUserId() async {
    final User? user = _auth.currentUser;
    return user?.uid;
  }

  Future<void> _checkSpelling(String inputText) async {
 
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:5000/check_spelling'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'text': inputText,
        }),
      );

    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _translateText(String inputText) async {
  
    String direction;
    switch (_selectedDirection) {
      case TranslationDirection.EnglishToChichewa:
        direction = 'en-ny';
        break;
      case TranslationDirection.ChichewaToEnglish:
        direction = 'ny-en';
        break;
      case TranslationDirection.EnglishToTumbuka:
        direction = 'en-tum';
        break;
      case TranslationDirection.TumbukaToEnglish:
        direction = 'tum-en';
        break;
      case TranslationDirection.KoreanToChichewa:
        direction = 'ko-ny';
        break;
      case TranslationDirection.KoreanToTumbuka:
        direction = 'ko-tum';
        break;
      case TranslationDirection.ChichewaToKorean:
        direction = 'ny-ko';
        break;
      case TranslationDirection.TumbukaToKorean:
        direction = 'tum-ko';
        break;
    }

    try {
      final response = await http.post(
        Uri.parse('http://192.168.43.76:5000/translate'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'text': inputText,
          'direction': direction,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        setState(() {
          _translation = jsonDecode(response.body)['translated_text'];
        });

        // SEND THE TRANSLATED TEXT TO FIRESTORE
        final String? userId = await _getCurrentUserId();
        if (userId != null) {
          await FirebaseFirestore.instance.collection('translations').add({
            'userId': userId,
            'original_text': inputText,
            'translated_text': _translation,
            'direction': direction,
            'timestamp': DateTime.now(),
          });
        } else {
          print('User not authenticated.');
        }
      } else {
        throw Exception('Failed to load translation');
      }
    } catch (e) {
      print('Error: $e');
    } 
  }

  Future<void> _addToFavorites() async {
    if (_translation.isNotEmpty) {
      final String? userId = await _getCurrentUserId();
      if (userId != null) {
        try {
          await FirebaseFirestore.instance.collection('favorites').add({
            'userId': userId,
            'original_text': _textEditingController.text,
            'translated_text': _translation,
            'direction': _selectedDirection.toString().split('.').last,
            'timestamp': DateTime.now(),
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Added to favorites!')),
          );
        } catch (e) {
          print('Error adding to favorites: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add to favorites.')),
          );
        }
      } else {
        print('User not authenticated.');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No translation to add to favorites.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          DropdownButton<TranslationDirection>(
            value: _selectedDirection,
            onChanged: (newValue) {
              setState(() {
                _selectedDirection = newValue!;
              });
            },
            items: [
              const DropdownMenuItem(
                value: TranslationDirection.EnglishToChichewa,
                child: Text('English to Chichewa', style: TextStyle(color: Colors.brown)),
              ),
              const DropdownMenuItem(
                value: TranslationDirection.ChichewaToEnglish,
                child: Text('Chichewa to English', style: TextStyle(color: Colors.brown)),
              ),
              const DropdownMenuItem(
                value: TranslationDirection.EnglishToTumbuka,
                child: Text('English to Tumbuka', style: TextStyle(color: Colors.brown)),
              ),
              const DropdownMenuItem(
                value: TranslationDirection.TumbukaToEnglish,
                child: Text('Tumbuka to English', style: TextStyle(color: Colors.brown)),
              ),
              const DropdownMenuItem(
                value: TranslationDirection.KoreanToChichewa,
                child: Text('Korean to Chichewa', style: TextStyle(color: Colors.brown)),
              ),
              const DropdownMenuItem(
                value: TranslationDirection.KoreanToTumbuka,
                child: Text('Korean to Tumbuka', style: TextStyle(color: Colors.brown)),
              ),
              const DropdownMenuItem(
                value: TranslationDirection.ChichewaToKorean,
                child: Text('Chichewa to Korean', style: TextStyle(color: Colors.brown)),
              ),
              const DropdownMenuItem(
                value: TranslationDirection.TumbukaToKorean,
                child: Text('Tumbuka to Korean', style: TextStyle(color: Colors.brown)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _textEditingController,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Enter text to translate',
              hintStyle: TextStyle(color: Colors.white),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 20),
       
          
          ElevatedButton(
            onPressed: () {
              _translateText(_textEditingController.text);
            },
            child: const Text('Translate'),
          ),
         
          if (_translation.isNotEmpty) ...[
            const Text(
              'Translation:',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 10),
            Text(_translation, style: const TextStyle(color: Colors.white, fontSize: 20)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _addToFavorites,
              icon: Icon(Icons.favorite),
              label: Text('Add to Favorites'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Define the TranslationDirection enum


class CaptureTab extends StatefulWidget {
  const CaptureTab({Key? key}) : super(key: key);

  @override
  _CaptureTabState createState() => _CaptureTabState();
}

class _CaptureTabState extends State<CaptureTab> {
  late CameraController _cameraController;
  late Future<void> _initializeControllerFuture;
  final TextRecognizer _textRecognizer = GoogleMlKit.vision.textRecognizer();
  String _recognizedText = '';
  TranslationDirection _selectedDirection = TranslationDirection.EnglishToChichewa;

  @override
  void initState() {
    super.initState();
    _initializeControllerFuture = _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    _cameraController = CameraController(
      firstCamera,
      ResolutionPreset.high,
    );

    return _cameraController.initialize();
  }

  Future<void> _captureAndRecognizeText() async {
    try {
      await _initializeControllerFuture;
      final image = await _cameraController.takePicture();
      final inputImage = InputImage.fromFilePath(image.path);

      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

      // Extract recognized text
      final String capturedText = recognizedText.text;

      // Translate recognized text
      await _translateText(capturedText);
    } catch (e) {
      print(e);
    }
  }

  Future<void> _translateText(String inputText) async {
    String direction;
    switch (_selectedDirection) {
      case TranslationDirection.EnglishToChichewa:
        direction = 'en-ny';
        break;
      case TranslationDirection.ChichewaToEnglish:
        direction = 'ny-en';
        break;
      case TranslationDirection.EnglishToTumbuka:
        direction = 'en-tum';
        break;
      case TranslationDirection.TumbukaToEnglish:
        direction = 'tum-en';
        break;
      default:
        direction = 'en-ny';
    }

    // Make HTTP POST request to Flask backend for translation
    try {
      final response = await http.post(
        Uri.parse('http://192.168.43.76:5000/translate'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'text': inputText,
          'direction': direction,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          _recognizedText = jsonDecode(response.body)['translated_text'];
        });
      } else {
        throw Exception('Failed to load translation');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _textRecognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FutureBuilder<void>(
          future: _initializeControllerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return CameraPreview(_cameraController);
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
        Positioned(
          bottom: 450,
          left: 16,
          right: 16,
          child: DropdownButton<TranslationDirection>(
            value: _selectedDirection,
            onChanged: (TranslationDirection? newValue) {
              setState(() {
                _selectedDirection = newValue!;
              });
            },
            items: TranslationDirection.values.map((TranslationDirection direction) {
              return DropdownMenuItem<TranslationDirection>(
                value: direction,
                child: Text(direction.toString().split('.').last),
              );
            }).toList(),
          ),
        ),
        Positioned(
          bottom: 10,
          left: 16,
          right: 16,
          child: Text(
            "Your text is: " + _recognizedText,
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
        Positioned(
          bottom: 16,
          left: 0,
          right: 0,
          child: Center(
            child: FloatingActionButton(
              onPressed: _captureAndRecognizeText,
              child: const Icon(Icons.camera),
            ),
          ),
        ),
      ],
    );
  }
}