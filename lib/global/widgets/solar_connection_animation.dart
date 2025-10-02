import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:rive/rive.dart' hide LinearGradient;

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
  RiveAnimationController? _controller;
  bool _isAnimationLoaded = false;

  @override
  void initState() {
    super.initState();
    // Try Timeline 1 first, will be updated in onInit if needed
    _controller = SimpleAnimation('Timeline 1');
  }

  @override
  void didUpdateWidget(SolarConnectionAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isOnline != widget.isOnline) {
      _updateAnimation();
    }
  }

  void _updateAnimation() {
    if (_isAnimationLoaded && _controller != null) {
      // Try to restart the animation
      _controller!.isActive = false;
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _controller!.isActive = true;
        }
      });
    }
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
            child: RiveAnimation.asset(
              'assets/animations/solar connection',
              controllers: _controller != null ? [_controller!] : [],
              onInit: (artboard) {
                _isAnimationLoaded = true;
                try {
                  _controller = SimpleAnimation('Timeline 1');
                  _controller!.isActive = true;
                } catch (e) {
                  // Try Timeline 2
                  _controller = SimpleAnimation('Timeline 2');
                  _controller!.isActive = true;
                }
              },
              fit: BoxFit.contain,
              placeHolder: Container(
                width: double.infinity,
                height: AppConstants.imageLargeSize * 3, // 600px
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors:
                        widget.isOnline
                            ? [Colors.green.withAlpha((AppConstants.alphaMedium * 255).round()), Colors.green.withAlpha((AppConstants.alphaLow * 255).round())]
                            : [Colors.red.withAlpha((AppConstants.alphaMedium * 255).round()), Colors.red.withAlpha((AppConstants.alphaLow * 255).round())],
                  ),
                  borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
                ),
                child: Center(child: CircularProgressIndicator(color: widget.isOnline ? Colors.green : Colors.red, strokeWidth: AppConstants.chartLineThickness)),
              ),
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
                          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.white.withOpacity(0.3), Colors.white.withOpacity(0.1)]),
                          borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge), // 12px
                          border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 25, offset: const Offset(0, 10)),
                            BoxShadow(color: Colors.white.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, -3)),
                            // Glow effect
                            BoxShadow(color: widget.isOnline ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 0)),
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
                                    decoration: BoxDecoration(color: widget.isOnline ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2), shape: BoxShape.circle),
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
                                shadows: [Shadow(color: Colors.black.withOpacity(0.3), offset: const Offset(0, 1), blurRadius: 2)],
                              ),
                            ),
                            Text(
                              widget.unit,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
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
    _controller?.dispose();
    super.dispose();
  }
}
