import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

import '../constant/app_constants.dart';

class SolarConnectionAnimation extends StatefulWidget {
  final bool isOnline;
  final double productionValue;
  final String unit;

  const SolarConnectionAnimation({super.key, required this.isOnline, required this.productionValue, this.unit = 'kWh'});

  @override
  State<SolarConnectionAnimation> createState() => _SolarConnectionAnimationState();
}

class _SolarConnectionAnimationState extends State<SolarConnectionAnimation> {
  late final FileLoader _fileLoader;
  RiveWidgetController? _controller;
  SingleAnimationPainter? _animationPainter;
  bool _isAnimationLoaded = false;

  @override
  void initState() {
    super.initState();
    _fileLoader = FileLoader.fromAsset('assets/animations/solar connection', riveFactory: Factory.rive);
  }

  @override
  void didUpdateWidget(SolarConnectionAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isOnline != widget.isOnline) {
      _updateAnimation();
    }
  }

  void _updateAnimation() {
    if (_isAnimationLoaded && _animationPainter != null) {
      // Try to restart the animation by recreating the painter
      _animationPainter?.dispose();
      _setupAnimation();
    }
  }

  void _setupAnimation() {
    if (_controller == null) return;

    // In Rive 0.14, animations are handled differently
    // The default animation should auto-play if set in the Rive file
    // For custom animation control, you may need to use StateMachine or
    // configure the animation in the Rive file itself
    _animationPainter?.dispose();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Rive Animation - Full width with proper clipping
        ClipRRect(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
          child: SizedBox(
            width: double.infinity,
            height: AppConstants.imageLargeSize * 3, // 600px
            child: RiveWidgetBuilder(
              fileLoader: _fileLoader,
              builder: (context, state) {
                return switch (state) {
                  RiveLoading() => Container(
                    width: double.infinity,
                    height: AppConstants.imageLargeSize * 3, // 600px
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: widget.isOnline ? [Colors.green.shade300, Colors.green.shade100] : [Colors.red.shade300, Colors.red.shade100]),
                      borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
                    ),
                    child: Center(child: CircularProgressIndicator(color: widget.isOnline ? Colors.green : Colors.red, strokeWidth: AppConstants.chartLineThickness)),
                  ),
                  RiveFailed() => Container(
                    width: double.infinity,
                    height: AppConstants.imageLargeSize * 3,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: widget.isOnline ? [Colors.green.shade300, Colors.green.shade200] : [Colors.red.shade300, Colors.red.shade100]),
                      borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
                    ),
                    child: Center(child: Text('Failed to load: ${state.error}')),
                  ),
                  RiveLoaded() => Builder(
                    builder: (context) {
                      if (_controller != state.controller) {
                        _controller = state.controller;
                        _isAnimationLoaded = true;
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _setupAnimation();
                        });
                      }

                      return RiveWidget(controller: state.controller, fit: Fit.contain);
                    },
                  ),
                };
              },
            ),
          ),
        ),
        // Production Value - Enhanced card with glassmorphism effect
        Positioned(
          right: AppConstants.paddingLarge, // 20px
          top: (AppConstants.imageLargeSize), // 600/2 - 20 = 280px (orta noktanın 20px üstü)
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 800),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.8 + (0.2 * value),
                child: Opacity(
                  opacity: value,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge), // 12px
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.paddingLarge + 4, // 16px
                          vertical: AppConstants.paddingMedium + 4, // 12px
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.grey.shade200, Colors.grey.shade100]),
                          borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge), // 12px
                          border: Border.all(color: Colors.grey.shade300, width: 1.5),
                          boxShadow: [
                            BoxShadow(color: Colors.grey.shade700, blurRadius: 25, offset: const Offset(0, 10)),
                            BoxShadow(color: Colors.grey.shade100, blurRadius: 15, offset: const Offset(0, -3)),
                            // Glow effect
                            BoxShadow(color: widget.isOnline ? Colors.green.shade200 : Colors.red.shade200, blurRadius: 20, offset: const Offset(0, 0)),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Production icon with pulse animation
                            TweenAnimationBuilder<double>(
                              duration: const Duration(seconds: 2),
                              tween: Tween(begin: 0.8, end: 1.2),
                              builder: (context, scale, child) {
                                return Transform.scale(
                                  scale: scale,
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(color: widget.isOnline ? Colors.green.shade200 : Colors.red.shade200, shape: BoxShape.circle),
                                    child: Icon(Icons.flash_on, color: widget.isOnline ? Colors.green[300] : Colors.red[300], size: 16),
                                  ),
                                );
                              },
                              onEnd: () {
                                // Restart the animation
                                setState(() {});
                              },
                            ),
                            const SizedBox(height: 4),
                            // Production value with enhanced typography
                            Text(
                              widget.productionValue.toStringAsFixed(AppConstants.decimalPlaces),
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: AppConstants.fontSizeLarge + 2, // 18px
                                letterSpacing: 0.5,
                                shadows: [Shadow(color: Colors.grey.shade800, offset: const Offset(0, 1), blurRadius: 2)],
                              ),
                            ),
                            Text(
                              widget.unit,
                              style: TextStyle(
                                color: Colors.grey.shade100,
                                fontWeight: FontWeight.w600,
                                fontSize: AppConstants.fontSizeSmall, // 12px
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _animationPainter?.dispose();
    _fileLoader.dispose();
    super.dispose();
  }
}
