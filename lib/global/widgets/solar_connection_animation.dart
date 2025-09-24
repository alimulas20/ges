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
        // Production Value - Center-right, 20 units above center
        Positioned(
          right: AppConstants.paddingLarge, // 20px
          top: (AppConstants.imageLargeSize * 3) / 2 - AppConstants.paddingSuperLarge * 2, // Center - 20px
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppConstants.paddingLarge, // 12px
              vertical: AppConstants.paddingMedium, // 8px
            ),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha((AppConstants.alphaHigh * 255).round()),
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium), // 8px
            ),
            child: Text(
              '${widget.productionValue.toStringAsFixed(AppConstants.decimalPlaces)} ${widget.unit}',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: AppConstants.fontSizeLarge, // 16px
              ),
            ),
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
