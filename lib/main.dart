import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  List<CameraDescription> cameras = await availableCameras();
  runApp(MyApp(cameras: cameras));
}

class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras;

  const MyApp({Key? key, required this.cameras}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: Colors.grey[200],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[200],
          centerTitle: true,
        ),
      ),
      darkTheme: ThemeData.dark(),
      home: FlashlightScreen(cameras: cameras),
    );
  }
}

class FlashlightScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const FlashlightScreen({Key? key, required this.cameras}) : super(key: key);

  @override
  _FlashlightScreenState createState() => _FlashlightScreenState();
}

class _FlashlightScreenState extends State<FlashlightScreen> {
  late CameraController _controller;
  late bool _isFlashlightOn;
  double _brightnessLevel = 0.5;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(widget.cameras[0], ResolutionPreset.low);
    _isFlashlightOn = false;

    _controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleFlashlight() {
    setState(() {
      _isFlashlightOn = !_isFlashlightOn;
      _controller.setFlashMode(
        _isFlashlightOn ? FlashMode.torch : FlashMode.off,
      );

      if (_isFlashlightOn) {
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
      } else {
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
      }
    });
  }

  void _updateBrightnessLevel(double value) {
    setState(() {
      _brightnessLevel = value;
      _controller.setExposureMode(
        ExposureMode.auto, // Reset to auto mode before adjusting brightness
      );

      // Adjust the brightness level
      _controller.setExposureOffset(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return Container();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Flashlight App',
          style: TextStyle(
            color: Colors.black, // Title text color
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.flashlight_on,
              size: 100.0,
              color: _isFlashlightOn ? Colors.amber : Colors.grey,
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _toggleFlashlight,
              child: Text(_isFlashlightOn ? 'Turn Off' : 'Turn On'),
            ),
            SizedBox(height: 20.0),
            Text(
              'Brightness Level: ${(_brightnessLevel * 100).toStringAsFixed(0)}%',
              style: TextStyle(fontSize: 16.0),
            ),
            Slider(
              value: _brightnessLevel,
              onChanged: _updateBrightnessLevel,
              min: 0.0,
              max: 1.0,
              divisions: 100,
              label: '${(_brightnessLevel * 100).toStringAsFixed(0)}%',
            ),
          ],
        ),
      ),
      backgroundColor: _isFlashlightOn ? Colors.grey[50] : Colors.black,
    );
  }
}
