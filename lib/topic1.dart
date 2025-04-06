import 'package:flutter/material.dart';
import 'dart:math';
import 'home_page.dart';

class NumberComparisonApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Number Comparison',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: NumberComparisonScreen(),
    );
  }
}

class NumberComparisonScreen extends StatefulWidget {
  @override
  _NumberComparisonScreenState createState() => _NumberComparisonScreenState();
}

class _NumberComparisonScreenState extends State<NumberComparisonScreen> {
  int _num1 = 0;
  int _num2 = 0;
  String _resultMessage = '';
  Color _resultColor = Colors.black;
  int _score = 0;
  int _totalQuestions = 0;
  bool _isLessThanQuestion = false;

  @override
  void initState() {
    super.initState();
    _generateNewNumbers();
  }

  void _generateNewNumbers() {
    setState(() {
      _num1 = Random().nextInt(99);
      _num2 = Random().nextInt(99);

      _isLessThanQuestion = Random().nextBool();

      while (_num1 == _num2) {
        _num2 = Random().nextInt(99) + 1;
      }

      _resultMessage = _isLessThanQuestion
          ? 'Tap the number that is LESS than the other'
          : 'Tap the number that is GREATER than the other';
      _resultColor = Colors.black;
    });
  }

  void _checkAnswer(bool tappedFirstNumber) {
    setState(() {
      _totalQuestions++;
      bool correctAnswer;
      int selectedNumber = tappedFirstNumber ? _num1 : _num2;
      int otherNumber = tappedFirstNumber ? _num2 : _num1;

      if (_isLessThanQuestion) {
        correctAnswer = selectedNumber < otherNumber;
      } else {
        correctAnswer = selectedNumber > otherNumber;
      }

      if (correctAnswer) {
        _resultMessage = _isLessThanQuestion
            ? 'Correct! $selectedNumber is less than $otherNumber'
            : 'Correct! $selectedNumber is greater than $otherNumber';
        _resultColor = Colors.green;
        _score++;
      } else {
        _resultMessage = _isLessThanQuestion
            ? 'Oops! $selectedNumber is NOT less than $otherNumber'
            : 'Oops! $selectedNumber is NOT greater than $otherNumber';
        _resultColor = Colors.red;
      }

      Future.delayed(Duration(seconds: 2), _generateNewNumbers);
    });
  }

  void _endGame() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Game Over'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Total Questions: $_totalQuestions'),
              Text('Correct Answers: $_score'),
              SizedBox(height: 10),
              Text(
                'Success Rate: ${_totalQuestions > 0 ? ((_score / _totalQuestions) * 100).toStringAsFixed(1) : 0}%',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Continue Playing'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              },
              child: Text('Back to Home'),
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
        title: Text('Number Comparison Game'),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: _endGame,
            tooltip: 'End Game',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/start.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(15),
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Score: $_score/$_totalQuestions',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.all(15),
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _resultMessage,
                    style: TextStyle(fontSize: 24, color: _resultColor),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNumberButton(_num1, true),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text('vs', style: TextStyle(fontSize: 24)),
                    ),
                    _buildNumberButton(_num2, false),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNumberButton(int number, bool isFirstNumber) {
    return GestureDetector(
      onTap: () => _checkAnswer(isFirstNumber),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.8),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Text(
          number.toString(),
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}