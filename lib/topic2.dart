import 'package:flutter/material.dart';
import 'dart:math';
import 'home_page.dart';

void main() {
  runApp(NumberOrderingApp());
}

class NumberOrderingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Number Ordering Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: NumberOrderingScreen(),
    );
  }
}

class NumberOrderingScreen extends StatefulWidget {
  @override
  _NumberOrderingScreenState createState() => _NumberOrderingScreenState();
}

class _NumberOrderingScreenState extends State<NumberOrderingScreen> {
  List<int> numbers = [];
  bool isAscending = true;
  String resultMessage = '';
  Color resultColor = Colors.black;
  int score = 0;
  int totalQuestions = 0;
  bool showAnswer = false;

  @override
  void initState() {
    super.initState();
    _generateNewNumbers();
  }

  void _generateNewNumbers() {
    setState(() {
      numbers = [];
      Random random = Random();

      int count = random.nextInt(3) + 3;
      while (numbers.length < count) {
        int num = random.nextInt(100) + 1;
        if (!numbers.contains(num)) {
          numbers.add(num);
        }
      }

      isAscending = random.nextBool();
      resultMessage = isAscending
          ? 'Arrange these numbers in ASCENDING order'
          : 'Arrange these numbers in DESCENDING order';
      resultColor = Colors.black;
      showAnswer = false;
    });
  }

  void _checkOrder() {
    setState(() {
      totalQuestions++;
      bool isCorrect = true;

      for (int i = 0; i < numbers.length - 1; i++) {
        if (isAscending) {
          if (numbers[i] > numbers[i + 1]) {
            isCorrect = false;
            break;
          }
        } else {
          if (numbers[i] < numbers[i + 1]) {
            isCorrect = false;
            break;
          }
        }
      }

      if (isCorrect) {
        resultMessage = 'Correct! Perfect ${isAscending ? 'ascending' : 'descending'} order!';
        resultColor = Colors.green;
        score++;
        Future.delayed(Duration(seconds: 2), _generateNewNumbers);
      } else {
        resultMessage = 'Not quite right. Please Try Again!';
        resultColor = Colors.red;
      }
    });
  }

  void _showSolution() {
    setState(() {
      showAnswer = true;
      if (isAscending) {
        numbers.sort();
      } else {
        numbers.sort((a, b) => b.compareTo(a));
      }
    });
  }

  void _moveNumber(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final int number = numbers.removeAt(oldIndex);
      numbers.insert(newIndex, number);
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
        title: Text('Number Ordering Game'),
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
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Score: $score/$totalQuestions',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 20),
                      Text(
                        resultMessage,
                        style: TextStyle(fontSize: 24, color: resultColor),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30),
                Container(
                  height: 100,
                  child: ReorderableListView(
                    scrollDirection: Axis.horizontal,
                    onReorder: _moveNumber,
                    children: [
                      for (int i = 0; i < numbers.length; i++)
                        Container(
                          key: Key('$i'),
                          margin: EdgeInsets.symmetric(horizontal: 10),
                          child: _buildNumberBox(numbers[i]),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 30),
                Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: _checkOrder,
                            child: Text('Check Order'),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                            ),
                          ),
                          SizedBox(width: 20),
                          ElevatedButton(
                            onPressed: _showSolution,
                            child: Text('Show Answer'),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                              backgroundColor: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _generateNewNumbers,
                        child: Text('New Numbers'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                          backgroundColor: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                if (showAnswer)
                  Container(
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      'Tip: ${isAscending ? 'Ascending' : 'Descending'} order means numbers go '
                      '${isAscending ? 'from small to big' : 'from big to small'}',
                      style: TextStyle(fontSize: 16, color: Colors.blue),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNumberBox(int number) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.blue[100],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: Offset(0, 3),
          )
        ],
      ),
      child: Center(
        child: Text(
          number.toString(),
          style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}