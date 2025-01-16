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
  bool _showIngredients = false;

  @override
  void initState() {
    super.initState();
    ScreenBrightness().setScreenBrightness(1.0);
    _speech = stt.SpeechToText();
    _initSpeech();
    
    // Safely handle instructions
    _instructions = widget.recipe.instructions
        .split(RegExp(r'(?:\r?\n|\r|\.|STEP\s*\d+)'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
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
        leading: Hero(
          tag: 'recipe-image-${widget.recipe.id}-${widget.recipe.imageUrl}',
          child: CircleAvatar(
            backgroundImage: NetworkImage(widget.recipe.imageUrl),
          ),
        ),
        title: Text(widget.recipe.title),
        subtitle: Text('Step ${_currentStep + 1} of ${_instructions.length}'),
      ),
    );
  }

  Widget _buildIngredientsCard() {
    final scaleFactor = widget.servings / widget.recipe.servings;
    
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Card(
        margin: const EdgeInsets.all(8),
        child: ExpansionTile(
          initiallyExpanded: _showIngredients,
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
      ),
    );
  }

  Widget _buildInstructionsStep() {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                _instructions[_currentStep],
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton.icon(
            onPressed: _currentStep > 0 ? _previousStep : null,
            icon: const Icon(Icons.arrow_back),
            label: const Text('Previous'),
          ),
          ElevatedButton.icon(
            onPressed: _currentStep < _instructions.length - 1 ? _nextStep : null,
            icon: const Icon(Icons.arrow_forward),
            label: const Text('Next'),
          ),
        ],
      ),
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
    command = command.toLowerCase();
    setState(() {
      if (command.contains('next') || command.contains('forward')) {
        _nextStep();
      } else if (command.contains('back') || command.contains('previous')) {
        _previousStep();
      } else if (command.contains('ingredient')) {
        _showIngredients = !_showIngredients;
      } else if (command.contains('repeat')) {
        // Keep current step, maybe add TTS later
      } else if (command.contains('start over')) {
        _currentStep = 0;
      } else if (command.contains('last step')) {
        _currentStep = _instructions.length - 1;
      }
    });
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
            subtitle: Text('Toggle ingredients list'),
          ),
          ListTile(
            title: Text('Start Over'),
            subtitle: Text('Return to first step'),
          ),
          ListTile(
            title: Text('Last Step'),
            subtitle: Text('Go to final step'),
          ),
        ],
      ),
    );
  }
} 