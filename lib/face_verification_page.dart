import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dashboard_page.dart';

// TODO: This screen currently only captures a photo from the device
// camera — it does NOT perform real face matching or liveness detection.
// For a financial app, "Face Verification" should be backed by an actual
// biometric/KYC provider before this gates access to the dashboard.
// Common options for Nigerian fintech apps: Smile Identity, Youverify,
// or Dojah. Each typically works like this:
//   1. Capture a photo (this screen already does that).
//   2. Send the photo to the provider's API (usually alongside a BVN/NIN
//      photo already on file) from your BACKEND, not directly from the
//      app, since API keys must never live in client code.
//   3. Your backend returns a match/liveness result.
//   4. Only navigate to DashboardPage if that result is a pass.
// Until that's wired up, treat this screen as a capture step, not a
// security gate.

class FaceVerificationPage extends StatefulWidget {
  const FaceVerificationPage({super.key});

  @override
  State<FaceVerificationPage> createState() => _FaceVerificationPageState();
}

enum _VerificationStatus { idle, capturing, verifying, failed }

class _FaceVerificationPageState extends State<FaceVerificationPage> {
  CameraController? _cameraController;
  Future<void>? _initializeControllerFuture;

  _VerificationStatus _status = _VerificationStatus.idle;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _setupCamera();
  }

  Future<void> _setupCamera() async {
    try {
      final cameras = await availableCameras();

      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      _initializeControllerFuture = _cameraController!.initialize();

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _status = _VerificationStatus.failed;
        _errorMessage =
            "Couldn't access the camera. Check camera permissions in your device settings and try again.";
      });
    }
  }

  Future<void> _verifyFace() async {
    if (_cameraController == null || _initializeControllerFuture == null) {
      return;
    }

    setState(() {
      _status = _VerificationStatus.capturing;
      _errorMessage = null;
    });

    try {
      await _initializeControllerFuture;
      final image = await _cameraController!.takePicture();

      setState(() {
        _status = _VerificationStatus.verifying;
      });

      // TODO: Replace this with a real call to your backend, sending
      // `image.path` for biometric verification against the provider
      // you choose (see note at top of file). The delay below is a
      // placeholder only.
      await Future.delayed(const Duration(seconds: 2));

      final bool verified = true; // TODO: real result from backend

      if (!mounted) return;

      if (!verified) {
        setState(() {
          _status = _VerificationStatus.failed;
          _errorMessage =
              "We couldn't verify your face. Make sure you're in good lighting and looking directly at the camera, then try again.";
        });
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardPage()),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _status = _VerificationStatus.failed;
        _errorMessage = "Something went wrong while capturing your photo. Please try again.";
      });
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  bool get _isBusy =>
      _status == _VerificationStatus.capturing ||
      _status == _VerificationStatus.verifying;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Face Verification"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              ClipOval(
                child: SizedBox(
                  width: 140,
                  height: 140,
                  child: _cameraController != null &&
                          _cameraController!.value.isInitialized
                      ? CameraPreview(_cameraController!)
                      : Container(
                          color: Colors.blue,
                          child: const Icon(
                            Icons.face,
                            size: 80,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                "Verify Your Face",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              const Text(
                "For your security, Mamash requires facial verification before accessing your account.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),

              if (_errorMessage != null) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red.shade700, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isBusy ? null : _verifyFace,
                  child: _isBusy
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          _status == _VerificationStatus.failed
                              ? "TRY AGAIN"
                              : "VERIFY FACE",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 16),

              TextButton(
                onPressed: _isBusy
                    ? null
                    : () {
                        // TODO: Route this to a real support/contact page,
                        // or an alternate verification method (e.g. manual
                        // document review) if you offer one.
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Support contact coming soon...")),
                        );
                      },
                child: const Text("Having trouble? Contact support"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}