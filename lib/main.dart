// Import necessary packages
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';

// Entry point of the application
void main() async {
  // Ensure that Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Obtain the available cameras
  List<CameraDescription> cameras = await availableCameras();

  // Run the app
  runApp(MyApp(cameras: cameras));
}

// Main app class
class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras;

  const MyApp({Key? key, required this.cameras}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // MaterialApp widget defines the structure of the app
    return MaterialApp(
      // Set the initial light theme
      theme: ThemeData.light(),
      // Set the dark theme
      darkTheme: ThemeData.dark(),
      // Home screen of the app
      home: FlashlightScreen(cameras: cameras),
    );
  }
}

// Flashlight screen class
class FlashlightScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const FlashlightScreen({Key? key, required this.cameras}) : super(key: key);

  @override
  _FlashlightScreenState createState() => _FlashlightScreenState();
}

// State class for the Flashlight screen
class _FlashlightScreenState extends State<FlashlightScreen> {
  late CameraController _controller;
  late bool _isFlashlightOn;

  @override
  void initState() {
    super.initState();
    // Initialize the camera controller
    _controller = CameraController(widget.cameras[0], ResolutionPreset.low);
    // Initialize flashlight state
    _isFlashlightOn = false;

    // Initialize the camera controller
    _controller.initialize().then((_) {
      // Check if the widget is still mounted before setting state
      if (!mounted) {
        return;
      }
      // Set the state to trigger a rebuild
      setState(() {});
    });
  }

  @override
  void dispose() {
    // Dispose of the camera controller when the widget is disposed
    _controller.dispose();
    super.dispose();
  }

  // Method to toggle the flashlight state
  void _toggleFlashlight() {
    // Set the state based on the current flashlight state
    setState(() {
      _isFlashlightOn = !_isFlashlightOn;
      // Set the flashlight mode
      _controller.setFlashMode(
        _isFlashlightOn ? FlashMode.torch : FlashMode.off,
      );

      // Set the system UI overlay style
      if (_isFlashlightOn) {
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
      } else {
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Check if the camera is not initialized
    if (!_controller.value.isInitialized) {
      return Container();
    }

    // Build the flashlight screen
    return Scaffold(
      appBar: AppBar(
        title: Text('Flashlight App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Flashlight icon
            Icon(
              Icons.flashlight_on,
              size: 100.0,
              color: _isFlashlightOn ? Colors.yellow : Colors.grey,
            ),
            SizedBox(height: 20.0),
            // Button to toggle the flashlight
            ElevatedButton(
              onPressed: _toggleFlashlight,
              child: Text(_isFlashlightOn ? 'Turn Off' : 'Turn On'),
            ),
          ],
        ),
      ),
    );
  }
}
