import 'dart:math';
import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: SoundWaveformWidget(),
        ),
      ),
    );
  }
}

class SoundWaveformWidget extends StatefulWidget {
  final int count;
  final double minHeight;
  final double maxHeight;
  final int durationInMilliseconds;
  const SoundWaveformWidget({
    Key? key,
    this.count = 6,
    this.minHeight = 10,
    this.maxHeight = 50,
    this.durationInMilliseconds = 500,
  }) : super(key: key);
  @override
  State<SoundWaveformWidget> createState() => _SoundWaveformWidgetState();
}

class _SoundWaveformWidgetState extends State<SoundWaveformWidget>
    with TickerProviderStateMixin {
  late AnimationController controller;
  late List<double> heights;
  final Random random = Random();

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.durationInMilliseconds),
    )..repeat();
    heights = List<double>.filled(widget.count, widget.minHeight);
    _randomizeHeights();
  }

  void _randomizeHeights() {
    Future.delayed(
      Duration(milliseconds: widget.durationInMilliseconds ~/ widget.count),
      () {
        setState(() {
          for (int i = 0; i < heights.length; i++) {
            heights[i] = widget.minHeight +
                random.nextDouble() * (widget.maxHeight - widget.minHeight);
          }
        });
        _randomizeHeights(); // Recursive call to keep updating heights
      },
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            widget.count,
            (i) => AnimatedContainer(
              duration: Duration(
                milliseconds: widget.durationInMilliseconds ~/ widget.count,
              ),
              margin: i == (widget.count - 1)
                  ? EdgeInsets.zero
                  : const EdgeInsets.only(right: 5),
              height: heights[i],
              width: 5,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
          ),
        );
      },
    );
  }
}
