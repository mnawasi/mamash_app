import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Shows the splash artwork over the app for a few seconds, then fades it out.
/// Tap anywhere to skip.
class SplashGate extends StatefulWidget {
  final Widget child;
  const SplashGate({super.key, required this.child});

  @override
  State<SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<SplashGate> {
  static const String _asset = 'assets/images/splash_screen.jpg';
  static const Duration _showFor = Duration(milliseconds: 3200);
  // Share of the picture cut off at the top, to remove the painted status bar
  // (time, signal, wifi, battery). Raise it to cut more, lower it to cut less.
  static const double _cropTop = 0.05;

  Timer? _timer;
  bool _fading = false;
  bool _gone = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _timer = Timer(_showFor, _hide);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage(_asset), context, onError: (e, s) {
      debugPrint('SPLASH IMAGE ERROR: $e');
    });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _timer?.cancel();
    super.dispose();
  }

  void _hide() {
    if (!mounted || _fading) return;
    setState(() => _fading = true);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        if (!_gone)
          Positioned.fill(
            child: IgnorePointer(
              ignoring: _fading,
              child: AnimatedOpacity(
                opacity: _fading ? 0 : 1,
                duration: const Duration(milliseconds: 450),
                onEnd: () {
                  if (_fading && mounted) {
                    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
                    setState(() => _gone = true);
                  }
                },
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _hide,
                  child: ColoredBox(
                    color: const Color(0xFF030B24),
                    child: LayoutBuilder(
                      builder: (context, c) {
                        // Tall phone screens: fill the screen. Wide windows: show the whole picture.
                        final wide = c.maxWidth / c.maxHeight > 0.6;
                        return SizedBox.expand(
                          child: FittedBox(
                            fit: wide ? BoxFit.contain : BoxFit.cover,
                            clipBehavior: Clip.hardEdge,
                            child: ClipRect(
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                heightFactor: 1 - _cropTop,
                                child: Image.asset(
                                  _asset,
                                  errorBuilder: (context, error, stack) {
                                    debugPrint('SPLASH IMAGE ERROR: $error');
                                    return const SizedBox(width: 640, height: 1280);
                                  },
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
