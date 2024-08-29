import 'package:flutter/material.dart';
import '../models/word.dart';
import '../helpers/db_helper.dart';

class TestGamePage extends StatefulWidget {
  const TestGamePage({super.key});

  @override
  State<TestGamePage> createState() => _TestGamePageState();
}

class _TestGamePageState extends State<TestGamePage> {
  late List<Word> _words;
  late DbHelper _dbHelper;
  Word? _currentWord;
  late String _correctAnswer;
  late String _wrongAnswer;
  bool _isLoading = true;
  bool _isAnswerSelected = false;
  bool _isCorrectAnswerSelected = false;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  Future<void> _initializeGame() async {
    _dbHelper = await DbHelper.create();
    _words = await _fetchWords();

    if (_words.length < 2) {
      _showWarningDialog();
    } else {
      _setNextQuestion();
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<List<Word>> _fetchWords() async {
    final List<Map<String, dynamic>> wordMaps = await _dbHelper.getWords();
    final List<Word> words = wordMaps.map((map) => Word.fromMap(map)).toList();
    return words.where((word) => !word.isLearned).toList();
  }

  void _setNextQuestion() {
    _words.shuffle();
    _currentWord = _words.first;

    final List<Word> otherWords = List.from(_words)..remove(_currentWord);
    otherWords.shuffle();

    _correctAnswer = _currentWord!.mean;

    if (otherWords.isNotEmpty) {
      _wrongAnswer = otherWords.first.mean;
    } else {
      _wrongAnswer =
          "N/A"; // Default değer, burada daha uygun bir şey kullanılabilir
    }

    _isAnswerSelected = false;
    _isCorrectAnswerSelected = false;
  }

  void _checkAnswer(String selectedAnswer) async {
    setState(() {
      _isAnswerSelected = true;
      _isCorrectAnswerSelected = (selectedAnswer == _correctAnswer);
    });

    if (_isCorrectAnswerSelected) {
      _updateCorrectCount();
    }

    await Future.delayed(const Duration(seconds: 1));

    if (_words.isNotEmpty) {
      _setNextQuestion();
    } else {
      _showGameOverDialog();
    }

    setState(() {});
  }

  Future<void> _updateCorrectCount() async {
    _currentWord!.correctCount += 1;

    if (_currentWord!.correctCount >= 5) {
      _currentWord!.isLearned = true;
    }

    await _dbHelper.updateWord(_currentWord!.id!, _currentWord!.toMap());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Doğru! ${_currentWord!.title} güncellendi.')),
    );

    _words.remove(_currentWord);

    if (_words.length < 2) {
      _showGameOverDialog();
    }
  }

  void _showWarningDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Yetersiz Kelime'),
          content: const Text(
              'Test oyununu oynamak için en az iki kelimeniz olmalıdır.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Geri dön
              },
              child: const Text('Tamam'),
            ),
          ],
        );
      },
    );
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Oyun Bitti'),
          content:
              const Text('Oyun tamamlandı! Öğrenilecek başka kelime kalmadı.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Geri dön
              },
              child: const Text('Tamam'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Oyunu'),
        backgroundColor: const Color(0xFF1D93F3),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _currentWord == null
              ? const Center(child: Text('Yetersiz Kelime!'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Center(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(24.0),
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 2.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 10,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _currentWord!.title,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1D93F3),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    LinearProgressIndicator(
                                      value: _currentWord!.correctCount / 5,
                                      backgroundColor: Colors.grey[300],
                                      color: const Color(0xFF1D93F3),
                                      minHeight: 8,
                                    ),
                                    const SizedBox(height: 8),
                                    if (_currentWord!.example1 != null ||
                                        _currentWord!.example2 != null)
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (_currentWord!.example1 != null)
                                            Text(
                                              '• ${_currentWord!.example1}',
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontStyle: FontStyle.italic,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          if (_currentWord!.example2 != null)
                                            Text(
                                              '• ${_currentWord!.example2}',
                                              style: const TextStyle(
                                                fontStyle: FontStyle.italic,
                                                fontSize: 15,
                                                color: Colors.black87,
                                              ),
                                            ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                              Positioned(
                                right: 16,
                                top: 16,
                                child: Container(
                                  padding: const EdgeInsets.all(6.0),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Text(
                                    _currentWord!.type.toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _isAnswerSelected
                                      ? null
                                      : () => _checkAnswer(_correctAnswer),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    textStyle: const TextStyle(fontSize: 20),
                                    backgroundColor: const Color.fromARGB(
                                        255, 155, 193, 224),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: BorderSide(
                                        color: _isAnswerSelected &&
                                                _isCorrectAnswerSelected
                                            ? Colors.green
                                            : Colors.transparent,
                                        width: 3,
                                      ),
                                    ),
                                    elevation: 5,
                                  ),
                                  child: Text(
                                    _correctAnswer,
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _isAnswerSelected
                                      ? null
                                      : () => _checkAnswer(_wrongAnswer),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    textStyle: const TextStyle(fontSize: 20),
                                    backgroundColor: const Color.fromARGB(
                                        255, 155, 193, 224),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: BorderSide(
                                        color: _isAnswerSelected &&
                                                !_isCorrectAnswerSelected
                                            ? Colors.red
                                            : Colors.transparent,
                                        width: 3,
                                      ),
                                    ),
                                    elevation: 5,
                                  ),
                                  child: Text(
                                    _wrongAnswer,
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
