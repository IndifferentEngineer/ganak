import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() => runApp(const CalculatorApp());

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const CalculatorHome(),
    );
  }
}

class CalculatorHome extends StatefulWidget {
  const CalculatorHome({super.key});

  @override
  _CalculatorHomeState createState() => _CalculatorHomeState();
}

class _CalculatorHomeState extends State<CalculatorHome> {
  String _expression = '';
  String _result = '0';

  void buttonPressed(String buttonText) {
    setState(() {
      if (buttonText == 'C') {
        _expression = '';
        _result = '0';
      } else if (buttonText == '⌫') {  // Single cut button
        if (_expression.isNotEmpty) {
          _expression = _expression.substring(0, _expression.length - 1);
          _result = _expression.isEmpty ? '0' : _evaluateExpression(_expression);
        }
      } else if (buttonText == '=') {
        try {
          _result = _evaluateExpression(_expression);
        } catch (e) {
          _result = 'Error';
        }
      } else {
        _expression += buttonText;
        _result = _expression;
      }
    });
  }

  String _evaluateExpression(String expression) {
    try {
      final result = _calculateResult(expression);
      return NumberFormat('#,##0.#####').format(result);
    } catch (e) {
      return 'Error';
    }
  }

  double _calculateResult(String expression) {
    List<String> tokens = _tokenizeExpression(expression);
    List<double> numbers = [];
    List<String> operators = [];

    for (String token in tokens) {
      if (double.tryParse(token) != null) {
        numbers.add(double.parse(token));
      } else {
        while (operators.isNotEmpty && _hasPrecedence(token, operators.last)) {
          double b = numbers.removeLast();
          double a = numbers.removeLast();
          numbers.add(_applyOperation(a, b, operators.removeLast()));
        }
        operators.add(token);
      }
    }

    while (operators.isNotEmpty) {
      double b = numbers.removeLast();
      double a = numbers.removeLast();
      numbers.add(_applyOperation(a, b, operators.removeLast()));
    }

    return numbers.single;
  }

  List<String> _tokenizeExpression(String expression) {
    return expression.split(RegExp(r'([+\-*/])')).map((e) => e.trim()).toList();
  }

  bool _hasPrecedence(String op1, String op2) {
    if ((op1 == '*' || op1 == '/') && (op2 == '+' || op2 == '-')) {
      return false;
    }
    return true;
  }

  double _applyOperation(double a, double b, String operator) {
    switch (operator) {
      case '+':
        return a + b;
      case '-':
        return a - b;
      case '*':
        return a * b;
      case '/':
        return a / b;
      default:
        throw Exception('Unsupported operator');
    }
  }

  Widget buildButton(String buttonText) {
    return Expanded(
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.all(24.0),
          side: const BorderSide(color: Colors.white24),
        ),
        child: Text(
          buttonText,
          style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
        ),
        onPressed: () => buttonPressed(buttonText),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculator'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
              alignment: Alignment.centerRight,
              child: Text(
                _expression,
                style: const TextStyle(fontSize: 32, color: Colors.white),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
              alignment: Alignment.centerRight,
              child: Text(
                _result,
                style: const TextStyle(
                    fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            const Divider(),
            Column(
              children: [
                Row(
                  children: <Widget>[
                    buildButton('7'),
                    buildButton('8'),
                    buildButton('9'),
                    buildButton('/'),
                  ],
                ),
                Row(
                  children: <Widget>[
                    buildButton('4'),
                    buildButton('5'),
                    buildButton('6'),
                    buildButton('*'),
                  ],
                ),
                Row(
                  children: <Widget>[
                    buildButton('1'),
                    buildButton('2'),
                    buildButton('3'),
                    buildButton('-'),
                  ],
                ),
                Row(
                  children: <Widget>[
                    buildButton('0'),
                    buildButton('.'),
                    buildButton('⌫'), // Single cut button
                    buildButton('+'),
                  ],
                ),
                Row(
                  children: <Widget>[
                    buildButton('('),
                    buildButton(')'),
                    buildButton('%'),
                    buildButton('='),
                  ],
                ),
                Row(
                  children: <Widget>[
                    buildButton('C'), // Full clear button
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
