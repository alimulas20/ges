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
    return Container(
      width: double.infinity - 10,
      height: 600,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge), color: Colors.grey[100]),
      child: Stack(
        children: [
          // Rive Animation - Full width with proper clipping
          ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
            child: SizedBox(
              width: double.infinity,
              height: 600,
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
                  height: 300,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: widget.isOnline ? [Colors.green.withOpacity(0.3), Colors.green.withOpacity(0.1)] : [Colors.red.withOpacity(0.3), Colors.red.withOpacity(0.1)]),
                    borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
                  ),
                  child: Center(child: CircularProgressIndicator(color: widget.isOnline ? Colors.green : Colors.red)),
                ),
              ),
            ),
          ),
          // Production Value - Only in center-right
          Positioned(
            right: 20,
            top: 0,
            bottom: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.7), borderRadius: BorderRadius.circular(8)),
                child: Text('${widget.productionValue.toStringAsFixed(1)} ${widget.unit}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
