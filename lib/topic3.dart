import 'package:flutter/material.dart';
import 'dart:math';
import 'home_page.dart';

void main() {
  runApp(NumberCompositionApp());
}

class NumberCompositionApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Number Composition Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: NumberCompositionScreen(),
    );
  }
}

class NumberCompositionScreen extends StatefulWidget {
  @override
  _NumberCompositionScreenState createState() =>
      _NumberCompositionScreenState();
}

class _NumberCompositionScreenState extends State<NumberCompositionScreen> {
  int targetNumber = 0;
  int? selectedNumber1;
  int? selectedNumber2;
  List<int> availableNumbers = [];
  String resultMessage = '';
  Color resultColor = Colors.black;
  int score = 0;
  int totalQuestions = 0;
  List<String> foundCombinations = [];
  bool showRetryOptions = false;

  @override
  void initState() {
    super.initState();
    _generateNewProblem();
  }

  void _generateNewProblem() {
    setState(() {
      Random random = Random();
      targetNumber = random.nextInt(15) + 5;
      availableNumbers = [];

      // Generate numbers that sum to target
      for (int i = 1; i < targetNumber; i++) {
        if (random.nextBool() || availableNumbers.length < 5) {
          availableNumbers.add(i);
        }
      }

      // Add distracting numbers
      for (int i = 0; i < 3; i++) {
        availableNumbers.add(targetNumber + random.nextInt(5) + 1);
      }

      availableNumbers.shuffle();
      selectedNumber1 = null;
      selectedNumber2 = null;
      resultMessage = 'Find two numbers to make $targetNumber';
      resultColor = Colors.black;
      foundCombinations = [];
      showRetryOptions = false;
    });
  }

  void _selectNumber(int number) {
    setState(() {
      if (selectedNumber1 == null) {
        selectedNumber1 = number;
      } else if (selectedNumber2 == null && selectedNumber1 != number) {
        selectedNumber2 = number;
      } else {
        if (selectedNumber1 == number) {
          selectedNumber1 = selectedNumber2;
          selectedNumber2 = null;
        } else {
          selectedNumber2 = number;
        }
      }
    });
  }

  void _checkCombination() {
    if (selectedNumber1 == null || selectedNumber2 == null) return;

    setState(() {
      totalQuestions++;
      int sum = selectedNumber1! + selectedNumber2!;

      if (sum == targetNumber) {
        String combination = '${selectedNumber1!} + ${selectedNumber2!}';
        if (!foundCombinations.contains(combination)) {
          foundCombinations.add(combination);
          score++;
          resultMessage = 'Great! $combination = $targetNumber';
          resultColor = Colors.green;
          showRetryOptions = false;

          //refresh question in 2 seconds
          Future.delayed(Duration(seconds: 2), () {
            _generateNewProblem();
          });
        } else {
          resultMessage = 'Correct, but already found!';
          resultColor = Colors.blue;
          showRetryOptions = false;
        }
      } else {
        resultMessage =
            '$selectedNumber1 + $selectedNumber2 = $sum (Not $targetNumber)';
        resultColor = Colors.red;
        showRetryOptions = true;
      }

      // retry after wrong answer
      if (sum != targetNumber) return;
      
      selectedNumber1 = null;
      selectedNumber2 = null;
    });
  }

  void _retrySameQuestion() {
    setState(() {
      resultMessage = 'Find two numbers to make $targetNumber';
      resultColor = Colors.black;
      selectedNumber1 = null;
      selectedNumber2 = null;
      showRetryOptions = false;
    });
  }

  void _endGame() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Game Summary'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Total Questions: $totalQuestions'),
              Text('Correct Answers: $score'),
              SizedBox(height: 10),
              Text(
                'Success Rate: ${totalQuestions > 0 ? ((score / totalQuestions) * 100).toStringAsFixed(1) : 0}%',
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
        title: Text('Number Composition Game'),
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
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Center(
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Score: $score/$totalQuestions',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Text('Target Number:', style: TextStyle(fontSize: 24)),
                  SizedBox(height: 10),
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(color: Colors.orange, width: 3),
                    ),
                    child: Center(
                      child: Text(
                        targetNumber.toString(),
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  Text(
                    resultMessage,
                    style: TextStyle(fontSize: 24, color: resultColor),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  if (foundCombinations.isNotEmpty) ...[
                    Text('Found combinations:', style: TextStyle(fontSize: 18)),
                    Text(
                      foundCombinations.join(', '),
                      style: TextStyle(fontSize: 18, color: Colors.green),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                  ],
                  if (showRetryOptions) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: _retrySameQuestion,
                          child: Text('Try Again'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                        ),
                        SizedBox(width: 20),
                        ElevatedButton(
                          onPressed: _generateNewProblem,
                          child: Text('New Question'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                  ],
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: availableNumbers.map((number) {
                      bool isSelected =
                          selectedNumber1 == number || selectedNumber2 == number;
                      return GestureDetector(
                        onTap: () => _selectNumber(number),
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.blue[300] : Colors.blue[100],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              number.toString(),
                              style: TextStyle(fontSize: 28),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _checkCombination,
                    child: Text('Check Combination'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}