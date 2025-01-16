import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screen_brightness/screen_brightness.dart';
import '../model/recipe_model.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class CookingModeScreen extends ConsumerStatefulWidget {
  final Recipe recipe;
  final int servings;

  const CookingModeScreen({
    Key? key,
    required this.recipe,
    this.servings = 1,
  }) : super(key: key);

  @override
  ConsumerState<CookingModeScreen> createState() => _CookingModeScreenState();
}

class _CookingModeScreenState extends ConsumerState<CookingModeScreen> {
  int _currentStep = 0;
  late List<String> _instructions;
  bool _isListening = false;
  late stt.SpeechToText _speech;
  String _lastWords = '';

  @override
  void initState() {
    super.initState();
    ScreenBrightness().setScreenBrightness(1.0);
    _speech = stt.SpeechToText();
    _initSpeech();
    _instructions = widget.recipe.instructions
        .split('\n')
        .where((step) => step.trim().isNotEmpty)
        .toList();
    
    if (_instructions.isEmpty) {
      _instructions = ['No instructions available for this recipe.'];
    }
  }

  Future<void> _initSpeech() async {
    try {
      var hasSpeech = await _speech.initialize(
        onStatus: (status) {
          print('Speech status: $status');
          if (status == 'done') {
            setState(() => _isListening = false);
          }
        },
        onError: (error) => print('Speech error: $error'),
      );

      if (hasSpeech) {
        setState(() {
          _isListening = false;
        });
      }
    } catch (e) {
      print('Speech initialization error: $e');
    }
  }

  @override
  void dispose() {
    ScreenBrightness().resetScreenBrightness();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cooking Mode'),
        actions: [
          IconButton(
            icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
            onPressed: _speech.isAvailable ? _toggleVoiceCommands : null,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildRecipeHeader(),
            _buildVoiceCommandsHelp(),
            _buildIngredientsCard(),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.4,
              child: _buildInstructionsStep(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeHeader() {
    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(widget.recipe.imageUrl),
        ),
        title: Text(widget.recipe.title),
        subtitle: Text('Step ${_currentStep + 1} of ${_instructions.length}'),
      ),
    );
  }

  Widget _buildIngredientsCard() {
    final scaleFactor = widget.servings / widget.recipe.servings;
    
    return Card(
      margin: const EdgeInsets.all(8),
      child: ExpansionTile(
        title: const Text('Ingredients'),
        children: widget.recipe.ingredients.map((ingredient) {
          final quantity = _extractQuantity(ingredient);
          final scaled = quantity * scaleFactor;
          final text = ingredient.replaceAll(
            quantity.toString(),
            scaled.toStringAsFixed(1),
          );
          
          return ListTile(
            title: Text(text),
            leading: const Icon(Icons.check_circle_outline),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInstructionsStep() {
    if (_instructions.isEmpty) {
      return const Center(
        child: Text('No instructions available'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Step ${_currentStep + 1} of ${_instructions.length}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        Text(
          _instructions[_currentStep],
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: _currentStep > 0 ? _previousStep : null,
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward),
              onPressed: _currentStep < _instructions.length - 1 ? _nextStep : null,
            ),
          ],
        ),
      ],
    );
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _nextStep() {
    if (_currentStep < _instructions.length - 1) {
      setState(() => _currentStep++);
    }
  }

  void _toggleVoiceCommands() {
    setState(() => _isListening = !_isListening);
    if (_isListening) {
      _startListening();
    } else {
      _stopListening();
    }
  }

  void _startListening() async {
    if (!_speech.isAvailable) return;

    try {
      await _speech.listen(
        onResult: (result) {
          setState(() {
            _lastWords = result.recognizedWords.toLowerCase();
            if (result.finalResult) {
              _handleVoiceCommand(_lastWords);
            }
          });
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        cancelOnError: true,
        listenMode: stt.ListenMode.confirmation,
      );
      setState(() => _isListening = true);
    } catch (e) {
      print('Error starting speech recognition: $e');
      setState(() => _isListening = false);
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  void _handleVoiceCommand(String command) {
    if (command.contains('next') || command.contains('forward')) {
      _nextStep();
    } else if (command.contains('back') || command.contains('previous')) {
      _previousStep();
    } else if (command.contains('ingredients')) {
      // TODO: Show ingredients
    } else if (command.contains('repeat')) {
      // TODO: Text-to-speech current step
    }
  }

  double _extractQuantity(String ingredient) {
    final regex = RegExp(r'(\d+(?:\.\d+)?)');
    final match = regex.firstMatch(ingredient);
    return match != null ? double.parse(match.group(1)!) : 1.0;
  }

  Widget _buildVoiceCommandsHelp() {
    return Card(
      margin: const EdgeInsets.all(8),
      child: ExpansionTile(
        title: const Text('Voice Commands'),
        leading: const Icon(Icons.mic),
        children: const [
          ListTile(
            title: Text('Next / Forward'),
            subtitle: Text('Move to next step'),
          ),
          ListTile(
            title: Text('Back / Previous'),
            subtitle: Text('Go to previous step'),
          ),
          ListTile(
            title: Text('Ingredients'),
            subtitle: Text('Show ingredients list'),
          ),
          ListTile(
            title: Text('Repeat'),
            subtitle: Text('Repeat current step'),
          ),
        ],
      ),
    );
  }
} 