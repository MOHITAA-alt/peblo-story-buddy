import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:math';

void main() {
  runApp(const PebloApp());
}

class PebloApp extends StatelessWidget {
  const PebloApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Peblo Story Buddy',
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final FlutterTts flutterTts = FlutterTts();

  bool isLoading = false;
  bool showQuiz = false;
  bool isSuccess = false;
  String? selectedAnswer;

  late AnimationController _shakeController;

  final String story =
      "Once upon a time, a clever little robot named Pip lost his shiny blue gear in the Whispering Woods...";

  final Map<String, dynamic> quizData = {
    "question": "What colour was Pip the Robot's lost gear?",
    "options": ["Red", "Green", "Blue", "Yellow"],
    "answer": "Blue",
  };

  @override
  void initState() {
    super.initState();

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    flutterTts.setCompletionHandler(() {
      if (mounted) {
        setState(() {
          isLoading = false;
          showQuiz = true;
        });
      }
    });

    flutterTts.setErrorHandler((msg) {
      if (mounted) {
        setState(() => isLoading = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("TTS Error: $msg")),
        );
      }
    });
  }

  Future<void> readStory() async {
    setState(() {
      isLoading = true;
      showQuiz = false;
      isSuccess = false;
      selectedAnswer = null;
    });

    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.45);
    await flutterTts.setPitch(1.0);

    await flutterTts.speak(story);
  }

  void triggerShake() {
    _shakeController
      ..reset()
      ..forward();
  }

  void checkAnswer() {
    if (selectedAnswer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select an answer.")),
      );
      return;
    }

    if (selectedAnswer == quizData["answer"]) {
      setState(() => isSuccess = true);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("🎉 Correct Answer!")),
      );
    } else {
      triggerShake();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Wrong Answer! Try Again")),
      );
    }
  }

  Widget buildCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }

  @override
  void dispose() {
    flutterTts.stop();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List options = quizData["options"];

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF89F7FE), Color(0xFF66A6FF)],
              ),
            ),
          ),

          Positioned(
            top: -50,
            left: -30,
            child: buildCircle(130, Colors.white24),
          ),

          Positioned(
            bottom: -70,
            right: -40,
            child: buildCircle(160, Colors.white12),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: AnimatedBuilder(
                  animation: _shakeController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(
                        sin(_shakeController.value * pi * 4) * 10,
                        0,
                      ),
                      child: child,
                    );
                  },
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "📚 Peblo",
                            style: TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),

                          const SizedBox(height: 10),
                          const Text("🤖", style: TextStyle(fontSize: 80)),

                          const Text(
                            "Pip the Robot",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),

                          const SizedBox(height: 20),

                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              story,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),

                          const SizedBox(height: 20),

                          ElevatedButton(
                            onPressed: isLoading ? null : readStory,
                            child: Text(
                              isLoading ? "Reading..." : "Read Me a Story 📖",
                            ),
                          ),

                          const SizedBox(height: 20),

                          if (showQuiz) ...[
                            const Text(
                              "🧠 Quiz Time!",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),

                            const SizedBox(height: 10),

                            Text(
                              quizData["question"],
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white),
                            ),

                            const SizedBox(height: 10),

                            ...options.map((option) {
                              return ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      selectedAnswer == option
                                          ? Colors.greenAccent
                                          : Colors.white,
                                ),
                                onPressed: () {
                                  setState(() => selectedAnswer = option);
                                },
                                child: Text(option),
                              );
                            }),

                            const SizedBox(height: 10),

                            ElevatedButton(
                              onPressed: checkAnswer,
                              child: const Text("Submit"),
                            ),
                          ],

                          if (isSuccess) ...[
                            const SizedBox(height: 20),
                            const Text(
                              "🎉 SUCCESS!",
                              style: TextStyle(
                                fontSize: 28,
                                color: Colors.yellow,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              "Pip found his blue gear!",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}