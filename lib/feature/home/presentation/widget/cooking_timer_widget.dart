import 'package:flutter/material.dart';
import 'dart:async';

class CookingTimer extends StatefulWidget {
  final int totalMinutes;

  const CookingTimer({super.key, required this.totalMinutes});

  @override
  _CookingTimerState createState() => _CookingTimerState();
}

class _CookingTimerState extends State<CookingTimer> {
  Timer? _timer;
  late int _secondsRemaining;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _secondsRemaining = widget.totalMinutes * 60;
  }

  void _startTimer() {
    setState(() => _isRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        _stopTimer();
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  void _resetTimer() {
    _stopTimer();
    setState(() => _secondsRemaining = widget.totalMinutes * 60);
  }

  String get _formattedTime {
    int minutes = _secondsRemaining ~/ 60;
    int seconds = _secondsRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Cooking Timer',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _formattedTime,
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                  onPressed: _isRunning ? _stopTimer : _startTimer,
                ),
                IconButton(
                  icon: const Icon(Icons.replay),
                  onPressed: _resetTimer,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}