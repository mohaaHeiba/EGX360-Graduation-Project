import 'dart:async';

import 'package:egx/core/helper/context_extensions.dart';
import 'package:flutter/material.dart';

class CountdownTimer extends StatefulWidget {
  final DateTime targetTime;

  const CountdownTimer({super.key, required this.targetTime});

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late Timer _timer;
  Duration _timeLeft = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTime();
    });
  }

  void _updateTime() {
    final now = DateTime.now();
    if (widget.targetTime.isAfter(now)) {
      setState(() {
        _timeLeft = widget.targetTime.difference(now);
      });
    } else {
      setState(() {
        _timeLeft = Duration.zero;
      });
    }
  }

  @override
  void didUpdateWidget(covariant CountdownTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.targetTime != widget.targetTime) {
      _updateTime();
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = _timeLeft.inMinutes
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    final seconds = _timeLeft.inSeconds
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    final hours = _timeLeft.inHours > 0 ? '${_timeLeft.inHours}:' : '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: context.onSurface.withValues(alpha: 0.1)),
      ),
      child: Text(
        '$hours$minutes:$seconds',
        style: TextStyle(
          color: context.onSurface,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}
